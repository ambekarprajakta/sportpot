//
//  SP_MainTabBarViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 13/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

protocol PushManagerDelegate: class {
    func handleNavigationFromPushNotification(with userInfo: [AnyHashable : Any])
}

class SP_MainTabBarViewController: UITabBarController {
    
    weak var pushDelegate: PushManagerDelegate?
    var notificationType : String = ""
    var userInfo: [AnyHashable : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if notificationType == "showRankingsVC" || notificationType == "showChatVC" {
            for navController in self.viewControllers as? [UINavigationController] ?? [] {
                for vc in navController.children {
                    if vc.isKind(of: SP_MyPotsViewController.self) {
                        self.selectedIndex = 1
                        let mypots = vc as? SP_MyPotsViewController
                        mypots?.handleNavigationFromPushNotification(with: userInfo ?? [:])
                    }
                }
            }
        }
    }
}
