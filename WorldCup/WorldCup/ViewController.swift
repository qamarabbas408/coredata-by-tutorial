//
//  ViewController.swift
//  WorldCup
//
//  Created by Siliconplex on 25/10/2024.
//

import UIKit
import CoreData

class ViewController: UIViewController {
   
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var coreDataStack : CoreDataStack! 
    fileprivate let teamCellIdentifier = "Cell"

    lazy var fetchedResultsController: NSFetchedResultsController<Team> = {
        //1
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        
        let sort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
        
        let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
        
        let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
        
        let nameSort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
        
//        fetchRequest.sortDescriptors = [sort]
//        fetchRequest.sortDescriptors = [scoreSort]
        fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort]

        //2
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: #keyPath(Team.qualifyingZone), cacheName: "WorldCup")
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addButton.isEnabled = false 
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
    }

    @IBAction func addAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Secret Team", message: "Add a new team", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Team Name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Qualifying Zone"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self](action) in
            guard let nameTextField = alert.textFields?.first, let zoneTextField = alert.textFields?.last else {
                return
            }
            
            let team = Team(context: self.coreDataStack.managedContext)
            
            team.teamName = nameTextField.text
            team.qualifyingZone = zoneTextField.text
            team.imageName = "wenderland-flag"
            self.coreDataStack.saveContext()
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            addButton.isEnabled = true
        }
    }
    
    
}

//helper
extension ViewController {
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {

      guard let cell = cell as? TeamTableViewCell else {
        return
      }

  //    cell.flagImageView.backgroundColor = .blue
  //    cell.teamLabel.text = "Team Name"
  //    cell.scoreLabel.text = "Wins: 0"
          
          let team = fetchedResultsController.object(at: indexPath)
          cell.teamLabel.text = team.teamName
          cell.scoreLabel.text = "Wins: \(team.wins)"
          
          if let imageName = team.imageName {
              cell.flagImageView.image = UIImage(named: imageName)
          } else {
              cell.flagImageView.image = nil
          }
          
    }
}

extension ViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
          
          guard let sections = fetchedResultsController.sections else {
              return 0
          }
          
      return sections.count
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
    return sectionInfo.numberOfObjects
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        
        return sectionInfo?.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

      let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
      configure(cell: cell, for: indexPath)
      return cell
    }
//    
//    func tableView(_ tableView: UITableView,
//                   didSelectRowAt indexPath: IndexPath) {
//      let team = fetchedResultsController.object(at: indexPath)
//      team.wins += 1
//      coreDataStack.saveContext()
//    tableView.reloadData()
//    }
//    
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = fetchedResultsController.object(at: indexPath)
        team.wins = team.wins + 1
        coreDataStack.saveContext()
//        tableView.reloadData()
  }
}

extension ViewController :  NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! TeamTableViewCell
            configure(cell: cell, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        @unknown default:
            fatalError("Error")
        }
        
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.reloadData()
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
        
    }
}
