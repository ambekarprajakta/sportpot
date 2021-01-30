//
//  Notification.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 10/01/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import Foundation

enum NotificationObjectType: String, Codable {
    case comment
    case invite
    case join
    case won
}

struct NotificationObject: Codable {
    let author: String
    let isRead: Bool
    let notificationType: NotificationObjectType
    let potId: String
    let timeStamp: Double
}
