//
//  SP_SignUpViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 03/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import MBProgressHUD

class SP_SignUp_Step1_ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: SP_UnderlinedTextField!
    
    @IBOutlet weak var emailTextField: SP_UnderlinedTextField!
    
    @IBOutlet weak var passwordTextField: SP_UnderlinedTextField!
    
    @IBOutlet weak var confirmPasswordTextField: SP_UnderlinedTextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.layer.cornerRadius = continueButton.frame.size.height/2
        passwordTextField.disableAutoFill()
        confirmPasswordTextField.disableAutoFill()
    }
    
    // MARK: - Validation
    
    func isValidInput() -> Bool {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            nameTextField.becomeFirstResponder()
             return false
        } else if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            emailTextField.becomeFirstResponder()
            return false
        } else if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            passwordTextField.becomeFirstResponder()
            return false
        } else if confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  == true {
            confirmPasswordTextField.becomeFirstResponder()
            return false
        }
        return true
    }
    func showSignupVCNotification() {
        let signUp1VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step1_ViewController") as!  SP_SignUp_Step1_ViewController
        self.present(signUp1VC, animated: true, completion: nil)
    }
    
    func checkUsernameAvailable(userName: String) {
        self.showHUD()
        db.collection("user").getDocuments(completion: { (querySnapshot, error) in
            self.hideHUD()
            guard let snapshot = querySnapshot else {
                print("Error retreiving documents \(error!)")
                return
            }
            for document in snapshot.documents{
                print(snapshot.documents)
                let displayName = document.data()["displayName"] as? String ?? ""
                let email = document.data()["email"] as? String ?? ""
                print("displayName: \(displayName), email: \(email)")
                if displayName == userName {
                    self.popupAlert(title: "Oops!", message: ErrorMessages.userNameExistsError, actionTitles: ["Close"], actions: [{ action1 in
                        self.nameTextField.becomeFirstResponder()
                        }])
                    return
                }
            }
            self.createUser()
        })
        
    }

    // MARK: - Actions
    
    func createUser() {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            //Check for errors
            if err != nil {
                //There was an error
                self.popupAlert(title: "Oops!", message: err?.localizedDescription, actionTitles: ["Close"], actions: [{ action1 in
                    }])
            }else {
                //User was created successfully, now store the first name and last name
                Firestore.firestore().collection("user").document(email).setData([
                    "id" : String((result?.user.uid)!)])
                self.step2VerifyPhoneNumber()
            }
        }
    }
    
    fileprivate func step2VerifyPhoneNumber() {
        let username = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let signUp2VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step2_ViewController") as!  SP_SignUp_Step2_ViewController
        signUp2VC.username = username
        signUp2VC.email = email
        signUp2VC.password = password
        self.present(signUp2VC, animated: true, completion: nil)
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
        //TODO: Uncomment this after testing
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.popupAlert(title: "Error", message: "Entered passwords do not match. Please try again later.", actionTitles: ["Close"], actions: [{ action1 in
                }])
        } else if isValidInput() {
            checkUsernameAvailable(userName: nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        } else {
            self.popupAlert(title: "Error", message: "Please check input fields and try again later.", actionTitles: ["Close"], actions: [{ action1 in
                }])
        }
    }
}

// MARK: - Extensions

extension SP_SignUp_Step1_ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
            confirmPasswordTextField.becomeFirstResponder()
        } else if confirmPasswordTextField.isFirstResponder {
            confirmPasswordTextField.resignFirstResponder()
            continueButtonAction(self)
        }
        return false
    }
}

extension UITextField {
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
