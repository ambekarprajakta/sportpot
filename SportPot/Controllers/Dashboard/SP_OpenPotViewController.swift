//
//  SP_OpenPotViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 05/06/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SideMenu

class SP_OpenPotViewController: UIViewController {
    
    @IBOutlet weak var totalPotsCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(joinPotAction(notification:)), name: NSNotification.Name(rawValue: "joinPotNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToMyPots), name: NSNotification.navigateToMyPots, object: nil)
        getCurrentRound()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNotificationData()
    }
    
    private func setupNavigationBar() {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: "logo-sport-pot"), for: .normal)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    fileprivate func getCurrentRound() {
        self.showHUD()
        Firestore.firestore().collection("currentRound").document("round").getDocument { (docSnapShot, error) in
            self.hideHUD()
            if error == nil {
                guard let currentWeekStr = docSnapShot?.data() else { return }
                guard let currentRound = currentWeekStr["currentRound"] as? String else { return }
                guard let leagueID = currentWeekStr["leagueID"] as? String else { return }
                guard let bookMakerID = currentWeekStr["bookMakerID"] as? String else { return }
                UserDefaults.standard.set(currentRound, forKey: UserDefaultsConstants.currentRoundKey)
                UserDefaults.standard.set(leagueID, forKey: UserDefaultsConstants.leagueID)
                UserDefaults.standard.set(bookMakerID, forKey: UserDefaultsConstants.bookMakerID)
            }
        }
    }

    @objc func joinPotAction(notification: NSNotification) {
        self.showHUD()
        
        if let notificationDict = notification.userInfo {
            guard let potIDStr = notificationDict["owner"] as? String else { return }
            guard let fixtureCount = notificationDict["fixtureCount"] as? String else { return }
            guard let timestamp = notificationDict["timestamp"] as? String else { return }
            
            if let decodedStr = potIDStr.base64Decoded() {
                print("Base64 decoded string: \"\(decodedStr)\"")
                //Extract user and timestamp from decodedStr
                let dataArr = decodedStr.split(separator: "&")
                let owner = String(dataArr[0])
                let currentUser = UserDefaults.standard.string(forKey: UserDefaultsConstants.currentUserKey) ?? ""
                Firestore.firestore().collection("user").document(currentUser).getDocument { (docSnapShot, error) in
                    self.hideHUD()
                    if let userData = docSnapShot?.data() {
                        if let pots = userData["joinedPots"] as? [String] {
                            if pots.contains(potIDStr) {
                                // User has already joined the pot
                                self.popupAlert(title: nil, message: "You’ve already placed your bets for this pot", actionTitles: ["Okay"], actions: [{action in}])
                                return
                            }
                        }
                    }
                    // Allow user to join the pot
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let potInviteeViewController = storyboard.instantiateViewController(identifier: "SP_Pot_Invitee_ViewController") as SP_Pot_Invitee_ViewController
                    potInviteeViewController.ownerStr = owner
                    potInviteeViewController.potIDStr = potIDStr
                    potInviteeViewController.remainingTime = timestamp
                    potInviteeViewController.fixtureCount = fixtureCount
                    potInviteeViewController.delegate = self
                    self.present(potInviteeViewController, animated: true, completion: nil)
                }
            }
        }
    }

    func fetchNotificationData(){
        showHUD()
        Firestore.firestore().collection("pots").getDocuments { (snapshot, error) in
            self.hideHUD()
            if error == nil {
                self.totalPotsCountLabel.text = "\(snapshot?.documents.count ?? 100)"
            }
        }
    }
    
    @IBAction func hamburgerMenuAction(_ sender: Any) {
        SPAnalyticsManager().logEventToFirebase(name: FirebaseEvents.didClickHamburgerMenu, parameters: nil)
        let rightMenuNavigationController = storyboard!.instantiateViewController(withIdentifier: "SP_RightMenuNavController") as! SideMenuNavigationController
        rightMenuNavigationController.leftSide = false
        rightMenuNavigationController.settings = makeSettings()
        self.present(rightMenuNavigationController, animated: true, completion: nil)
        
    }
    
    func makeSettings() -> SideMenuSettings{
        var settings = SideMenuSettings()
        settings.presentationStyle = SideMenuPresentationStyle.menuDissolveIn
        settings.menuWidth = min(view.frame.width, view.frame.height) * 0.8
        settings.blurEffectStyle = .dark
        return settings
    }
    
    @objc private func navigateToMyPots() {
        tabBarController?.selectedIndex = 1
    }
}

extension SP_OpenPotViewController: SP_Pot_Invitee_ViewControllerDelegate {
    func didJoinPot() {
        navigateToMyPots()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let goodLuckViewController = storyboard.instantiateViewController(identifier: "SP_GoodLuckViewController") as SP_GoodLuckViewController
        self.present(goodLuckViewController, animated: true, completion: nil)
    }
}
