//
//  SP_SettingsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SP_SettingsViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        userLabel.text = "Hi, \(UserDefaults.standard.string(forKey: UserDefaultsConstants.currentUserKey) ?? "Guest")"
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getNotificationsCount()
    }

    func getNotificationsCount() {
        Firestore.firestore().collection("user").document(currentUser).getDocument { (docSnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                guard let response = docSnapshot?.data() else { return }
                guard let notificationsArr = response["notifications"] as? JSONArray else { return }
                guard let notifications = notificationsArr.toArray(of: NotificationObject.self) else { return }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
