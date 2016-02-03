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

class motoRouteController: UITableViewController {
    
    // realm object list
    var motoRoutes =  Results<Route>!()

    //Action methods
    @IBAction func close(segue:UIStoryboardSegue) {
        
        
        
    }
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the default Realm
        let realm = try! Realm()
        motoRoutes = realm.objects(Route)
        
        print(motoRoutes.count)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // [2]
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
          return motoRoutes.count
    }
    
    // data for each table cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! motoRouteCellView
        
        let route = motoRoutes[indexPath.row]
        
        // Configure the cell...
        cell.nameLabel.text = "Time: \(numberFormats.clockFormat(route.duration))"
        cell.distanceLabel.text = "Distance: \(route.distance)"
        
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRouteController" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! showRouteController
                destinationController.motoRoute = motoRoutes[indexPath.row]
            }
        }
    }
    
}
