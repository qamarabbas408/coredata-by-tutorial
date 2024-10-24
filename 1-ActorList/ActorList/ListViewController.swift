//
//  ViewController.swift
//  ActorList
//
//  Created by Siliconplex on 23/10/2024.
//

import UIKit
import CoreData
class ListViewController: UIViewController {
    @IBOutlet weak var tableListView: UITableView!
    var names: [String] = []
    var person : [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "The List"
        tableListView.register(UITableViewCell.self,forCellReuseIdentifier: "Cell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
    //1
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
    return
    }
        
      let managedContext =
        appDelegate.persistentContainer.viewContext
        
    //2
      let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Person")
        
    //3
      do {
        person = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }


    @IBAction func addName(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) {_ in 
            
            guard let textField = alert.textFields?.first,let nameToSave = textField.text else {
                return
            }
            
            
//            self.names.append(nameToSave)
            self.save(name: nameToSave)
            self.tableListView.reloadData()
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func save(name: String) {
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
    return
    }
 
      let managedContext =
        appDelegate.persistentContainer.viewContext

      let entity =
        NSEntityDescription.entity(forEntityName: "Person",
                                   in: managedContext)!
        
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
    // 3
      person.setValue(name, forKeyPath: "name")
    // 4
      do {
        try managedContext.save()
        self.person.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
}

extension ListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
//    return names.count
      return person.count
  }
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let person = person[indexPath.row]
        
        let cell =
        tableView.dequeueReusableCell(withIdentifier: "Cell",
                                      for: indexPath)
        
//        cell.textLabel?.text = names[indexPath.row]
        cell.textLabel?.text =
            person.value(forKeyPath: "name") as? String
        
        return cell
        
        
        
        
    }
}
