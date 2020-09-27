//
//  ScoreMO+CoreDataClass.swift
//  SportPot
//
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation
import CoreData

@objc(ScoreMO)
public class ScoreMO: NSManagedObject, Decodable {


    private enum CodingKeys: String, CodingKey {
        case halftime
        case fulltime
        case extratime
        case penalty
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Score", in: managedObjectContext) else {
                fatalError("Failed to decode Score")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        halftime = try container.decodeIfPresent(String.self, forKey: .halftime)
        fulltime = try container.decodeIfPresent(String.self, forKey: .fulltime)
        extratime = try container.decodeIfPresent(String.self, forKey: .extratime)
        penalty = try container.decodeIfPresent(String.self, forKey: .penalty)
    }
}
