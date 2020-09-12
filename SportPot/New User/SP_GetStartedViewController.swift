//
//  SP_GetStartedViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 03/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_GetStartedViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        signUpButton.layer.cornerRadius = signUpButton.frame.size.height/2
        signInButton.layer.cornerRadius = signInButton.frame.size.height/2
    }

     // MARK: - Button Actions
    
    @IBAction func signUpAction(_ sender: Any) {
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignUp_Step1_ViewController") as!  SP_SignUp_Step1_ViewController
        
        self.present(signUpVC, animated: true, completion: nil)
    }
    
    @IBAction func signInAction(_ sender: Any) {
        
        let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "SP_SignInViewController") as!  SP_SignInViewController
        
        self.present(signInVC, animated: true, completion: nil)
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
