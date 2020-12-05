//
//  Prediction.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 29/11/20.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation

class Prediction: Codable {
    let selection: Int  // Away = 3, Draw = 2, Home = 1
    let isDoubleDown: Bool
    let fixtureId: Int
}
extension Prediction {
    
}
