//
//  SceneDelegate.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 03/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        self.loadBaseController()
    }
    func loadBaseController() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let window = self.window else { return }
        window.makeKeyAndVisible()
        //if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            // Show home page
            let homeVC: SP_MainTabBarViewController = storyboard.instantiateViewController(withIdentifier: "SP_MainTabBarViewController") as! SP_MainTabBarViewController
            self.window?.rootViewController = homeVC
        /*} else {
            // Show login page
            let loginVC: SP_GetStartedViewController = storyboard.instantiateViewController(withIdentifier: "SP_GetStartedViewController") as! SP_GetStartedViewController
            self.window?.rootViewController = loginVC
        }*/
        self.window?.makeKeyAndVisible()
    }
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        // change the root view controller to your specific view controller
        window.rootViewController = vc
        // add animation
        UIView.transition(with: window,
                          duration: 1.0,
                          options: [.curveEaseInOut],
                          animations: nil,
                          completion: nil)

    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        CoreDataManager.sharedManager.saveContext()
    }


}

