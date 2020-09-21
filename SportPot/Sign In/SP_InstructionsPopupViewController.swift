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
    override func viewDidLoad() {
        super.viewDidLoad()

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
