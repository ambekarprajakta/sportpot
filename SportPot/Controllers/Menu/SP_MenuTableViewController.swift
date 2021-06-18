//
//  SP_MenuTableViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 08/06/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import SideMenu
import UIKit

class SP_MenuTableViewController: UITableViewController {
    let menuItems = ["Rules", "Privacy Policy", "Terms and Conditions", "Logout"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.tag = indexPath.row
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.font = UIFont.ubuntuRegularFont(ofSize: 16)
        cell.textLabel?.textColor = .sp_mustard
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch indexPath.row {
        case 0:
            let rulesViewController = storyboard.instantiateViewController(identifier: String(describing: SP_RulesViewController.self)) as SP_RulesViewController
            self.present(rulesViewController, animated: true, completion: nil)
        case 1:
            let termsNPrivacyViewController = storyboard.instantiateViewController(identifier: String(describing: SP_TermsNPrivacyViewController.self)) as SP_TermsNPrivacyViewController
            self.present(termsNPrivacyViewController, animated: true, completion: nil)
        case 2:
            let termsNPrivacyViewController = storyboard.instantiateViewController(identifier: String(describing: SP_TermsNPrivacyViewController.self)) as SP_TermsNPrivacyViewController
            termsNPrivacyViewController.vcType = "tnc"
            self.present(termsNPrivacyViewController, animated: true, completion: nil)
        case 3:
            logout()
        default:
            print("Do nothing")
        }
    }
    
    
    //MARK:- Logout
    
    func logout(){
        self.popupAlert(title: "Logout", message: "Are you sure you want to logout?", actionTitles: ["Yes","Cancel"], actions: [{ action1 in
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.set(nil, forKey: "currentUser")
            UserDefaults.standard.set(nil, forKey: "displayName")
            UIApplication.shared.applicationIconBadgeNumber = 0
            UIApplication.shared.unregisterForRemoteNotifications()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }, {action2 in
        }])
    }
}
