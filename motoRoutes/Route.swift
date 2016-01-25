//
//  route.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 24/01/16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//


import Foundation
import CoreData

class Route: NSManagedObject {
    
    @NSManaged var name: NSString
    @NSManaged var duration: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var timestamp: NSDate
    
    @NSManaged var locationRelations: NSOrderedSet

    
}