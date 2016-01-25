//
//  location.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 24/01/16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {
    
    @NSManaged var timestamp: NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var altitude: NSNumber
    @NSManaged var pace: NSNumber
    
    @NSManaged var routeRelation: NSManagedObject 
    
}
