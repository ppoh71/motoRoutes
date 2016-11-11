//
//  DataService.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage


let FirDB = FIRDatabase.database().reference()
let FirStorage = FIRStorage.storage()

class FirebaseData {
    static let dataService = FirebaseData()
    
    var r_ = RouteMaster()
    fileprivate var _REF_BASE = FirDB
    fileprivate var _REF_ROUTES = FirDB.child("motoRoutes")
    fileprivate var _REF_LOCATIONS = FirDB.child("Locations")
    fileprivate var _REF_STORAGE = FirStorage.reference(forURL: "gs://motoroutes-c018f.appspot.com")

    var REF_Base: FIRDatabaseReference{
        return _REF_BASE
    }
    
    var FIR_ROUTES: FIRDatabaseReference{
        return _REF_ROUTES
    }
    
    var FIR_LOCATIONS: FIRDatabaseReference{
        return _REF_LOCATIONS
    }
    
    var FIR_STORAGE: FIRStorageReference{
        return _REF_STORAGE
    }

    func addRouteToFIR(_ motoRoute: RouteMaster, keychain: String) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        var routeKey = motoRoute._MotoRoute.id
        routeKey = routeKey.replacingOccurrences(of: "#", with: "-")
        print(userID ?? "no userifd")
        
        //add routeMaster data
        let motoRouteData: Dictionary<String, AnyObject> = [
            "firUID": keychain as AnyObject,
            "startLatitude": motoRoute._RouteList[0].latitude as AnyObject,
            "startLongitude": motoRoute._RouteList[0].longitude as AnyObject,
            "duration": motoRoute._MotoRoute.duration as AnyObject,
            "timestamp": motoRoute._MotoRoute.timestamp.timeIntervalSince1970 as AnyObject,
            "locationStart": motoRoute._MotoRoute.locationStart as AnyObject,
            "locationEnd" : motoRoute._MotoRoute.locationEnd as AnyObject,
            "distance" : motoRoute._MotoRoute.distance as AnyObject,
            "image" : motoRoute._MotoRoute.image as AnyObject
            ]
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.childUpdatesFIR(self.FIR_ROUTES, key: String(routeKey), data: motoRouteData)
            DispatchQueue.global().async {
                //do stuff in main thread
            }
        }

        
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
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.childUpdatesFIR(self.FIR_LOCATIONS, key: String(routeKey), data: locationAll as Dictionary<String, AnyObject>)
            DispatchQueue.global().async {
                //do stuff in main thread
            }
        }
        
       self.uploadRouteImage(motoRoute._MotoRoute.image, id: motoRoute._MotoRoute.id)
       
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
                    
                    if let _image = snapshotValue?["image"] as? String {
                        newRoute.image = _image
                    }
                    
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
    
    func uploadRouteImage(_ imgName: String, id: String){
        // File located on disk
        print(id)
        let localFile = Utils.getDocumentsDirectory().appendingPathComponent(imgName)
        let localFileUrl = URL(fileURLWithPath: localFile)
        
        // Create a reference to the file you want to upload
        let riversRef = FIR_STORAGE.child("\(id)/\(id).png")
        
        // Upload the file to the path "images/rivers.jpg"
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let _ = riversRef.putFile(localFileUrl, metadata: nil) { metadata, error in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata!.downloadURL
                    print(downloadURL)
                }
            }

            DispatchQueue.global().async {
                //do stuff in main thread
            }
        }
    }
    
    func downloadRouteImage(_ imgName: String, id: String){
        // Create a reference to the file you want to download
        let islandRef = FIR_STORAGE.child("\(id)/\(imgName)")
        
        // Download to the local filesystem
        let filename = Utils.getDocumentsDirectory().appendingPathComponent(imgName)
        
        // Create local filesystem URL
        let localURL: NSURL! = NSURL(string: filename)
        
        // Download to the local filesystem
        _ = islandRef.write(toFile: localURL as URL) { (URL, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Local file URL for "images/island.jpg" is returned
            }
        }
    }

}

