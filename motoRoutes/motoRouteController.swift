//
//  motoRouteController.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 21.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class motoRouteController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // vars
    var fetchResultController:NSFetchedResultsController!
    var routes:[RouteCore] = [] // define restaurant core data empty array

    
    //Action methods
    @IBAction func close(segue:UIStoryboardSegue) {
        
    }
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // (1) Create a Dog object and then set its properties
//        let myDog = Dog()
//        myDog.name = "Rex6"
//        myDog.age = 8
//       
//        let myPerson = Person()
//        myPerson.name = "Haa"
//        
//        
//        // Get the default Realm
//        let realm = try! Realm()
//        // You only need to do this once (per thread)
//        
//        // Add to the Realm inside a transaction
//        try! realm.write {
//            realm.add(myDog)
//            realm.add(myPerson)
//        }
        
        // (2) Create a Dog object from a dictionary
        //let myOtherDog = Dog(value: ["name" : "Pluto", "age": 3])
        
        //// (3) Create a Dog object from an array
        //let myThirdDog = Dog(value: ["Fido", 5])

        
        
    }


    
    //
    // MARK: - Table view data source / Table rows and cells
    //
    
    // number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // number of rows
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return routes.count
    }
    
    // data for each table cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! motoRouteCellView
        
        let route = routes[indexPath.row]
        
        // Configure the cell...
        cell.distanceLabel.text = "Distance: \(route.distance)"
        
        return cell
    }

    
    
    
    
    
    
}
