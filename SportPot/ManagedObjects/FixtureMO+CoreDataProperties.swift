//
//  FixtureMO+CoreDataProperties.swift
//  
//
//  Created by Prajakta Ambekar on 25/09/2020.
//
//

import Foundation
import CoreData


extension FixtureMO {

    @nonobjc public static func fetchRequest() -> NSFetchRequest<FixtureMO> {
        return NSFetchRequest<FixtureMO>(entityName: "Fixture")
    }

    @NSManaged public var elapsed: Int64
    @NSManaged public var event_date: String?
    @NSManaged public var event_timestamp: Int64
    @NSManaged public var firstHalfStart: Int64
    @NSManaged public var fixture_id: Int64
    @NSManaged public var goalsAwayTeam: Int64
    @NSManaged public var goalsHomeTeam: Int64
    @NSManaged public var league_id: Int64
    @NSManaged public var referee: String?
    @NSManaged public var round: String?
    @NSManaged public var secondHalfStart: Int64
    @NSManaged public var status: String?
    @NSManaged public var statusShort: String?
    @NSManaged public var venue: String?
    @NSManaged public var awayTeam: TeamMO?
    @NSManaged public var homeTeam: TeamMO?
    @NSManaged public var league: LeagueMO?
    @NSManaged public var score: ScoreMO?

    func isMatchFinished() -> Bool {
        return statusShort?.lowercased() == "ft"
    }
    
    func isMatchOnGoing() -> Bool {
//        let negativeStatus = ["TBD","NS", "SUSP", "INT", "CANC", "ABD", "AWD", "WO"]
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
