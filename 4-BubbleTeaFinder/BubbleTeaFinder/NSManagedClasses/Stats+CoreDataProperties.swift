//
//  Stats+CoreDataProperties.swift
//  BubbleTeaFinder
//
//  Created by Siliconplex on 24/10/2024.
//
//

import Foundation
import CoreData


extension Stats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: "Stats")
    }

    @NSManaged public var checkinsCount: Int32
    @NSManaged public var tipCount: Int32
    @NSManaged public var usersCount: Int32
    @NSManaged public var venue: Venue?

}

extension Stats : Identifiable {

}
