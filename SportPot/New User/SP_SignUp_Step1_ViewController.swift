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
    
    
    // MARK: - Actions
    @IBAction func continueButtonAction(_ sender: Any) {
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Create the user
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            //Check for errors
            if err != nil {
                
                //There was an error
//                self.showError("Error creating user")
            }
            else {
                
                //User was created successfully, now store the first name and last name
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["name":name, "email":email, "uid": result!.user.uid ]) { (error) in
                    
                    if error != nil {
                        // Show error message
//                        self.showError("Error saving user data")
                        
                    }
                }
                print("User successfully created!")
                let signUp2VC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step2_ViewController") as!  SP_SignUp_Step2_ViewController
                           self.present(signUp2VC, animated: true, completion: nil)
            
                //Transition to the home screen
//                self.transitionToHome()
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
