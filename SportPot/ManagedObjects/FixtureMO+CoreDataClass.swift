//
//  FixtureMO+CoreDataClass.swift
//  
//
//  Created by Prajakta Ambekar on 25/09/2020.
//
//

import Foundation
import CoreData

@objc(FixtureMO)
public class FixtureMO: NSManagedObject, Decodable {
    var isDoubleDown: Bool = false
    var predictionType: PredictionType = .none
    var selectedPoints: Double = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case elapsed
        case event_date
        case event_timestamp
        case firstHalfStart
        case fixture_id
        case goalsAwayTeam
        case goalsHomeTeam
        case league_id
        case referee
        case round
        case secondHalfStart
        case status
        case statusShort
        case venue
        case awayTeam
        case homeTeam
        case league
        case score
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Fixture", in: managedObjectContext) else {
                fatalError("Failed to decode Fixtrure")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        elapsed = try container.decodeIfPresent(Int64.self, forKey: .elapsed) ?? 0
        event_date = try container.decodeIfPresent(String.self, forKey: .event_date)
        event_timestamp = try container.decodeIfPresent(Int64.self, forKey: .event_timestamp) ?? 0
        firstHalfStart = try container.decodeIfPresent(Int64.self, forKey: .firstHalfStart) ?? 0
        fixture_id = try container.decodeIfPresent(Int64.self, forKey: .fixture_id) ?? 0
        goalsAwayTeam = try container.decodeIfPresent(Int64.self, forKey: .goalsAwayTeam) ?? 0
        goalsHomeTeam = try container.decodeIfPresent(Int64.self, forKey: .goalsHomeTeam) ?? 0
        league_id = try container.decodeIfPresent(Int64.self, forKey: .league_id) ?? 0
        referee = try container.decodeIfPresent(String.self, forKey: .referee)
        round = try container.decodeIfPresent(String.self, forKey: .round)
        secondHalfStart = try container.decodeIfPresent(Int64.self, forKey: .secondHalfStart) ?? 0
        status = try container.decodeIfPresent(String.self, forKey: .status)
        statusShort = try container.decodeIfPresent(String.self, forKey: .statusShort)
        venue = try container.decodeIfPresent(String.self, forKey: .venue)
        awayTeam = try container.decodeIfPresent(TeamMO.self, forKey: .awayTeam)
        homeTeam = try container.decodeIfPresent(TeamMO.self, forKey: .homeTeam)
        league = try container.decodeIfPresent(LeagueMO.self, forKey: .league)
        score = try container.decodeIfPresent(ScoreMO.self, forKey: .score)
    }

}
