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


class FirebaseData {
    
    static let dataService = FirebaseData()
    
    var r_ = RouteMaster()
    
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
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        print(userID)
        
        var routeKey = motoRoute._MotoRoute.id
        routeKey = routeKey.stringByReplacingOccurrencesOfString("#", withString: "-")
        print("ROUTEKEY: \(routeKey)")
        
        //add routeMaster data
        let motoRouteData: Dictionary<String, AnyObject> = [
            "firUID": keychain,
            "startLatitude": motoRoute._RouteList[0].latitude,
            "startLongitude": motoRoute._RouteList[0].longitude,
            "duration": motoRoute._MotoRoute.duration,
            "timestamp": motoRoute._MotoRoute.timestamp.timeIntervalSince1970,
            "locationStart": motoRoute._MotoRoute.locationStart,
            "locationEnd" : motoRoute._MotoRoute.locationEnd,
            "distance" : motoRoute._MotoRoute.distance
            ]
        childUpdatesFIR(FIR_ROUTES, key: String(routeKey), data: motoRouteData)

    
        //add all locations
        var locationAll = [String:[String:AnyObject]]()
        
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
            locationAll[String(key)] = location
        }
        
        childUpdatesFIR(FIR_LOCATIONS, key: String(routeKey), data: locationAll)
    }
    
    
    // firebase updates
    func childUpdatesFIR(refFIR: FIRDatabaseReference, key: String, data:  Dictionary<String, AnyObject>){
    
       refFIR.child("/\(key)").updateChildValues(data, withCompletionBlock: { (error, ref) in
            print("Locations done with it")
            if error != nil {
                print("error: \(error) - \(ref)")
            } else {
                print("ref: \(ref) - \(error)")
            }
        })
    }
    
    
    func deleteFIRChild(child: String){
        FIR_LOCATIONS.child("/\(child)").removeValue()
    }
    
    
    func getRoutesFromFIR(){
        
        FIR_ROUTES.observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            if let snap = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                var routes = [RouteMaster]()
                
                for item in snap {
                    
                    let newRoute = Route()
                    newRoute.id = item.key
                    
                    if let _startLat = item.value?["startLatitude"] as? Double {
                         newRoute.startLatitude = _startLat
                    }
                    
                    if let _startLong = item.value?["startLongitude"] as? Double {
                        newRoute.startLongitude = _startLong
                    }
                    
                    if let _duration = item.value?["duration"] as? Int {
                         newRoute.duration = _duration
                    }
                    
                    if let _distance = item.value?["distance"] as? Double {
                       newRoute.distance = _distance
                    }
                    
                    if let _locationStart = item.value?["locationStart"] as? String, _locationEnd = item.value?["locationEnd"] as? String {
                        newRoute.locationStart = _locationStart
                        newRoute.locationEnd = _locationEnd
                    }
                    
                    if let _timestamp = item.value?["timestamp"] as? Int {
                        newRoute.timestamp = NSDate(timeIntervalSinceReferenceDate: NSTimeInterval(_timestamp))
                    }

                    let newMaster = RouteMaster()
                    newMaster._MotoRoute = newRoute
                    routes.append(newMaster)
                }

                NSNotificationCenter.defaultCenter().postNotificationName(firbaseGetRoutesNotificationKey, object: routes)
            }
            // ...
        }) {
            (error) in
            print(error.localizedDescription)
        }
    }
    
    
    //get all locations from FIR by routeID and return [LocationMaster]
    func geLocationsRouteFIR(_RouteMaster: RouteMaster){
    
        let child = _RouteMaster._MotoRoute.id
        if  child.characters.count > 5 {
        
                FIR_LOCATIONS.child("/\(child)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let snap = snapshot.children.allObjects as? [FIRDataSnapshot] {

                    for item in snap {
                    
                        let newLocation = Location()
                        
                        if let _accuracy = item.value?["accuracy"] as? Double {
                            newLocation.accuracy = _accuracy
                        }
               
                        if let _altitude = item.value?["altitude"] as? Double {
                            newLocation.altitude = _altitude
                        }
                        
                        if let _course = item.value?["course"] as? Double {
                            newLocation.course = _course
                        }
                        
                        if let _distance = item.value?["distance"] as? Double {
                            newLocation.distance = _distance
                        }
                        
                        if let _latitude = item.value?["latitude"] as? Double {
                            newLocation.latitude = _latitude
                        }
                        
                        if let _longitude = item.value?["longitude"] as? Double {
                            newLocation.longitude = _longitude
                        }
                        
                        if let _speed = item.value?["speed"] as? Double {
                            newLocation.speed = _speed
                        }
                        
                        if let _timestamp = item.value?["timestamp"] as? Int {
                            newLocation.timestamp = NSDate(timeIntervalSinceReferenceDate: NSTimeInterval(_timestamp))
                        }
                        
                        //add all locations to route model as list
                        _RouteMaster._MotoRoute.locationsList.append(newLocation)
                    }
                    
                    //make locationMasters iut if list
                    _RouteMaster.associateRouteFIR()
                    
                    let returnObj = [_RouteMaster]
                    NSNotificationCenter.defaultCenter().postNotificationName(firbaseGetLocationsNotificationKey, object: returnObj)
                }
                
            // ...
        }) {
            (error) in
            print(error.localizedDescription)
            }
        }
}


}