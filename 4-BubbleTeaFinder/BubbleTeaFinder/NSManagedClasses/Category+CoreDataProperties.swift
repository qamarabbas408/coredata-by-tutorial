//
//  Category+CoreDataProperties.swift
//  BubbleTeaFinder
//
//  Created by Siliconplex on 24/10/2024.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryID: String?
    @NSManaged public var name: String?
    @NSManaged public var venue: Venue?

}

extension Category : Identifiable {

}
