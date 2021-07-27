//
//  SP_MyPotsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 07/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

struct PotModel {
    let fixturePredictionsArr : Array<Any>
    let createdOn : String
    let joinees : String
    let points : Int
}

class SP_MyPotsViewController: UIViewController {
    
    @IBOutlet weak var potTableView: UITableView!
    var delegate: PushManagerDelegate?
    private let refreshControl = UIRefreshControl()
    private var pots = [Pot]()
    private let cellID = String(describing: SP_MyPotsTableViewCell.self)
    private var currentUser = UserDefaults.standard.string(forKey: UserDefaultsConstants.currentUserKey) ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.sp_mustard
        setupTable()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNotificationDetail(_:)), name: NSNotification.Name(rawValue: "showNotificationDetail"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getPotDataFromServer()
        getNotificationsCount()
    }
    
    private func setupTable() {
        refreshControl.addTarget(self, action: #selector(getPotDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        potTableView.addSubview(refreshControl)
        potTableView.register(UINib(nibName: "SP_MyPotsTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        potTableView.rowHeight = 60
    }
    
    @objc func showNotificationDetail(_ notification: NSNotification) {
        
        if let pot = notification.userInfo?["pot"] as? Pot {
            navigateToPotDetail(pot: pot, userInfo: [:])
        }
    }
    
    func getNotificationsCount() {
        Firestore.firestore().collection("user").document(currentUser).getDocument { (docSnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                guard let response = docSnapshot?.data() else { return }
                guard let notificationsArr = response["notifications"] as? JSONArray else { return }
                guard var notifications = notificationsArr.toArray(of: NotificationObject.self) else { return }

                let unReadNotifications =  notifications.filter({ (notifObj) -> Bool in
                    return !notifObj.isRead
                })
                print(unReadNotifications)
                self.updateNotificationBadge(count: unReadNotifications.count)
            }
        }
    }
    
    func updateNotificationBadge(count: Int) {
        guard let tabItems = self.tabBarController?.tabBar.items else { return }
        let tabItem = tabItems[2]
        
        if count != UserDefaults.standard.integer(forKey: UserDefaultsConstants.notificationsBadgeCount) {
            tabItem.badgeValue = String(count)
        } else {
            tabItem.badgeValue = nil
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: .badge)
        { (granted, error) in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = Int(tabItem.badgeValue ?? "") ?? 0
                }
            }
        }
    }
    
    // MARK: - Fetch Pot Data
    
    @objc private func getPotDataFromServer() {
        self.showHUD()
        refreshControl.beginRefreshing()
        let db = Firestore.firestore()
        self.potTableView.restore()
        db.collection("user").document(currentUser).getDocument { (docSnapShot, error) in
            self.refreshControl.endRefreshing()
            self.hideHUD()
            guard let snapshot = docSnapShot else {
                print("Error retreiving documents \(error!)")
                return
            }
            guard let joinedPotsArr = snapshot.data()?["joinedPots"] as? Array<String> else {
                self.potTableView.setEmptyMessage("No Data Available")
                return
            }
            if joinedPotsArr.count == 0 {
                self.potTableView.setEmptyMessage("No Pots Available")
            }
            self.pots.removeAll() // Remove previous data
            for potID in joinedPotsArr {
                db.collection("pots").document(potID).getDocument { [weak self] (docSnapShot, error) in
                    guard let self = self, let potJson = docSnapShot?.data(), let pot = potJson.to(type: Pot.self, keyDecodingStartegy: .convertFromSnakeCase) else {
                        return
                    }
                    pot.id = potID
                    self.pots.append(pot)
                    self.pots =  self.pots.sorted { lhs, rhs in
                        Date(timeIntervalSince1970: Double(lhs.createdOn) ?? 0) > Date(timeIntervalSince1970: Double(rhs.createdOn) ?? 0)
                    }
                    self.potTableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Table View

extension SP_MyPotsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SP_MyPotsTableViewCell {
            if pots.count > 0 {
                matchCell.display(pot: pots[indexPath.section])
            }
            return matchCell
        }
        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToPotDetail(pot: pots[indexPath.section], userInfo: [:])
    }
    
    func navigateToPotDetail(pot: Pot, userInfo: [AnyHashable : Any]) {
        
        setupChat(using: pot)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rvc = storyboard.instantiateViewController(identifier: String(describing: SP_RankingsViewController.self)) as SP_RankingsViewController
        rvc.userInfo = userInfo
        rvc.pot = pot
        self.navigationController?.pushViewController(rvc, animated: false)
        
    }
    
    
    func fetchPotFromDB (potID: String, completionHandler:  @escaping (Pot) -> ()) {
        
        self.showHUD()
        Firestore.firestore().collection("pots").document(potID).getDocument { [weak self] (docSnapShot, error) in
            self?.hideHUD()
            guard let _ = self, let potJson = docSnapShot?.data(), let pot = potJson.to(type: Pot.self, keyDecodingStartegy: .convertFromSnakeCase) else {
                return
            }
//            pot.id = potID
//            self.pot = pot
            completionHandler(pot)
        }
    }

    private func setupChat(using pot: Pot) {
        let docRef = Firestore.firestore().collection("chats").document(pot.id ?? "")
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists{
                    //print("Document data: \(document.data())")
                } else {
                    print("Document does not exist")
                    Firestore.firestore().collection("chats").document(pot.id ?? "").setData([
                                                                                                "id" : pot.name])
                }
            }
        }
    }
}

extension SP_MyPotsViewController: PushManagerDelegate {
    func handleNavigationFromPushNotification(with userInfo: [AnyHashable : Any]) {
        guard let potID = userInfo["potID"] as? String else { return }
        self.fetchPotFromDB(potID: potID) { (pot) in
            pot.id = potID
            self.navigateToPotDetail(pot: pot, userInfo: userInfo)
        }
    }
}
