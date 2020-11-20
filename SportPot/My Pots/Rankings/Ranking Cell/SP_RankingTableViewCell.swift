//
//  SP_RankingTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var doubleDownLabel: UILabel!
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
        
        if joineesArr[indexPath.row] != UserDefaults.standard.string(forKey: UserDefaultsConstants.currentUserKey)  {
            nameLabel.text = joineesArr[indexPath.row]
        }
        
    }
    
}
