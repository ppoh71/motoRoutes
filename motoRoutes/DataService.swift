//
//  DataService.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import Firebase

let FIR_DB = FIRDatabase.database().reference()


class DataService {
    
    static let dataService = DataService()
    
    private var _REF_BASE = FIR_DB
    private var _REF_ROUTES = FIR_DB.child("motoRoutes")
    private var _REF_LOCATIONS = FIR_DB.child("Locations")
    
    var REF_Base: FIRDatabaseReference{
        return _REF_BASE
    }
    
    var FIR_ROUTES: FIRDatabaseReference{
        return _REF_ROUTES
    }
    
    var FIR_LOCATIONS: FIRDatabaseReference{
        return _REF_LOCATIONS
    }

    
    func addRouteToFIR(motoRoute: RouteMaster, keychain: String) {
    
        //let locationKey = FIR_ROUTES.child("Locations").childByAutoId().key
        //let motoRouteKey = FIR_ROUTES.child("motoRoutes").childByAutoId().key
        
        let routeKey = motoRoute._MotoRoute.id
        
        //routeMaster data
        let motoRouteData: Dictionary<String, AnyObject> = [
            "firUID": keychain,
            "startLatitude": motoRoute._RouteList[0].latitude,
            "startLongitude": motoRoute._RouteList[0].longitude,
            "duration": motoRoute._MotoRoute.duration,
            "timestamp": motoRoute._MotoRoute.timestamp.timeIntervalSince1970,
            "locationStart": motoRoute._MotoRoute.locationStart,
            "locationEnd" : motoRoute._MotoRoute.locationEnd,
        ]
        
        //add routeMaster
        FIR_ROUTES.child(routeKey).updateChildValues(motoRouteData)
        
        //add all locations
        for (key,item) in motoRoute._RouteList.enumerate() {

            let location: Dictionary<String, AnyObject> = [
                        "latitude": item.latitude,
                        "longitude": item.longitude,
                        "altitude" : item.altitude,
                        "speed" : item.speed,
                        "course" : item.course,
                        "accuracy" : item.accuracy,
                        "distance" : item.distance,
                        "timestamp" : item.timestamp.timeIntervalSince1970,
                ]

             FIR_LOCATIONS.child("/\(routeKey)/\(key)").updateChildValues(location)
        }
    }
    
    func getRoutesFromFIR(){
    
        let userID = FIRAuth.auth()?.currentUser?.uid
        FIR_ROUTES.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            
            print(snapshot)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}