//
//  Team+CoreDataProperties.swift
//  SportPot
//
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation
import CoreData

extension TeamMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMO> {
        return NSFetchRequest<TeamMO>(entityName: "Team")
    }

    @NSManaged public var team_id: Int64
    @NSManaged public var team_name: String
    @NSManaged public var logo: String?

}
