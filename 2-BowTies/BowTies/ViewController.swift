//
//  ViewController.swift
//  BowTies
//
//  Created by Siliconplex on 23/10/2024.
//

import UIKit
import CoreData
class ViewController: UIViewController {

    @IBOutlet weak var noResultsFoundView: UIView!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var tieWearCount: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var tieNameLabel: UILabel!
    @IBOutlet weak var tieImageView: UIImageView!
    @IBOutlet weak var lastWearDate: UILabel!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    var currentBowTie : BowTie!
    var managedContext: NSManagedObjectContext!
    let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
    
//    var showNoResultFoundView:Bool = false {
//        didSet  {
//            self.noResultsFoundView.isHidden = false
//        }
//    }
    
    var showNoResultFoundView: Bool {
        get {
            return self.noResultsFoundView.isHidden
        }
        set {
                self.noResultsFoundView.isHidden = !newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate?.persistentContainer.viewContext
        
        insertSampleData()
        
        let request : NSFetchRequest<BowTie> = BowTie.fetchRequest()
        let firstTitle = segmentController.titleForSegment(at: 0) ?? ""
        
//        let firstLetter = segmentController.titleForSegment(at: 0)!.first ?? "R"
//        print("Selected Segment Letter === \(firstLetter)")
        
        
        request.predicate = NSPredicate (
            format: "%K = %@", argumentArray: [#keyPath(BowTie.searchKey), firstTitle]
        )
        
        do{
            let results = try managedContext.fetch(request)
            if(results.isEmpty) {
                self.showNoResultFoundView = true
            }
            if let tie = results.first{
                currentBowTie = tie
                populate(bowtie:tie)
                self.showNoResultFoundView = false
            }
        }catch let error as NSError {
            print("Could not fetch \(error) , \(error.userInfo)")
        }
        
        
    }
    
    func populate( bowtie : BowTie) {
        guard let imageData = bowtie.photoData as Data?,
            let lastWorn = bowtie.lastWorn as Date?,
              let tintColor = bowtie.tintColor else {
            return
        }
        
        tieImageView.image = UIImage(data: imageData)
        tieNameLabel.text = bowtie.name
        ratingLabel.text = "Rating: \(bowtie.rating)/5"
        tieWearCount.text = "# times worn: \(bowtie.timesWorn)"
        
          let dateFormatter = DateFormatter()
          dateFormatter.dateStyle = .short
          dateFormatter.timeStyle = .none
        
        lastWearDate.text =
            "Last worn: " + dateFormatter.string(from: lastWorn)
        
          favoriteLabel.isHidden = !bowtie.isFavorite
          view.tintColor = tintColor
    }
    
    
    
    func insertSampleData(){
        let fetch:NSFetchRequest<BowTie> = BowTie.fetchRequest()
        fetch.predicate = NSPredicate(format: "searchKey != nil")
        let tieCount = (try? managedContext.count(for: fetch)) ?? 0
        if tieCount > 0 {
//            Sample Data already in CoreData
            return
        }
        
        let dataArray = NSArray(contentsOfFile: path!)!
        
        let _ = dataArray.map {
            dict in
            let entity = NSEntityDescription.entity(
                  forEntityName: "BowTie",
                  in: self.managedContext)!
            
            let btDict = dict as! [String: Any]
            
            let bowtie = BowTie(entity: entity, insertInto: managedContext)
            bowtie.id = UUID(uuidString: btDict["id"] as! String)
               bowtie.name = btDict["name"] as? String
               bowtie.searchKey = btDict["searchKey"] as? String
               bowtie.rating = btDict["rating"] as! Double
               let colorDict = btDict["tintColor"] as! [String: Any]
               bowtie.tintColor = UIColor.color(dict: colorDict)
               let imageName = btDict["imageName"] as? String
               let image = UIImage(named: imageName!)
               bowtie.photoData = image?.pngData()
               bowtie.lastWorn = btDict["lastWorn"] as? Date
               let timesNumber = btDict["timesWorn"] as! NSNumber
               bowtie.timesWorn = timesNumber.int32Value
               bowtie.isFavorite = btDict["isFavorite"] as! Bool
               bowtie.url = URL(string: btDict["url"] as! String)
            
            
            
        }
        try? managedContext.save()
    }

    
    @IBAction func onSegmentValueChanged(_ sender: UISegmentedControl) {
        guard let selectedSegment = sender.titleForSegment(at: sender.selectedSegmentIndex) else {
                 return
             }
        let request : NSFetchRequest<BowTie> = BowTie.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@" ,
                                        argumentArray: [#keyPath(BowTie.searchKey),selectedSegment]
        )
        do {
            let results = try managedContext.fetch(request)
            if (results.isEmpty) {
                print("No Results Found");
                self.showNoResultFoundView = true
                return
            }
            self.showNoResultFoundView = false
            currentBowTie = results.first
            populate(bowtie: currentBowTie)
        }
        catch let error as NSError {
            print("Could not Fetch \(error), \(error.userInfo)")

        }
        
    }

    
    @IBAction func tapAddRating(_ sender: Any) {
//        currentBowTie.rating += 1
        let alert = UIAlertController(title: "New Rating",
                                      message: "Rate this bow tie",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
          textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                          style: .cancel)
        
        let saveAction = UIAlertAction(
            title: "Save", style: .default) {
                [unowned self]
                _ in
                if let textfield = alert.textFields?.first {
                    update(rating: textfield.text)
                }
            }
        
            alert.addAction(cancelAction)
         alert.addAction(saveAction)
         present(alert, animated: true)
        
    }
    
    func update(rating: String? ) {
        guard let ratingString = rating, let rating = Double(ratingString) else {return}
        do {
            currentBowTie.rating = rating
            try managedContext.save()
            populate(bowtie: currentBowTie)
        }catch let error as NSError {
            if error.domain == NSCocoaErrorDomain &&
                 (error.code == NSValidationNumberTooLargeError ||
                   error.code == NSValidationNumberTooSmallError) {
                tapAddRating(currentBowTie!)
           } else {
                 print("Could not save \(error), \(error.userInfo)")
               }
            
            
//            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func tapAddTieWear(_ sender: Any) {
        currentBowTie.timesWorn += 1
        currentBowTie.lastWorn = Date()
        do {
            try managedContext.save()
            populate(bowtie: currentBowTie)
        }catch let error as NSError {
            print("Could not fetch \(error) , \(error.userInfo)")
        }
    }
}

private extension UIColor {
  static func color(dict: [String: Any]) -> UIColor? {
    guard
      let red = dict["red"] as? NSNumber,
      let green = dict["green"] as? NSNumber,
      let blue = dict["blue"] as? NSNumber else {
return nil
}
    return UIColor(
      red: CGFloat(truncating: red) / 255.0,
      green: CGFloat(truncating: green) / 255.0,
      blue: CGFloat(truncating: blue) / 255.0,
      alpha: 1)
} }
