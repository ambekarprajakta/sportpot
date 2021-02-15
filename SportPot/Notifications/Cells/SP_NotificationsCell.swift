//
//  SP_NotificationsCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 10/01/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_NotificationsCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var newMessageLabel: UILabel!
    let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""

    @IBOutlet weak var typeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func display(notification: NotificationObject) {
        switch notification.notificationType {
        case .join:
            typeImage.image = UIImage.init(named: "user-join-pot")
            if notification.author ==  currentUser {
                titleLabel.text = "You have joined a pot \(notification.potName ?? "LoL_PaRtyy!")!"
            } else {
                titleLabel.text = "\(notification.author) joined \(notification.potName ?? "LoL_PaRtyy!")!"
            }
            break
        case .won:
            typeImage.image = UIImage.init(named: "you-won-pot")
            if notification.author ==  currentUser {
                titleLabel.text = "You won the pot!"
            } else {
                titleLabel.text = "\(notification.author) won the pot \(notification.potName ?? "LoL_PaRtyy!")!"
            }
            break
        case .comment:
            titleLabel.text = "\(notification.author) commented on the pot"
            break
        case .invite:
            titleLabel.text = "\(notification.author) has been invited to the pot"
            break
        }
        let date = Date(timeIntervalSince1970: notification.timeStamp)
        dateLabel.text =  date.stringFromDate()
        
        if notification.isRead {
            newMessageLabel.isHidden = true
        } else {
            newMessageLabel.isHidden = false
        }
    }

}
