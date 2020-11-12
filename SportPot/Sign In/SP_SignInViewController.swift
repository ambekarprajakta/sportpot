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
        emailOrPhoneTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .go
        emailOrPhoneTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSignupVCNotification"), object: nil, userInfo: nil)
        }
    }
    @IBAction func signInAction(_ sender: Any) {
        authenticateUser()
    }
    private func authenticateUser() {
        guard let username = emailOrPhoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty else {
            // Show invalid username error here...
            self.popupAlert(title: "Error", message: ErrorMessages.emailPhoneError, actionTitles: ["Close"], actions: [{ action1 in
                self.emailOrPhoneTextField.text = ""
                }])
            
            return
        }
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            // Show password empty error here...
            self.popupAlert(title: "Error", message: ErrorMessages.passwordError, actionTitles: ["Close"], actions: [{ action1 in
                self.passwordTextField.text = ""
                }])
            return
        }
        
        Auth.auth().signIn(withEmail: username, password: password) { [weak self] authResult, error in
            
            guard let strongSelf = self else { return }
            if let error = error {
                print("Authentication Error: \(error)")
                strongSelf.popupAlert(title: "Error", message: error.localizedDescription, actionTitles: ["Close"], actions: [{ action1 in
                    strongSelf.emailOrPhoneTextField.text = ""
                    strongSelf.passwordTextField.text = ""
                    }])
            } else {
                print("Successfully logged in!")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(username, forKey: "currentUser")
                // Show home page
                //self.performSegue(withIdentifier: "loginSegue", sender: nil)
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
extension SP_SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailOrPhoneTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
            authenticateUser()
        }
        return false
    }
}
