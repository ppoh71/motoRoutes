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
//import SwiftKeychainWrapper
import Firebase


class motoRouteController: UITableViewController {
    
    var motoRoutes: Results<Route>!

    //Action methods
    @IBAction func closeToMR(_ segue:UIStoryboardSegue) {
         print("close mc \(segue.source)")
        segue.source.removeFromParentViewController()
    }
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
    
     
     //  let authKeychain = KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID)

        let realm = try! Realm()
        motoRoutes = realm.objects(Route.self).sorted(byProperty: "timestamp", ascending: false)
     
        print(realm)      

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // [2]
    }

    override func viewDidAppear(_ animated: Bool) {
     
     FIRAuth.auth()?.addStateDidChangeListener { auth, user in
          if let user = user {
               // User is signed in.
               print("user is logged in")
               print(user)
          } else {
               // No user is signed in.
                print("No user is logged in")
          }
     }
  
    }
    
    //
    // MARK: - Table view data source / Table rows and cells
    //
    
    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return motoRoutes.count
    }
    
    // data for each table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MRCellView
        
        let route = motoRoutes[indexPath.row]
        var image = UIImage()
     
     
        print(motoRoutes[indexPath.row].id)
        
        //get the stuff for the cell

        let imgName = route.image
     
          if(imgName.characters.count > 0){
             //let path = (utils.getDocumentsDirectory() as String) + img
             let imgPath = utils.getDocumentsDirectory().appendingPathComponent(imgName)
             image = imageUtils.loadImageFromPath(imgPath as NSString)!
          }
     
     
        //image = (image == nil) ? "default.jpg" : image
        print(route.id)

        let nameLabel = "\(utils.clockFormat(route.duration))"
        let distanceLabel = "\(utils.distanceFormat(route.distance))"
        
        
        //configure cell
        cell.configureCell(nameLabel, distance: distanceLabel, image: image, fromLocation: route.locationStart, toLocation: route.locationEnd)
        
        return cell
    }
    
    
    /*
    * Swipe actions, delete share
    */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete routes
        if editingStyle == .delete {
            print("deleting row \(motoRoutes[indexPath.row])")
            
            // Get the default Realm
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(motoRoutes[indexPath.row])
            }
            
            tableView.reloadData()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRouteController" {
            
            let destinationController = segue.destination as! showRouteController
            
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationController.motoRoute = motoRoutes[indexPath.row]
                }           
        }
    }
    
}
