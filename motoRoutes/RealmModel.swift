//
//  realmLocation.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 28.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import RealmSwift
import Foundation
import CoreLocation
import Mapbox


//MARK: REALM Objects

// Route Realm Model
class Route: Object {
    
    dynamic var id = ""
    dynamic var name = ""
    dynamic var duration = 0
    dynamic var distance = 0.0
    dynamic var timestamp = NSDate()
    dynamic var image = ""
    dynamic var locationStart = ""
    dynamic var locationEnd = ""
    dynamic var startLatitude = 0.0
    dynamic var startLongitude = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    let locationsList = List<Location>()
    let mediaList = List<Media>()
    let gyroscopeList = List<Gyroscope>()
}


// Location Realm Data Model
class Location: Object {
    
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var course = 0.0
    dynamic var accuracy = 0.0
    dynamic var distance = 0.0
    dynamic var timestamp = NSDate()
    
    let route = LinkingObjects(fromType: Route.self, property: "locationsList")
}

//Media Object for location
class Media: Object {
    
    dynamic var image = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var course = 0.0
    dynamic var timestamp = NSDate()
    dynamic var accuracy = 0.0
    
    let route = LinkingObjects(fromType: Route.self, property: "mediaList")
}


//Gyroscope Object for location
class Gyroscope: Object {
    
    dynamic var timestamp = NSDate()
    let route = LinkingObjects(fromType: Route.self, property: "gyroscopeList")
}


//MARK: REALM UTILS, Save


/*  Save new route to realm */

class RealmUtils{
    
    class func saveRouteRealm(LocationsRoute:[CLLocation], MediaObjects: [MediaMaster], screenshotFilename:String, startTimestamp:Int, distance:Double, totalTime:Int ) -> String {
        
        // save to realm
        let newRoute = Route()
        let id = NSUUID().UUIDString
        
        newRoute.id = id
        newRoute.timestamp = NSDate()
        newRoute.distance = distance
        newRoute.duration = totalTime
        newRoute.image = screenshotFilename
        
        // distance calc
        var locationDistance = 0.0
        var lastLocation = LocationsRoute[0]
        
        //add Locations to Realm Objctes
        for location in LocationsRoute {
            
            
            //calc distance
            locationDistance += location.distanceFromLocation(lastLocation)
            lastLocation = location
            
            //print("locationdistance: \(locationDistance)" )
            
            let newLocation = Location()
            
            newLocation.timestamp = location.timestamp
            newLocation.latitude = location.coordinate.latitude
            newLocation.longitude = location.coordinate.longitude
            newLocation.altitude = location.altitude
            newLocation.speed = location.speed
            newLocation.course = location.course
            newLocation.accuracy = location.horizontalAccuracy
            newLocation.distance = locationDistance
            
            newRoute.locationsList.append(newLocation)
            
        }
        
        //add Media to Realm Objctes
        for media in MediaObjects {
            
            let newMedia = Media()
            
            newMedia.latitude = media.latitude
            newMedia.longitude  = media.longitude
            newMedia.timestamp  = media.timestamp
            newMedia.image = media.image
            
            newRoute.mediaList.append(newMedia)
        }
        
        
        // Get the default Realm
        let realm = try! Realm()
        // You only need to do this once (per thread)
        
        // Add to the Realm inside a transaction
        try! realm.write {
            realm.add(newRoute)
        }
        
        return id
    }
    
    class func saveRouteFromFIR(_RouteMaster: RouteMaster){
    
        // Get the default Realm
        let realm = try! Realm()
        let routetExists = realm.objects(Route).filter("id == %@", _RouteMaster._MotoRoute.id)
        
        if routetExists.count == 0 {
            try! realm.write {
                print("added route to realm")
                realm.add(_RouteMaster._MotoRoute)
            }
        } else {
            //don't add
            print("route exists, donÄt add")
        }
    }
    
    
    
    class func getRealmByID(routeID: String) -> Results<Route>{
        
        let realm = try! Realm()
        let  currRoute = realm.objects(Route.self).filter("id = '\(routeID)' ")
        return currRoute
    }
    
    
    class func updateLocation2Realm(route: Route, location: String, field: String) {
        let realm = try! Realm()
        try! realm.write {
            
            switch(field){
                
            case "from":
                route.locationStart = location
                
            case "to":
                route.locationEnd = location
                
            default:
                break
            }
        }
    }
    
    
}



