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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func display(joinee: Joinee) {
        nameLabel.text = joinee.joinee
        accuracyButton.setTitle(String(format: "%.2f", joinee.accuracy ?? 0), for: .normal)
        pointsButton.setTitle(String(format:"%.2f", joinee.points ), for: .normal)
        doubleDownButton.setTitle(String(format:"%d/3", Int(joinee.doubleDown ?? 0)), for: .normal)
    }

}
