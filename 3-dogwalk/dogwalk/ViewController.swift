//
//  ViewController.swift
//  dogwalk
//
//  Created by Siliconplex on 24/10/2024.
//

import UIKit
import CoreData
class ViewController: UIViewController {

    @IBOutlet weak var dogTitleLabel: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noWalksFoundLabel: UILabel!
    @IBOutlet weak var dogImageView: UIImageView!
    
    var walks : [NSDate] = []
    var currentDog : Dog?
    
    var showNoRecords :Bool {
        get {
            return self.noWalksFoundLabel.isHidden
        }
        set {
            return self.noWalksFoundLabel.isHidden = !newValue
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      formatter.timeStyle = .medium
      return formatter
    }()
    
    lazy var coreDataStack = CoreDataStack(modelName: "dogwalk")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self,forCellReuseIdentifier: "Cell")
        
        
        let dogName = "Fido"
        let dogFetchRequest : NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name),dogName)
        do{
            let results = try coreDataStack.managedContext.fetch(dogFetchRequest)
            if results.isEmpty {
                currentDog = Dog(context: coreDataStack.managedContext)
                currentDog?.name = dogName
                coreDataStack.saveContext()
            }else {
//                showNoRecords = false
                currentDog = results.first
            }
            
        }
        catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }

    @IBAction func addDogWalkTap(_ sender: Any) {
        
//        walks.append(NSDate())
        let walk = Walk(context: coreDataStack.managedContext)
        walk.date = Date()
        
//        if let dog = currentDog,
//           let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
//            walks.add(walk)
//            dog.walks = walks
//        }
        
        currentDog?.addToWalks(walk)
        
        coreDataStack.saveContext()
        
        tableView.reloadData()
    }
    
}


extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
  //    return names.count
//        return walks.count
        let count = currentDog?.walks?.count ?? 0
        showNoRecords = false
        if count == 0 {
            showNoRecords = true
        }
        
        return count
    }
    
     func tableView(_ tableView: UITableView,  cellForRowAt indexPath: IndexPath)-> UITableViewCell {
//          let person = person[indexPath.row]
          
          let cell =
          tableView.dequeueReusableCell(withIdentifier: "Cell",
                                        for: indexPath)
//         let walk = walks[indexPath.row]
//         cell.textLabel?.text = dateFormatter.string(from: walk as Date)
         
         guard let walk = currentDog?.walks?[indexPath.row] as? Walk , let walkDate = walk.date as Date? else {
             return cell
         }
        
         cell.textLabel?.text = dateFormatter.string(from: walkDate)
          return cell
          
      }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk, editingStyle == .delete else {
            return
        }
        coreDataStack.managedContext.delete(walkToRemove)
        coreDataStack.saveContext()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
    }
    
}
