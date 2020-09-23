//
//  SP_InstructionsPopupViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 16/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_InstructionsPopupViewController: UIViewController {

    @IBOutlet weak var popupTitleLabel: UILabel!
    @IBOutlet weak var popupDetailTextLabel: UILabel!
    private var alertTitle: String?
    private var alertMessage: String?

    static func newInstance(title: String? = nil, message: String? = nil) -> SP_InstructionsPopupViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instructionPopupVC = storyboard.instantiateViewController(identifier: String(describing: SP_InstructionsPopupViewController.self)) as SP_InstructionsPopupViewController
        instructionPopupVC.modalPresentationStyle = .overCurrentContext
        instructionPopupVC.alertTitle = title ?? "Oops!"
        instructionPopupVC.alertMessage = message ?? "Something went wrong and we are looking into it. Please come back later."
        return instructionPopupVC
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popupTitleLabel.text = alertTitle
        popupDetailTextLabel.text = alertMessage
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func showPopupfor(viewcontroller: UIViewController, type: PopupType.ContentType) {
        if viewcontroller .isKind(of: SP_HomeViewController.self) && type == PopupType.ContentType.BetTenMatches  {
            self.popupTitleLabel.text = "Oops!"
            self.popupDetailTextLabel.text = "You must place bets on all 10 matches"
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
