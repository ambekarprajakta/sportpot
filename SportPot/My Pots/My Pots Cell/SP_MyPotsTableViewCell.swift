//
//  SP_MyPotsTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 08/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_MyPotsTableViewCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func display(pot: Pot) {
        let date = Date(timeIntervalSince1970: Double(pot.createdOn) ?? 0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        dateLabel.text = dateFormatter.string(from: date)

        let joinees = pot.joinees.map { (joinee) -> String in
            return joinee.joinee
        }

        if joinees.count >= 2 {
            if joinees.count == 2 {
                detailLabel.text = "Bets places in English Premier League with " + joinees[1]
            } else if joinees.count == 3 {
                detailLabel.text = "Bets places in English Premier League with " + joinees[1] + " & \(joinees.count - 2) other"
            } else {
                detailLabel.text = "Bets places in English Premier League with " + joinees[1] + " & \(joinees.count - 2) others"
            }
        } else {
            detailLabel.text = "Start betting in English Premier League with your friends! "
        }
    }
}
