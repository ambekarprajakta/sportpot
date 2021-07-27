//
//  FixturePoints.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 24/02/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import Foundation

struct FixturePoints: Codable {
    var home: Int
    var away: Int
    var draw: Int
    let fixtureId: Int
}

struct Value: Codable {
    var value: String
    let odd: Int
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        var value = try? container?.decodeIfPresent(String.self, forKey: .value)
        if value == nil {
            if let intValue = try? container?.decodeIfPresent(Int.self, forKey: .value) {
                value = "\(intValue)"
            }
        }
        if value != nil {
            self.value = value ?? ""
        } else {
            self.value = ""
        }
        if let oddValue = try? container?.decodeIfPresent(String.self, forKey: .odd),
           let doubleValue = Double(oddValue) {
            odd = Int(round(doubleValue * 100))
        } else {
            odd = 0
        }
    }
    
}

struct Bet: Codable {
    let labelName: String?
    let values: [Value]?
}

struct BookMaker: Codable {
    let bookmakerName: String
    let bets: [Bet]
}
