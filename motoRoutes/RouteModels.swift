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




// Master Location Model for all Route functions
class LocationMaster {
    
    var latitude = 0.0
    var longitude = 0.0
    var altitude = 0.0
    var speed = 0.0
    var course = 0.0
    var timestamp = NSDate()
    var accuracy = 0.0
    var marker = false

    
    init(latitude:Double, longitude:Double, altitude:Double,speed:Double, course:Double,timestamp:NSDate, accuracy:Double, marker:Bool ){
    
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speed = speed
        self.course = course
        self.timestamp = timestamp
        self.accuracy = accuracy
        self.marker = marker
    
    }
    
    
    init(){
        
    }
    
    
}


class RouteMaster {

    
    var _RouteList = [LocationMaster]()
    
    init(){
    
    }

    
    
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

    
    
    //create a LocationMaster Object with from Realm List
    class func createMasterLocationRealm(LocationsList:List<Location>!) -> [LocationMaster]{
    
        var newRouteList = RouteMaster()._RouteList
    
        //loop all CLLocation and create and append to LocationMaster
        for location in LocationsList {
            
            let locationTmp = LocationMaster(latitude: location.latitude, longitude: location.longitude, altitude: location.altitude, speed: location.speed, course: location.course, timestamp: location.timestamp, accuracy: location.accuracy, marker: false)
    
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





// Master Location Model for all Route functions
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
