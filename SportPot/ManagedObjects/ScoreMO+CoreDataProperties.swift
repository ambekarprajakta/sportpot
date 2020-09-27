//
//  Score+CoreDataProperties.swift
//  SportPot
//
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation
import CoreData

extension ScoreMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScoreMO> {
        return NSFetchRequest<ScoreMO>(entityName: "Score")
    }

    @NSManaged public var halftime: String?
    @NSManaged public var fulltime: String?
    @NSManaged public var extratime: String?
    @NSManaged public var penalty: String?

}
