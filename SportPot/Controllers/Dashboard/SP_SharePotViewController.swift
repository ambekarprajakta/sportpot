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
        activityVC.title = "Share Pot"
        present(activityVC, animated: true, completion: nil)
    }
}
