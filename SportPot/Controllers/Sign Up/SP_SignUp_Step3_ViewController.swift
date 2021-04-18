//
//  SP_SignUp_Step3_ViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 26/01/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SP_SignUp_Step3_ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var verificationCodeLabel: SP_UnderlinedTextField!
    public var phoneNumber: String?
    public var username: String?
    public var email: String?
    public var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.setTitle("Verify Code", for: .normal)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        if button.titleLabel?.text == "Verify Code" {
            self.showHUD()
            ///Verify Phone Number
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: UserDefaults.standard.string(forKey: "authVerificationID") ?? "", verificationCode: self.verificationCodeLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines) )
            print(credential)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                self.hideHUD()
                if error == nil {
                    // User is signed in
                    self.createUser()
                } else {
                    self.popupAlert(title: "Error!", message: error?.localizedDescription, actionTitles: ["Okay"], actions: [{ action1 in
                    }])
                    return
                }
                return
            }
        }
    }
    
    @IBAction func resendCodeAction(_ sender: Any) {
        self.showHUD()
        PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", uiDelegate: nil) { (verificationID, error) in
            self.hideHUD()
            if let error = error {
                self.popupAlert(title: "Error!", message: error.localizedDescription, actionTitles: ["Okay"], actions: [{ action1 in
                }])
                return
            }else{
                print(verificationID ?? "")
                self.popupAlert(title: "Success!", message: "Verification code successfully sent!", actionTitles: ["Okay"], actions: [{ action1 in
                    //                    self.verificationCodeLabel.becomeFirstResponder()
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                }])
            }
        }
        
    }
    
    func createUser() {
        self.showHUD()
        //User was created successfully, now store the basic details of the user
        Firestore.firestore().collection("user").document(self.email ?? "").setData([
            "email":self.email ?? "",
            "displayName" : self.username ?? "",
            "points" : 0,
            "joinedPots" : []
        ], merge: true){ (error) in
            //If all good, proceed!
            self.hideHUD()
            if error != nil {
                self.popupAlert(title: "Error!", message: error?.localizedDescription, actionTitles: ["Okay"], actions: [{ action1 in
                }])
                return
            } else {
                UserDefaults.standard.set(self.email, forKey: UserDefaultsConstants.currentUserKey)
                UserDefaults.standard.set(self.username, forKey: UserDefaultsConstants.displayNameKey)
                self.pushToHomeScreen()
            }
        }
    }
    
    func pushToHomeScreen() {
        //Validate and push to the Home Page
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "SP_MainTabBarViewController")
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
}
