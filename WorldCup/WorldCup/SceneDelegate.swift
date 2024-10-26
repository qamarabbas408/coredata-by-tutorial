//
//  SceneDelegate.swift
//  WorldCup
//
//  Created by Siliconplex on 25/10/2024.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack(modelName: "WorldCup")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        importJSONSeedDataIfNeeded()

        
        guard let navController = window?.rootViewController as? UINavigationController,
              let viewController = navController.topViewController as? ViewController else {return }
        
        viewController.coreDataStack = coreDataStack
        
    }
    
    
    func importJSONSeedDataIfNeeded() {

      let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
      let count = try? coreDataStack.managedContext.count(for: fetchRequest)

      guard let teamCount = count,
        teamCount == 0 else {
          return
      }

      importJSONSeedData()
    }

    func importJSONSeedData() {

      let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
      let jsonData = try! Data(contentsOf: jsonURL)

      do {
        let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [[String: Any]]

        for jsonDictionary in jsonArray {
          let teamName = jsonDictionary["teamName"] as! String
          let zone = jsonDictionary["qualifyingZone"] as! String
          let imageName = jsonDictionary["imageName"] as! String
          let wins = jsonDictionary["wins"] as! NSNumber

          let team = Team(context: coreDataStack.managedContext)
          team.teamName = teamName
          team.imageName = imageName
          team.qualifyingZone = zone
          team.wins = wins.int32Value
        }

        coreDataStack.saveContext()
        print("Imported \(jsonArray.count) teams")

      } catch let error as NSError {
        print("Error importing teams: \(error)")
      }
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

