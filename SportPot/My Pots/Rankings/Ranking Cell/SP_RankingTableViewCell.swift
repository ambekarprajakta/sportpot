//
//  SP_RankingTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_RankingTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var accuracyLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var doubleDownLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func display(joinee: Joinee) {
        nameLabel.text = joinee.joinee
        accuracyLabel.text = String(format: "%d", joinee.accuracy ?? 0)
        pointsLabel.text = String(format:"%.2f", joinee.pointsScored ?? 0)
        doubleDownLabel.text = String(format:"%d/3", joinee.doubleDown ?? 0)
    }

}
