//
//  FixtureMO+CoreDataClass.swift
//  
//
//  Created by Prajakta Ambekar on 25/09/2020.
//
//

import Foundation

struct FixtureModel: Codable {
    var isDoubleDown: Bool? = false
    var predictionType: PredictionType? = Optional.none
    var selectedPoints: Int? = 0
    
    let elapsed: Int64?
    let event_date: String?
    let event_timestamp: Int64
    let firstHalfStart: Int64?
    let fixture_id: Int64
    let goalsAwayTeam: Int64?
    let goalsHomeTeam: Int64?
    let league_id: Int64?
    let referee: String?
    let round: String?
    let secondHalfStart: Int64?
    let status: String?
    let statusShort: String?
    let venue: String?
    let awayTeam: TeamModel?
    let homeTeam: TeamModel?
    let league: LeagueModel?
    let score: ScoreModel?
    
    func isMatchFinished() -> Bool {
        return statusShort?.lowercased() == "ft"
    }
    
    func isMatchOnGoing() -> Bool {
        let onGoingStatuses = ["1H", "2H", "HT", "FT", "ET", "P", "AET", "PEN", "BT"]
        if let matchStatus = statusShort {
            return onGoingStatuses.contains(matchStatus)
        }
        return false
    }
}

/*
 TBD : Time To Be Defined
 NS : Not Started
 1H : First Half, Kick Off
 HT : Halftime
 2H : Second Half, 2nd Half Started
 ET : Extra Time
 P : Penalty In Progress
 FT : Match Finished
 AET : Match Finished After Extra Time
 PEN : Match Finished After Penalty
 BT : Break Time (in Extra Time)
 SUSP : Match Suspended
 INT : Match Interrupted
 PST : Match Postponed
 CANC : Match Cancelled
 ABD : Match Abandoned
 AWD : Technical Loss
 WO : WalkOver
 */
