//
//  PushNotificationManager.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 22/04/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications


class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate,PushManagerDelegate {
    
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }

    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("notificationTokens").document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
            UserDefaults.standard.set(token, forKey: UserDefaultsConstants.notificationToken)
            UserDefaults.standard.synchronize()
        }
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let notificationType = userInfo["type"] as? String {
            print("Custom data received: \(notificationType)")
            switch notificationType {
            case "join", "won", "comment":
                print("Show Rankings")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.handleNavigationFromPushNotification(with: userInfo)
//                }
            default:
                print("Test")
            }
            
            //TODO: For group notifications
//            switch response.actionIdentifier {
//            case UNNotificationDefaultActionIdentifier:
//                // the user swiped to unlock
//                print("Default identifier")
//
//            case "show":
//                // the user tapped our "show more info…" button
//                print("Show more information…")
//
//            default:
//                break
//            }
        }

        // you must call the completion handler when you're done
        completionHandler()
    }
    
    func handleNavigationFromPushNotification(with userInfo: [AnyHashable : Any]) {

        let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        if let tabController = window?.rootViewController { //Tab bar
            let homeVC: SP_MainTabBarViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SP_MainTabBarViewController") as! SP_MainTabBarViewController
            guard let navController = tabController.children[1] as? UINavigationController else {return}
            for vc in navController.viewControllers {
                if vc .isKind(of: SP_MyPotsViewController.self)  {
                    if userInfo["type"] as! String == "comment" {
                        homeVC.notificationType = "showChatVC"
                    } else {
                        homeVC.notificationType = "showRankingsVC"
                    }
                    homeVC.userInfo = userInfo
                    window?.rootViewController = homeVC
                    window?.makeKeyAndVisible()
                }
            }
        }
    }
}
