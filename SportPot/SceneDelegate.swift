//
//  SceneDelegate.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 03/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks

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
        guard let _ = (scene as? UIWindowScene) else { return }

        // Check if the app is launched from Universal link
        if let userActivity = connectionOptions.userActivities.first {
            DeeplinkManager.handleUserActivity(userActivity: userActivity)
        }
    }

    func loadBaseController() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let window = self.window else { return }
        window.makeKeyAndVisible()
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            // Show home page
            let homeVC: SP_MainTabBarViewController = storyboard.instantiateViewController(withIdentifier: "SP_MainTabBarViewController") as! SP_MainTabBarViewController
            self.window?.rootViewController = homeVC
        } else {
            // Show login page
            let loginVC: SP_GetStartedViewController = storyboard.instantiateViewController(withIdentifier: "SP_GetStartedViewController") as! SP_GetStartedViewController
            self.window?.rootViewController = loginVC
        }
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

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        DeeplinkManager.handleUserActivity(userActivity: userActivity)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
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

class DeeplinkManager {

    typealias DeepLinkQueryParams = (action: String?, owner: String?, timeStamp: String?)

    static func handleUserActivity(userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL, let urlStr = url.absoluteString.removingPercentEncoding,
          let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        let queryParams = getQueryParameters(from: urlStr)

        guard let owner = queryParams.owner, !owner.isEmpty else {
            let _ = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
                guard let urlStr = dynamiclink?.url?.absoluteString else { return }
                let queryParams = getQueryParameters(from: urlStr)
                self.handleDeepLink(queryParams: queryParams)
            }
            return
        }

        handleDeepLink(queryParams: queryParams)
    }

    private static func getQueryParameters(from url: String) -> DeepLinkQueryParams {
        let actionStr = getQueryStringParameter(url: url, param: "action")
        let owner = getQueryStringParameter(url: url, param: "owner")
        let timestamp = getQueryStringParameter(url: url, param: "timestamp")
        return (actionStr, owner, timestamp)
    }

    private static func handleDeepLink(queryParams: DeepLinkQueryParams) {
        let userInfo: [String: Any] = [
            "owner": queryParams.owner as Any,
            "action": queryParams.action as Any,
            "timestamp": queryParams.timeStamp as Any
        ]
        if queryParams.action == "joinPot" {
            /// Let the joinee join the pot
            /// Pot preview
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "joinPotNotification"), object: nil, userInfo: userInfo)
        }
    }

    private static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

}
