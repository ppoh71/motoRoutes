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


// Route Realm Model
class Route: Object {
    
    dynamic var id = ""
    dynamic var name = ""
    dynamic var duration = 0
    dynamic var distance = 0.0
    dynamic var timestamp = NSDate()
    dynamic var image = ""
    
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

    
    var route: [Route] {
        // Realm doesn't persist this property because it only has a getter defined
        return linkingObjects(Route.self, forProperty: "locationsList")
    }
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
    
    var route: [Route] {
        // Realm doesn't persist this property because it only has a getter defined
        return linkingObjects(Route.self, forProperty: "mediaList")
    }
}


//Gyroscope Object for location
class Gyroscope: Object {
    
    dynamic var timestamp = NSDate()
    
    var route: [Route] {
        // Realm doesn't persist this property because it only has a getter defined
        return linkingObjects(Route.self, forProperty: "gyroscopeList")
    }
}




// Master Location Model for all Route Operations inside App
class LocationMaster {
    
    var latitude = 0.0
    var longitude = 0.0
    var altitude = 0.0
    var speed = 0.0
    var course = 0.0
    var timestamp = NSDate()
    var accuracy = 0.0
    var marker = false
    var distance = 0.0

    
    init(latitude:Double, longitude:Double, altitude:Double,speed:Double, course:Double,timestamp:NSDate, accuracy:Double, marker:Bool, distance:Double ){
    
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speed = speed
        self.course = course
        self.timestamp = timestamp
        self.accuracy = accuracy
        self.marker = marker
        self.distance = distance
    
    }
    
    init(){
    }

}


// Master Media Model for all Route functions
class MediaMaster {
    
    dynamic var image = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var course = 0.0
    dynamic var timestamp = NSDate()
    dynamic var accuracy = 0.0
    
}



/*
 Remodel data for as kind of entity model, when it comes from realm
 */
class RouteMaster {

    
    var _RouteList = [LocationMaster]()
    
    init(){
    
    }
 
    
    //create a LocationMaster Object with from Realm List
    class func createMasterLocationRealm(LocationsList:List<Location>!) -> [LocationMaster]{
    
        var newRouteList = RouteMaster()._RouteList
    
        //loop all CLLocation and create and append to LocationMaster
        for location in LocationsList {
            
            let locationTmp = LocationMaster(latitude: location.latitude, longitude: location.longitude, altitude: location.altitude, speed: location.speed, course: location.course, timestamp: location.timestamp, accuracy: location.accuracy, marker: false, distance: location.distance)
    
            newRouteList.append(locationTmp)
    
        }
        
        return newRouteList
    }

    

    //update the marker object, so we know that the speedmarker has been set
    class func updateMarkerBool(RouteList: [LocationMaster], n: Int){
    
        //the marker for this location has been set
        RouteList[n].marker = true
        
    }
    
    
}



/**
 Save new route to realm
 
 - parameter locatiobRoute: [CLLocation] List with locations
 - parameter screenshotFilename: filename of screenshot
 - parameter startTimestamp: [starttime unix int
 - parameter distance: distance in m
 - parameter totalTime: total tine in seconds
 
 *
 */
class realmUtils{
    
    class func saveRouteRealm(LocationsRoute:[CLLocation], MediaObjects: [MediaMaster], screenshotFilename:String, startTimestamp:Int, distance:Double, totalTime:Int ){
        
        // save to realm
        let newRoute = Route()
        
        newRoute.id = UIDevice.currentDevice().identifierForVendor!.UUIDString + "#" + String(startTimestamp)
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
        
    }
    
}//end Class



/*
 //create a LocationMaster Object with from Core Location List
 class func createMasterLocation(locationsRoute:[CLLocation]) -> [LocationMaster]{
 
 print("#################MasterLocation")
 print(locationsRoute)
 
 var newRouteList = RouteMaster()._RouteList
 
 //loop all CLLocation and create and append to LocationMaster
 for location in locationsRoute {
 
 let locationTmp = LocationMaster(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude, speed: location.speed, course: location.course, timestamp: location.timestamp, accuracy: location.horizontalAccuracy, marker: false)
 
 newRouteList.append(locationTmp)
 
 }
 
 return newRouteList
 }
 */

