//
//  BowTie+CoreDataProperties.swift
//  BowTies
//
//  Created by Siliconplex on 23/10/2024.
//
//

import Foundation
import CoreData
import UIKit


extension BowTie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BowTie> {
        return NSFetchRequest<BowTie>(entityName: "BowTie")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: Date?
    @NSManaged public var name: String?
    @NSManaged public var photoData: Data?
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var tintColor: UIColor?
    @NSManaged public var url: URL?

}

extension BowTie : Identifiable {

}
