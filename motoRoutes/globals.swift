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
    
    //init global camera distance
    var gCamDistance  = 100.0
    init(gCamDistance:Double) {
        self.gCamDistance = gCamDistance
    }
    
    //init global camera animation duration
    var gCamDuration  = 0.2
    init(gCamDuration:Double) {
        self.gCamDuration = gCamDuration
    }
    
    //init global camnera pitch
    var gCamPitch:CGFloat  = 0.2
    init(gCamPitch:CGFloat) {
        self.gCamPitch = gCamPitch
    }
    
    //steps throu Location Array
    var gArrayStep:Int = 1
    init(gArrayStep:Int){
        self.gArrayStep = gArrayStep
    }
    
    
    //steps throu Location Array
    var gAutoplay:Bool = false
    init(gAutoplay:Bool){
        self.gAutoplay = gAutoplay
    }
    
}



var globalSpeedSet = global(speedSet:0)
var globalColor = global(gColor: UIColor.whiteColor())

var globalCamDistance = global(gCamDistance: 11500)
var globalCamDuration = global(gCamDuration: 0.2)
var globalCamPitch = global(gCamPitch: 60)
var globalArrayStep = global(gArrayStep: 1)
var globalAutoplay = global(gAutoplay: false)