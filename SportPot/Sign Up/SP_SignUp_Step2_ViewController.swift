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
    @IBOutlet weak var tncBtn: UIButton!
    @IBOutlet weak var sendCodeBtn: UIButton!
    var window: UIWindow?
    var username : String?
    var email : String?
    var password : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func sendVerificationCode() {
        self.showHUD()
        //Prajakta test number:"+91-8149435337"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), uiDelegate: nil) { (verificationID, error) in
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
                    let signUp3VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step3_ViewController") as!  SP_SignUp_Step3_ViewController
                    signUp3VC.phoneNumber = self.phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    signUp3VC.username = self.username
                    signUp3VC.email = self.email
                    signUp3VC.password = self.password
                    self.present(signUp3VC, animated: true, completion: nil)
                }])
            }
        }
    }
    
    @IBAction func authenticateCode(_ sender: UIButton) {
        if self.tncBtn.isSelected {
            sendVerificationCode()
        } else{
            self.popupAlert(title: "Error!", message: "Please check the Terms and Conditions", actionTitles: ["Okay"], actions: [{ action1 in
            }])
        }
    }
    
    @IBAction func tncAction(_ sender: UIButton) {
        tncBtn.isSelected = !sender.isSelected
    }
}
