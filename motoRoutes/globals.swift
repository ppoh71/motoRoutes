//
//  globals.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20/02/16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation

class global {
    
    var speedSet:Int = 0
    init(speedSet:Int) {
        self.speedSet = speedSet
    }
}
var globalSpeedSet = global(speedSet:0)
