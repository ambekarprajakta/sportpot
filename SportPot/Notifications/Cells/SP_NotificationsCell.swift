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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func display(notification: NotificationObject) {
        switch notification.notificationType {
        case .join:
            if notification.author ==  currentUser {
                titleLabel.text = "You have joined a pot!"
            } else {
                titleLabel.text = "Hey,\(notification.author) has joined the pot!"
            }
            break
        case .won:
            if notification.author ==  currentUser {
                titleLabel.text = "You won the pot!"
            } else {
                titleLabel.text = "\(notification.author) won the pot!"
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
        dateLabel.text =  date.stringTimeFromDate()
        
        if notification.isRead {
            newMessageLabel.isHidden = true
        } else {
            newMessageLabel.isHidden = false
        }
    }

}
