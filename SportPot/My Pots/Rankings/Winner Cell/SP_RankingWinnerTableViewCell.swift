//
//  SP_RankingWinnerTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_RankingWinnerTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accuracyButton: UIButton!
    @IBOutlet weak var pointsButton: UIButton!
    @IBOutlet weak var doubleDownButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func displayCell(data:[String:Any], indexPath: IndexPath) {
        guard let joineesArr = data["joinees"] as? Array<String> else { return }
        if indexPath.row == 0  {
            nameLabel.text = joineesArr[indexPath.row]
        }
        
    }
}
