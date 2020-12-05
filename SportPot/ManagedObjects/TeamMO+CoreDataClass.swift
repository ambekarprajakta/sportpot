//
//  TeamMO+CoreDataClass.swift
//  SportPot
//
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation
import CoreData

@objc(TeamMO)
public class TeamMO: NSManagedObject, Decodable {

    private enum CodingKeys: String, CodingKey {
        case team_id
        case team_name
        case logo
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Team", in: CoreDataManager.sharedManager.persistentContainer.viewContext) else {
                fatalError("Failed to decode Team")
        }

        var context: NSManagedObjectContext?
        if let codingUserInfoKeyContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyContext] as? NSManagedObjectContext {
            context = managedObjectContext
        }

        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        team_id = try container.decodeIfPresent(Int64.self, forKey: .team_id) ?? 0
        team_name = try container.decodeIfPresent(String.self, forKey: .team_name) ?? ""
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
    }

}
