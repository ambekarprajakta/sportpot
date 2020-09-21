//
//  SP_SignUp_Step2_ViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 11/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseAuth

class SP_SignUp_Step2_ViewController: UIViewController {
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func sendVerificationCode() {
        PhoneAuthProvider.provider().verifyPhoneNumber("+91-8149435337", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                print(verificationID ?? "")
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "", verificationCode: "991874")
                print(credential)
//                verifyCredWithPhoneNumber(verificationID,"991874")
            }
        }
        // Sign in using the verificationID and the code sent to the user
        //...
    }
    
    
    func verifyCredWithPhoneNumber(verificationID: String, verificationCode:String) {
        
    }
    @IBAction func createAccountAction(_ sender: Any) {
        
        sendVerificationCode()
//        pushToHomeScreen()
        
    }
    
    func pushToHomeScreen() {
        //Validate and push to the Home Page
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        // Show home page
        //        self.performSegue(withIdentifier: "loginSegue", sender: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "SP_MainTabBarViewController")
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    // MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     if segue.identifier == "loginSegue" {
     let appDelegate = UIApplication.shared.delegate! as! AppDelegate
     let destination = segue.destination
     
     //            let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "myTabbarControllerID")
     appDelegate.window?.rootViewController = destination
     appDelegate.window?.makeKeyAndVisible()
     
     
     }
     
     }
     */
    
}
