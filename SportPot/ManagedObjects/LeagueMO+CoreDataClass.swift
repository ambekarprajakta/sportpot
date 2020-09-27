//
//  LeagueMO+CoreDataClass.swift
//  SportPot
//
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation
import CoreData

@objc(LeagueMO)
public class LeagueMO: NSManagedObject, Decodable {

    private enum CodingKeys: String, CodingKey {
        case name
        case country
        case logo
        case flag
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "League", in: managedObjectContext) else {
                fatalError("Failed to decode League")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        flag = try container.decodeIfPresent(String.self, forKey: .flag)
    }

}
