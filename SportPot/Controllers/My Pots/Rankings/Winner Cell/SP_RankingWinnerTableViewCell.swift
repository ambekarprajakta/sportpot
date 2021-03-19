//
//  SP_RankingWinnerTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_RankingWinnerTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var accuracyButton: UIButton!
    @IBOutlet private weak var pointsButton: UIButton!
    @IBOutlet private weak var doubleDownButton: UIButton!
    let currentUser = UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? ""

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func display(joinee: Joinee, index: Int) {
        
        var displayName = "\(index). " + (joinee.displayName ?? "")
        if joinee.displayName ==  currentUser {
            displayName += " (you)"
        }
        nameLabel.text = displayName
        accuracyButton.setTitle(String(format: "%d%%", joinee.accuracy ?? 0), for: .normal)
        pointsButton.setTitle(String(format:"%d", joinee.pointsScored ?? 0), for: .normal)
        doubleDownButton.setTitle(String(format:"%d/3", joinee.doubleDown ?? 0), for: .normal)
    }

}
