//
//  SP_SignInViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 03/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseAuth

class SP_SignInViewController: UIViewController {
    
    @IBOutlet weak var emailOrPhoneTextField: SP_UnderlinedTextField!
    @IBOutlet weak var passwordTextField: SP_UnderlinedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signInAction(_ sender: Any) {
        let emailOrPhone = emailOrPhoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        
        Auth.auth().signIn(withEmail: emailOrPhone, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            // ...
            if error != nil {
                print("Authentication error!")
            }else{
                print("Successfully logged in!")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                // Show home page
                //        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "SP_MainTabBarViewController")
                
                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                
                
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
