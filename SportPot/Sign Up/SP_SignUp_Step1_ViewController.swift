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
    }
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        self.view.endEditing(true)
    //    }
    // MARK: - Validation
    func validateInput() -> Bool {
        //        if nameTextField.text?.isEmpty {
        //             return false
        //        }
        return true
    }
    func showSignupVCNotification() {
        let signUp1VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step1_ViewController") as!  SP_SignUp_Step1_ViewController
        self.present(signUp1VC, animated: true, completion: nil)
    }
    
    func checkUsernameAvailable(userName: String) {
        db.collection("user").getDocuments(completion: { (querySnapshot, error) in
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
    //    else{
    //                self.popupAlert(title: "Oops!", message: ErrorMessages.userNameExistsError, actionTitles: ["Close"], actions: [{ action1 in
    //    //                self.nameTextField.text = ""
    //                }])
    //            }
    // MARK: - Actions
    fileprivate func createUser() {
        let username = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Create the user
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            //Check for errors
            if err != nil {
                //There was an error
                self.popupAlert(title: "Oops!", message: err?.localizedDescription, actionTitles: ["Close"], actions: [{ action1 in
                    }])
            }else {
                //User was created successfully, now store the first name and last name
                self.db.collection("user").document(username).setData([
                    "id" : String((result?.user.uid)!),
                    "email":email,
                    "displayName" : username,
                    "points" : 0,
                    "joinedPots" : []
                ], merge: true){ (error) in
                    //If all good, proceed!
                    let signUp2VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step2_ViewController") as!  SP_SignUp_Step2_ViewController
                    signUp2VC.username = username
                    self.present(signUp2VC, animated: true, completion: nil)
                    print("User successfully created!")
                }
            }
        }
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
        //TODO: Uncomment this after testing
    checkUsernameAvailable(userName: nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
//        let signUp2VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step2_ViewController") as!  SP_SignUp_Step2_ViewController
//        self.present(signUp2VC, animated: true, completion: nil)
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
