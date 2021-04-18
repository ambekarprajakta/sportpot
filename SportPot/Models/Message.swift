//
//  Message.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 20/03/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import Foundation
import MessageKit

struct Message: Decodable, MessageType {
    
//    let potId: String
    let content: String
    let timeStamp: Double
    let displayName: String

    var messageId: String {
        return "\(sentDate)"
    }

    var kind: MessageKind {
        return .text(content)
    }
    
    var sentDate: Date {
        return Date(timeIntervalSince1970: timeStamp)
    }

    var sender: SenderType {
        return User(id: displayName, name: displayName)
    }
}

struct User: SenderType {
    let id: String
    let name: String

    var senderId: String {
        return id
    }

    var displayName: String {
        return name
    }
}
