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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FixtureMO> {
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
    @NSManaged public var awayTeam: AwayTeamMO?
    @NSManaged public var homeTeam: HomeTeamMO?
    @NSManaged public var league: LeagueMO?
    @NSManaged public var score: ScoreMO?

}
