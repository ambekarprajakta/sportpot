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
        guard let entity = NSEntityDescription.entity(forEntityName: "Score", in: CoreDataManager.sharedManager.persistentContainer.viewContext) else {
                fatalError("Failed to decode Score")
        }

        var context: NSManagedObjectContext?
        if let codingUserInfoKeyContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyContext] as? NSManagedObjectContext {
            context = managedObjectContext
        }

        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        halftime = try container.decodeIfPresent(String.self, forKey: .halftime)
        fulltime = try container.decodeIfPresent(String.self, forKey: .fulltime)
        extratime = try container.decodeIfPresent(String.self, forKey: .extratime)
        penalty = try container.decodeIfPresent(String.self, forKey: .penalty)
    }
}
