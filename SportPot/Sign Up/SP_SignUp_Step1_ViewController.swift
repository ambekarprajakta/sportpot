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
                //self.showError("Error creating user")
            }
            else {
                
                //User was created successfully, now store the first name and last name
                let db = Firestore.firestore()
                db.collection("user").document(String((result?.user.uid)!)).setData([
                    "id" : String((result?.user.uid)!),
                    "email":email,
                    "displayName" : username,
                    "points" : 0
                ], merge: true){ (error) in
                    
                    print("User successfully created!")

                }
            }
        }
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
        createUser()
        let signUp2VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step2_ViewController") as!  SP_SignUp_Step2_ViewController
        self.present(signUp2VC, animated: true, completion: nil)
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
