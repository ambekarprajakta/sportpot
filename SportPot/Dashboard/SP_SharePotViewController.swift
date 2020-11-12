//
//  SP_SharePotViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 20/10/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_SharePotViewController: UIViewController {

    @IBOutlet weak var linkLabel: UILabel!
    var linkString: String = ""
    @IBOutlet weak var copyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        linkLabel.text = linkString
        // Do any additional setup after loading the view.
    }
    
    @IBAction func copyToClipboard(_ sender: UIButton) {
        if !copyButton.isSelected {
            copyButton.isSelected = !sender.isSelected
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = linkString
        }
    }
    @IBAction func shareButtonAction(_ sender: Any) {
        let message = "Check out the pot I just created on Sportpot!"
        let activityVC = UIActivityViewController(activityItems: [message, linkString], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
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
