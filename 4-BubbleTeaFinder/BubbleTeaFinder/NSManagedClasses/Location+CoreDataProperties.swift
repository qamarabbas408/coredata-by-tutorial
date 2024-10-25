//
//  Location+CoreDataProperties.swift
//  BubbleTeaFinder
//
//  Created by Siliconplex on 24/10/2024.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var address: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var distance: Float
    @NSManaged public var state: String?
    @NSManaged public var zipcode: String?
    @NSManaged public var venue: Venue?

}

extension Location : Identifiable {

}
