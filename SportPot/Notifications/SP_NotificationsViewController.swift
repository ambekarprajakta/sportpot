//
//  SP_NotificationsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 10/01/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SP_NotificationsViewController: UIViewController {
    
    @IBOutlet private weak var notificationsTable: UITableView!
    
    private let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""
    private let db = Firestore.firestore()
    private let cellId = String(describing: SP_NotificationsCell.self)
    private var notifications = Array<NotificationObject>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getNotifications()
    }
    
    private func setupView() {
        notificationsTable.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        notificationsTable.rowHeight = UITableView.automaticDimension
        notificationsTable.estimatedRowHeight = 60
        notificationsTable.dataSource = self
        notificationsTable.delegate = self
    }
    
    private func getNotifications() {
        self.showHUD()
        db.collection("user").document(currentUser).getDocument { (docSnapShot, error) in
            self.hideHUD()
            if let userData = docSnapShot?.data() {
                if let notificationArr = userData["notifications"] as? JSONArray {
                    self.notifications = notificationArr.toArray(of: NotificationObject.self, keyDecodingStartegy: .convertFromSnakeCase) ?? []
                    self.updateNotificationBadgeCount()
                }
                self.notificationsTable.reloadData()
            }
        }
    }
    
    func updateNotificationBadgeCount() {
        let unReadNotifications =  self.notifications.filter({ (notifObj) -> Bool in
            return !notifObj.isRead
        })
        print(unReadNotifications)
        guard let tabItems = self.tabBarController?.tabBar.items else { return }
        let tabItem = tabItems[2]
        if unReadNotifications.count > 0 {
            tabItem.badgeValue = String(unReadNotifications.count)
        } else {
            tabItem.badgeValue = nil
        }

    }
    
    func updateNotificationToFirebase(indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        if notification.isRead { return }
        notifications[indexPath.row].isRead = true
        self.updateNotificationBadgeCount()
        do {
            let enc = JSONEncoder()
            if let encoded = try enc.encode(notifications).toJSON() as? [[String:Any]] {
                let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""
                let notifRef = Firestore.firestore().collection("user").document(currentUser)
                notifRef.setData(["notifications": encoded], merge: true) { (error) in
                    print("success")
                }
            }
        } catch {
            print(error)
        }
        
        notificationsTable.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension SP_NotificationsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SP_NotificationsCell {
            cell.display(notification: notifications[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SP_NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rvc = storyboard.instantiateViewController(identifier: String(describing: SP_RankingsViewController.self)) as SP_RankingsViewController
        guard let potID = notifications[indexPath.row].potId else { return }
        Firestore.firestore().collection("pots").document(potID).getDocument { [weak self] (docSnapShot, error) in
            guard let self = self, let potJson = docSnapShot?.data(), let pot = potJson.to(type: Pot.self, keyDecodingStartegy: .convertFromSnakeCase) else {
                return
            }
            rvc.pot = pot
            self.navigationController?.pushViewController(rvc, animated: true)
            self.updateNotificationToFirebase(indexPath: indexPath)
        }
    }
    
}
