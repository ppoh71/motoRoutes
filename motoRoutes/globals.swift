//
//  globals.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20/02/16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit

class global {
    
    //init sppedSet ( needed in same speed same color routes)
    var speedSet:Int = 0
    init(speedSet:Int) {
        self.speedSet = speedSet
    }
    
    //init global color
    var gColor:UIColor = UIColor.whiteColor()
    init(gColor:UIColor) {
        self.gColor = gColor
    }
    
}

var globalSpeedSet = global(speedSet:0)
var globalColor = global(gColor: UIColor.whiteColor())