//
//  Pot.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 29/11/20.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation

class Pot: Codable {
    let potID: String
    let createdOn: String
    let owner: String
    let joinees: [Joinee]
    let round: String?
    var id: String? = nil
    let name: String
}
