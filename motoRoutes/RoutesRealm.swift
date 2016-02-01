//
//  realmLocation.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 28.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import RealmSwift
import Foundation


// Roue Data Model
class Location: Object {
    
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var timestamp = NSDate()
    
    var route: [Route] {
        // Realm doesn't persist this property because it only has a getter defined
        // Define "owners" as the inverse relationship to Person.dogs
        return linkingObjects(Route.self, forProperty: "locationsList")
    }
}

// Person model
class Route: Object {
    
    dynamic var name = ""
    dynamic var duration = 0
    dynamic var distance = 0.0
    dynamic var timestamp = NSDate()
    
    let locationsList = List<Location>()
    
}
