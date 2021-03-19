//
//  SP_InstructionsPopupViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 16/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

struct InstructionsConstants {
    static let select_three_dd = "Please make sure you've\nselected three\t"
    static let already_selected_three_dd = "You've already selected three\nmatches to Double Down\t"
    static let ten_matches = "You must place bets\non all matches"
    static let instructions_content = """
            1. Place your bet on all available matches\n
            2. Invite your friends to the pot\n
            3. Player with the most correct bets- wins!
            """
}

class SP_InstructionsPopupViewController: UIViewController {
    
    @IBOutlet weak var alertContainerView: UIView!
    @IBOutlet weak var popupTitleLabel: UILabel!
    @IBOutlet weak var popupDetailTextLabel: UILabel!
    @IBOutlet weak var alertIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertActionButton: UIButton!
    
    private var contentType: PopupType.ContentType = .Instruction
    
    //MARK:- Initializer
    
    static func newInstance(contentType: PopupType.ContentType) -> SP_InstructionsPopupViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instructionPopupVC = storyboard.instantiateViewController(identifier: String(describing: SP_InstructionsPopupViewController.self)) as SP_InstructionsPopupViewController
        instructionPopupVC.modalPresentationStyle = .overFullScreen
        instructionPopupVC.contentType = contentType
        return instructionPopupVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        alertContainerView.layer.cornerRadius = 15
        alertContainerView.layer.masksToBounds = true
        
        popupTitleLabel.attributedText = getTitleAttributedString()
        popupDetailTextLabel.attributedText = getDetailedAttributedString()
        
        alertActionButton.layer.cornerRadius = alertActionButton.bounds.height / 2
        alertActionButton.titleLabel?.attributedText = getAttributedStringForButton()
    }
    
    // MARK: - Button Actions
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Return Customized String
    
    private func getDetailedAttributedString() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.ubuntuRegularFont(ofSize: 14),
            .foregroundColor : UIColor.white,
            .paragraphStyle : paragraphStyle
        ]
        
        var attributedString = NSMutableAttributedString()
        
        switch contentType {
        case .SelectAtleastThreeDoubleDown, .AlreadySelectedThreeDoubleDown:
            let imageAttributedString = getAttributedStringWithImage(imageNamed: contentType == .SelectAtleastThreeDoubleDown ? "x2-selected" : "x2-selected", font: UIFont.ubuntuRegularFont(ofSize: 14))
            
            let content = contentType == .SelectAtleastThreeDoubleDown ? InstructionsConstants.select_three_dd : InstructionsConstants.already_selected_three_dd
            attributedString = NSMutableAttributedString(string: content)
            attributedString.append(imageAttributedString)
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
            
        case .BetTenMatches:
            attributedString = NSMutableAttributedString(string: InstructionsConstants.ten_matches)
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
            
        case .Instruction:
            paragraphStyle.alignment = .left
            paragraphStyle.headIndent = 12
            paragraphStyle.minimumLineHeight = 17
            paragraphStyle.maximumLineHeight = 17
            paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 14)]
            
            let content = InstructionsConstants.instructions_content
            attributedString = NSMutableAttributedString(string: content)
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
        }
        
        return attributedString
    }
    
    // MARK: - Attributed String
    
    private func getAttributedStringWithImage(imageNamed: String, font: UIFont) -> NSAttributedString {
        let image = UIImage(named: imageNamed)!
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: (font.capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        return NSAttributedString(attachment: imageAttachment)
    }
    
    private func getTitleAttributedString() -> NSAttributedString {
        let font = UIFont.ubuntuBoldFont(ofSize: 25)
        let attributes: [NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor : UIColor.white
        ]
        let titleText = contentType == .Instruction ? "Instructions" : "Oops!"
        let attributedString = NSMutableAttributedString(string: titleText, attributes: attributes)
        return attributedString
    }
    
    private func getAttributedStringForButton(buttonText: String = "Got it") -> NSAttributedString {
        let font = UIFont.ubuntuBoldFont(ofSize: 14)
        let attributes: [NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor : UIColor.black  //FIXME: - Put the exact color here
        ]
        let attributedString = NSMutableAttributedString(string: buttonText, attributes: attributes)
        return attributedString
    }
    
}
