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
    @IBOutlet weak var phoneNumberTextField: SP_UnderlinedTextField!
    @IBOutlet weak var verificationCodeLabel: SP_UnderlinedTextField!
    @IBOutlet weak var tncBtn: UIButton!
    @IBOutlet weak var sendCodeBtn: UIButton!
    @IBOutlet weak var createAccountBtn: UIButton!
    var window: UIWindow?
    public var username: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    func setupViews(){
        self.createAccountBtn.isHidden = true
        self.sendCodeBtn.isHidden = false
        self.sendCodeBtn.setTitle("Send Code", for: .normal)
    }
    func sendVerificationCode() {
        createAccountAction(self)
        return
        //Prajakta test number:"+91-8149435337"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.popupAlert(title: "Error!", message: error.localizedDescription, actionTitles: ["Okay"], actions: [{ action1 in
                    }])
                return
            }else{
                print(verificationID ?? "")
                self.popupAlert(title: "Success!", message: "Verification code successfully sent!", actionTitles: ["Okay"], actions: [{ action1 in
                    self.verificationCodeLabel.becomeFirstResponder()
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    self.createAccountBtn.isHidden = true
                    self.sendCodeBtn.isHidden = false
                    self.sendCodeBtn.setTitle("Verify Code", for: .normal)
                    }])
            }
        }
    }
    
    ///Verify Phone Number
    func verifyCredWithPhoneNumber(verificationID: String, verificationCode:String) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: self.verificationCodeLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines) )
        print(credential)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error == nil {
                //Check TnC
                // User is signed in
                self.createAccountBtn.isHidden = false
                self.sendCodeBtn.isHidden = true
            }else {
                self.popupAlert(title: "Error!", message: error?.localizedDescription, actionTitles: ["Okay"], actions: [{ action1 in
                    }])
                return
            }
            return
        }
    }
    
    
    @IBAction func authenticateCode(_ sender: UIButton) {
        if sender.titleLabel?.text == "Send Code" {
            sendVerificationCode()
        }else{
            verifyCredWithPhoneNumber(verificationID: UserDefaults.standard.string(forKey: "authVerificationID") ?? "", verificationCode: verificationCodeLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        }
    }
    
    @IBAction func tncAction(_ sender: UIButton) {
        tncBtn.isSelected = !sender.isSelected
    }
    @IBAction func createAccountAction(_ sender: Any) {
        //        sendVerificationCode()
        if self.tncBtn.isSelected {
            pushToHomeScreen()
        }else{
            self.popupAlert(title: "Error!", message: "Please check the Terms and Conditions", actionTitles: ["Okay"], actions: [{ action1 in
                }])
        }
    }
    
    func pushToHomeScreen() {
        //Validate and push to the Home Page
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(username, forKey: "currentUser")

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
