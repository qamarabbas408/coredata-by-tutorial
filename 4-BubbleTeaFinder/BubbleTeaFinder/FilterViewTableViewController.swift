//
//  FilterViewTableViewController.swift
//  BubbleTeaFinder
//
//  Created by Siliconplex on 25/10/2024.
//

import UIKit
import CoreData

protocol FilterViewControllerDelegate : AnyObject {
    func filterViewController(filter: FilterViewTableViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}

class FilterViewTableViewController: UITableViewController {
    @IBOutlet weak var firstPriceCategoryLabel: UILabel!
    @IBOutlet weak var secondPriceCategoryLabel: UILabel!
    @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
    @IBOutlet weak var numDealsLabel: UILabel!

    // MARK: - Price section
    @IBOutlet weak var cheapVenueCell: UITableViewCell!
    @IBOutlet weak var moderateVenueCell: UITableViewCell!
    @IBOutlet weak var expensiveVenueCell: UITableViewCell!

    // MARK: - Most popular section
    @IBOutlet weak var offeringDealCell: UITableViewCell!
    @IBOutlet weak var walkingDistanceCell: UITableViewCell!
    @IBOutlet weak var userTipsCell: UITableViewCell!
    
    // MARK: - Sort section
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    @IBOutlet weak var nameZASortCell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!
    
    weak var delegate :FilterViewControllerDelegate?
    var coreDataStack: CoreDataStack!
    
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    
    lazy var cheapVenuePredicate : NSPredicate = {
        return NSPredicate(format : "%K == %@", #keyPath(Venue.priceInfo.priceCategory),"$")
    }()

    
    lazy var moderateVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
    }()
    
    lazy var expensiveVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")}()
    
    lazy var offeringDealPredicate: NSPredicate = {
      return NSPredicate(format: "%K > 0",
        #keyPath(Venue.specialCount))
    }()
    
    lazy var walkingDistancePredicate: NSPredicate = {
        return NSPredicate(format: "%K < 500",
                           #keyPath(Venue.location.distance))
        
    }()
    
    lazy var hasUserTipsPredicate: NSPredicate = {
      return NSPredicate(format: "%K > 0",
        #keyPath(Venue.stats.tipCount))
    }()
    
    
    lazy var nameSortDescriptor: NSSortDescriptor = {
      let compareSelector =
        #selector(NSString.localizedStandardCompare(_:))
      return NSSortDescriptor(key: #keyPath(Venue.name),
                              ascending: true,
                              selector: compareSelector)
    }()
    
    
    lazy var distanceSortDescriptor: NSSortDescriptor = {
      return NSSortDescriptor(
        key: #keyPath(Venue.location.distance),
        ascending: true)
    }()
    
    
    lazy var priceSortDescriptor: NSSortDescriptor = {
      return NSSortDescriptor(
        key: #keyPath(Venue.priceInfo.priceCategory),
        ascending: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateCheapVenueCountLabel()
        populateModerateVenueCountLabel()
        populateExpensiveVenueCountLabel()
        populateDealsCountLabel()
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    
    @IBAction func filterAction(_ sender: Any) {
        delegate?.filterViewController(
          filter: self,
          didSelectPredicate: selectedPredicate,
          sortDescriptor: selectedSortDescriptor)
        dismiss(animated: true)
    }
 
}

//Table Functions
extension FilterViewTableViewController  {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
      return
      }
        switch cell {
            
        case nameAZSortCell:
          selectedSortDescriptor = nameSortDescriptor
        case nameZASortCell:
          selectedSortDescriptor =
            nameSortDescriptor.reversedSortDescriptor
            as? NSSortDescriptor
        case distanceSortCell:
          selectedSortDescriptor = distanceSortDescriptor
        case priceSortCell:
          selectedSortDescriptor = priceSortDescriptor
            
        case offeringDealCell:
          selectedPredicate = offeringDealPredicate
        case walkingDistanceCell:
          selectedPredicate = walkingDistancePredicate
        case userTipsCell:
          selectedPredicate = hasUserTipsPredicate
            
         case cheapVenueCell:
           selectedPredicate = cheapVenuePredicate
         case moderateVenueCell:
            selectedPredicate = moderateVenuePredicate
          case expensiveVenueCell:
            selectedPredicate = expensiveVenuePredicate
          default: break
          }
          cell.accessoryType = .checkmark
        
    }
}

//Helper Functions
extension FilterViewTableViewController {
    func populateCheapVenueCountLabel(){
        let fetchRequest =
           NSFetchRequest<NSNumber>(entityName: "Venue")
         fetchRequest.resultType = .countResultType
         fetchRequest.predicate = cheapVenuePredicate
        
        do {
              let countResult =
                try coreDataStack.managedContext.fetch(fetchRequest)
              let count = countResult.first?.intValue ?? 0
              let pluralized = count == 1 ? "place" : "places"
              firstPriceCategoryLabel.text =
                "\(count) bubble tea \(pluralized)"
            } catch let error as NSError {
              print("count not fetched \(error), \(error.userInfo)")
            }

    }
    
    func populateModerateVenueCountLabel() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = moderateVenuePredicate
        
        do {
            let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            secondPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
//    alternate way to fetch venu counts
    func populateExpensiveVenueCountLabel() {
        let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest.predicate = expensiveVenuePredicate
        
        do {
            let count = try coreDataStack.managedContext.count(for: fetchRequest)
            thirdPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    func populateDealsCountLabel() {
        
        //1
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
        fetchRequest.resultType = .dictionaryResultType
        
        //2
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumDeals"
        
        //3
        let specialCountExp = NSExpression(forKeyPath: #keyPath(Venue.specialCount))
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExp])
        sumExpressionDesc.expressionResultType = .integer32AttributeType
        
        //4
        fetchRequest.propertiesToFetch = [sumExpressionDesc]
        
        //5
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            let resultDict = results.first!
            let numDeals = resultDict["sumDeals"]!
            numDealsLabel.text = "\(numDeals) total deals"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
        
    }
}
