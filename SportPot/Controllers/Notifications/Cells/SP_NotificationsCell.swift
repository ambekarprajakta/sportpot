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
    let currentUser = UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? ""

    @IBOutlet weak var typeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func display(notification: NotificationObject) {
        let defaultPotName = "TEST🍯"
        switch notification.notificationType {
        case .join:
            typeImage.image = UIImage.init(named: "user-join-pot")
            if notification.author ==  currentUser {
                titleLabel.text = "You have joined \(notification.potName ?? defaultPotName)!"
            } else {
                titleLabel.text = "\(notification.author) joined \(notification.potName ?? defaultPotName)!"
            }
            break
        case .won:
            if notification.author.contains(currentUser)  {
                typeImage.image = UIImage.init(named: "you-won-pot")
                titleLabel.text = "🏅You won the pot - \(notification.potName ?? defaultPotName)!"
            } else {
                typeImage.image = UIImage.init(named: "lost-pot")
                titleLabel.text = "\(notification.author) won the pot - \(notification.potName ?? defaultPotName)!"
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
