//
//  CoreDataStack.swift
//  BubbleTeaFinder
//
//  Created by Siliconplex on 24/10/2024.
//

import Foundation
import CoreData

class CoreDataStack {

  private let modelName: String

  init(modelName: String) {
    self.modelName = modelName
  }

  lazy var managedContext: NSManagedObjectContext = {
    return self.storeContainer.viewContext
  }()

  private lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
    

    

  func saveContext () {
    guard managedContext.hasChanges else { return }

    do {
      try managedContext.save()
    } catch {
      let nserror = error as NSError
      print("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
}
