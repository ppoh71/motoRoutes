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
    
    fileprivate var _REF_BASE = FIR_DB
    fileprivate var _REF_ROUTES = FIR_DB.child("motoRoutes")
    fileprivate var _REF_LOCATIONS = FIR_DB.child("Locations")
    
    var REF_Base: FIRDatabaseReference{
        return _REF_BASE
    }
    
    var FIR_ROUTES: FIRDatabaseReference{
        return _REF_ROUTES
    }
    
    var FIR_LOCATIONS: FIRDatabaseReference{
        return _REF_LOCATIONS
    }
    
    
    func addRouteToFIR(_ motoRoute: RouteMaster, keychain: String) {
        
        //let locationKey = FIR_ROUTES.child("Locations").childByAutoId().key
        //let motoRouteKey = FIR_ROUTES.child("motoRoutes").childByAutoId().key
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        print(userID ?? "no userifd")
        
        var routeKey = motoRoute._MotoRoute.id
        routeKey = routeKey.replacingOccurrences(of: "#", with: "-")
        print("ROUTEKEY: \(routeKey)")
        
        //add routeMaster data
        let motoRouteData: Dictionary<String, AnyObject> = [
            "firUID": keychain as AnyObject,
            "startLatitude": motoRoute._RouteList[0].latitude as AnyObject,
            "startLongitude": motoRoute._RouteList[0].longitude as AnyObject,
            "duration": motoRoute._MotoRoute.duration as AnyObject,
            "timestamp": motoRoute._MotoRoute.timestamp.timeIntervalSince1970 as AnyObject,
            "locationStart": motoRoute._MotoRoute.locationStart as AnyObject,
            "locationEnd" : motoRoute._MotoRoute.locationEnd as AnyObject,
            "distance" : motoRoute._MotoRoute.distance as AnyObject
            ]
        childUpdatesFIR(FIR_ROUTES, key: String(routeKey), data: motoRouteData)

    
        //add all locations
        var locationAll = [String:[String:AnyObject]]()
        
        for (key,item) in motoRoute._RouteList.enumerated() {
            let location: Dictionary<String, AnyObject> = [
                
                "latitude": item.latitude as AnyObject,
                "longitude": item.longitude as AnyObject,
                "altitude" : item.altitude as AnyObject,
                "speed" : item.speed as AnyObject,
                "course" : item.course as AnyObject,
                "accuracy" : item.accuracy as AnyObject,
                "distance" : item.distance as AnyObject,
                "timestamp" : item.timestamp.timeIntervalSince1970 as AnyObject,
                ]
            locationAll[String(key)] = location
        }
        
        childUpdatesFIR(FIR_LOCATIONS, key: String(routeKey), data: locationAll as Dictionary<String, AnyObject>)
    }
    
    
    // firebase updates
    func childUpdatesFIR(_ refFIR: FIRDatabaseReference, key: String, data:  Dictionary<String, AnyObject>){
    
       refFIR.child("/\(key)").updateChildValues(data, withCompletionBlock: { (error, ref) in
            print("Locations done with it")
            if error != nil {
                print("error: \(error) - \(ref)")
            } else {
                print("ref: \(ref) - \(error)")
            }
        })
    }
    
    
    func deleteFIRChild(_ child: String){
        FIR_LOCATIONS.child("/\(child)").removeValue()
    }
    
    
    func getRoutesFromFIR(){
        
        FIR_ROUTES.observeSingleEvent(of: .value, with: { (snapshot) in

            if let snap = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                var routes = [RouteMaster]()
                
                for item in snap {
                    
                    let newRoute = Route()
                    newRoute.id = item.key
                    
                    let snapshotValue = item.value as? NSDictionary
                    
                    if let _startLat = snapshotValue?["startLatitude"] as? Double {
                         newRoute.startLatitude = _startLat
                    }
                    
                    if let _startLong = snapshotValue?["startLongitude"] as? Double {
                        newRoute.startLongitude = _startLong
                    }
                    
                    if let _duration = snapshotValue?["duration"] as? Int {
                         newRoute.duration = _duration
                    }
                    
                    if let _distance = snapshotValue?["distance"] as? Double {
                       newRoute.distance = _distance
                    }
                    
                    if let _locationStart = snapshotValue?["locationStart"] as? String, let _locationEnd = snapshotValue?["locationEnd"] as? String {
                        newRoute.locationStart = _locationStart
                        newRoute.locationEnd = _locationEnd
                    }
                    
                    if let _timestamp = snapshotValue?["timestamp"] as? Int {
                        newRoute.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(_timestamp))
                    }

                    let newMaster = RouteMaster()
                    newMaster._MotoRoute = newRoute
                    routes.append(newMaster)
                }

                NotificationCenter.default.post(name: Notification.Name(rawValue: firbaseGetRoutesNotificationKey), object: routes)
            }
            // ...
        }) {
            (error) in
            print(error.localizedDescription)
        }
    }
    
    
    //get all locations from FIR by routeID and return [LocationMaster]
    func geLocationsRouteFIR(_ _RouteMaster: RouteMaster){
    
        let child = _RouteMaster._MotoRoute.id
        if  child.characters.count > 5 {
        
                FIR_LOCATIONS.child("/\(child)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snap = snapshot.children.allObjects as? [FIRDataSnapshot] {

                    for item in snap {
                    
                        let newLocation = Location()
                        
                        let snapshotValue = item.value as? NSDictionary
                        
                        if let _accuracy = snapshotValue?["accuracy"] as? Double {
                            newLocation.accuracy = _accuracy
                        }
               
                        if let _altitude = snapshotValue?["altitude"] as? Double {
                            newLocation.altitude = _altitude
                        }
                        
                        if let _course = snapshotValue?["course"] as? Double {
                            newLocation.course = _course
                        }
                        
                        if let _distance = snapshotValue?["distance"] as? Double {
                            newLocation.distance = _distance
                        }
                        
                        if let _latitude = snapshotValue?["latitude"] as? Double {
                            newLocation.latitude = _latitude
                        }
                        
                        if let _longitude = snapshotValue?["longitude"] as? Double {
                            newLocation.longitude = _longitude
                        }
                        
                        if let _speed = snapshotValue?["speed"] as? Double {
                            newLocation.speed = _speed
                        }
                        
                        if let _timestamp = snapshotValue?["timestamp"] as? Int {
                            newLocation.timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(_timestamp))
                        }
                        
                        //add all locations to route model as list
                        _RouteMaster._MotoRoute.locationsList.append(newLocation)
                    }
                    
                    //make locationMasters iut if list
                    _RouteMaster.associateRouteFIR()
                    
                    let returnObj = [_RouteMaster]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: firbaseGetLocationsNotificationKey), object: returnObj)
                }
                
            // ...
        }) {
            (error) in
            print(error.localizedDescription)
            }
        }
}


}
