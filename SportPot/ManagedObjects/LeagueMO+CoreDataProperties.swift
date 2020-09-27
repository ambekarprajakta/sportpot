//
//  League+CoreDataProperties.swift
//  SportPot
//
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation
import CoreData

extension LeagueMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LeagueMO> {
        return NSFetchRequest<LeagueMO>(entityName: "League")
    }

    @NSManaged public var name: String
    @NSManaged public var country: String
    @NSManaged public var logo: String?
    @NSManaged public var flag: String?

}
