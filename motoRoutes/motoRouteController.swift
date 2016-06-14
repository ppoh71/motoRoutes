//
//  motoRouteController.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 21.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//
//
//

import UIKit
import RealmSwift
import Crashlytics
import CoreLocation

class motoRouteController: UITableViewController {
    
    // realm object list
    var motoRoutes =  Results<Route>!(nil)


    //Action methods
    @IBAction func closeToMR(segue:UIStoryboardSegue) {
         print("close mc \(segue.sourceViewController)")
    }
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let realm = try! Realm()
        motoRoutes = realm.objects(Route).sorted("timestamp", ascending: false)
        
        print(realm)      
        print(motoRoutes.count)
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // [2]
    }

    override func viewDidAppear(animated: Bool) {
  
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MRCellView
        
        let route = motoRoutes[indexPath.row]
        
        //print(route)
        
        //get the stuff for the cell

        let imgName = route.image
        
        //let path = (utils.getDocumentsDirectory() as String) + img
        let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgName)
        let image = imageUtils.loadImageFromPath(imgPath)
        
        //image = (image == nil) ? "default.jpg" : image
        print(route.id)

        let nameLabel = "\(utils.clockFormat(route.duration))"
        let distanceLabel = "\(utils.distanceFormat(route.distance))"
        
        
        let from = CLLocationCoordinate2D(latitude: route.locationsList[0].latitude, longitude:route.locationsList[0].longitude)
        let to = CLLocationCoordinate2D(latitude: route.locationsList[route.locationsList.count-1].latitude, longitude: route.locationsList[route.locationsList.count-1].longitude)
        
        //configure cell
        cell.configureCell(nameLabel, distance: distanceLabel, image: image!, fromCoordinate: from, toCoordinate: to)
        
        return cell
    }
    
    
    /*
    * Swipe actions, delete share
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //delete routes
        if editingStyle == .Delete {
            print("deleting row \(motoRoutes[indexPath.row])")
            
            // Get the default Realm
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(motoRoutes[indexPath.row])
            }
            
            tableView.reloadData()
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRouteController" {
            
            let destinationController = segue.destinationViewController as! showRouteController
            
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationController.motoRoute = motoRoutes[indexPath.row]
                }           
        }
    }
    
}
