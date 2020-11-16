//
//  SP_MyPotsTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 08/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_MyPotsTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayCell(potDetails: [String:Any]) {
        
        if let timeResult = (potDetails["createdOn"] as? String) {
            let date = Date(timeIntervalSince1970: Double(timeResult) ?? 0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            dateLabel.text = dateFormatter.string(from: date)
        }
        
        let joineeArr = potDetails["joinees"] as! Array<String>
        if  joineeArr.count > 1{
            detailLabel.text = "Bets places in English Premier League with " + joineeArr[1]
        }
//        detailLabel.text = potDetails["createdOn"] as! String
    }
}
