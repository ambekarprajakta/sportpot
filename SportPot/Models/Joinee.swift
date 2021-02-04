//
//  Joinee.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 29/11/20.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation

class Joinee: Codable {
    var joinee: String = ""
    var points: Double = 0
    var predictions: [Prediction] = []

    var accuracy: Int? = 0
    var pointsScored: Double? = 0
    var doubleDown: Int? = 0
    var winner: Bool? = false

    init() {
    }
}

extension Joinee: Equatable {
    static func == (lhs: Joinee, rhs: Joinee) -> Bool {
        return lhs.joinee == rhs.joinee
    }
}

extension Joinee: Hashable {
    var hashValue: Int {
        return joinee.hash
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(joinee)
    }
}

extension Joinee {

    func copy() -> Joinee {
        let joineeCopy = Joinee()
        joineeCopy.joinee = joinee
        joineeCopy.points = points
        joineeCopy.predictions = predictions

        joineeCopy.accuracy = accuracy
        joineeCopy.doubleDown = doubleDown
        joineeCopy.pointsScored = pointsScored
        joineeCopy.winner = winner

        return joineeCopy
    }

    func isWinner() -> Bool {
        return winner ?? false
    }

}
