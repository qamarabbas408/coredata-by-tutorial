//
//  SceneDelegate.swift
//  BubbleTeaFinder
//
//  Created by Siliconplex on 24/10/2024.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var  coreDataStack = CoreDataStack(modelName: "BubbleTeaFinder")


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let navController = window?.rootViewController as? UINavigationController,
          let viewController = navController.topViewController as? ViewController else {
            return
        }
  
        viewController.coreDataStack = coreDataStack
        initJsonIfNeeded()
        
        guard let _ = (scene as? UIWindowScene) else { return }
  
        
    }
    
    
    func initJsonIfNeeded(){
          let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
          let count = try! coreDataStack.managedContext.count(for: fetchRequest)

          guard count == 0 else { return }
          
          do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            results.forEach({ coreDataStack.managedContext.delete($0) })
            coreDataStack.saveContext()
            importJSONSeedData()
          } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
          }
    }
    
    func importJSONSeedData(){
        
          let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
          let jsonData = try! Data(contentsOf: jsonURL)

          let jsonDict = try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: Any]
          let responseDict = jsonDict["response"] as! [String: Any]
          let jsonArray = responseDict["venues"] as! [[String: Any]]

        for jsonDictionary in jsonArray {
            let venueName = jsonDictionary["name"] as? String
            let contactDict = jsonDictionary["contact"] as! [String: String]
            
            let venuePhone = contactDict["phone"]
            
            let specialsDict = jsonDictionary["specials"] as! [String: Any]
            let specialCount = specialsDict["count"] as? NSNumber
            
            let locationDict = jsonDictionary["location"] as! [String: Any]
            let priceDict = jsonDictionary["price"] as! [String: Any]
            let statsDict =  jsonDictionary["stats"] as! [String: Any]
            
            let location = Location(context: coreDataStack.managedContext)
            location.address = locationDict["address"] as? String
            location.city = locationDict["city"] as? String
            location.state = locationDict["state"] as? String
            location.zipcode = locationDict["postalCode"] as? String
            let distance = locationDict["distance"] as? NSNumber
            location.distance = distance!.floatValue
            
            let category = Category(context: coreDataStack.managedContext)
            
            let priceInfo = PriceInfo(context: coreDataStack.managedContext)
            priceInfo.priceCategory = priceDict["currency"] as? String
            
            let stats = Stats(context: coreDataStack.managedContext)
            let checkins = statsDict["checkinsCount"] as? NSNumber
            stats.checkinsCount = checkins!.int32Value
            let tipCount = statsDict["tipCount"] as? NSNumber
            stats.tipCount = tipCount!.int32Value
            
            let venue = Venue(context: coreDataStack.managedContext)
            venue.name = venueName
            venue.phone = venuePhone
            venue.specialCount = specialCount!.int32Value
            venue.location = location
            venue.category = category
            venue.priceInfo = priceInfo
            venue.stats = stats
        }
        
        coreDataStack.saveContext()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

