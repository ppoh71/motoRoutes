//
//  realmLocation.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 28.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import RealmSwift
import Foundation


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
    
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var course = 0.0
    dynamic var timestamp = NSDate()
    dynamic var accuracy = 0.0

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
