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
    var gCamDuration  = 0.5
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
    
    //steps throu Location Array
    var gLineAltitude:Double = 0.0
    init(gLineAltitude:Double){
        self.gLineAltitude = gLineAltitude
    }
    
    //Speed
    var gSpeed:Double = 0.0
    init(gSpeed:Double){
        self.gSpeed = gSpeed
    }
    
    //
    var gMarkerID:String = ""
    init(gMarkerID:String){
        self.gMarkerID = gMarkerID
    }
    
    //
    var gCounter:Int = 0
    init(gCounter:Int){
        self.gCounter = gCounter
    }
    
    var gAltitude:Double = 0
    init(gAltitude:Double){
        self.gAltitude = gAltitude
    }
    
    var gHeading:Double = 0
    init(gHeading:Double){
        self.gHeading = gHeading
    }
    
    var gRoutePos:Int = 0
    init(gRoutePos:Int){
        self.gRoutePos = gRoutePos
    }
    
    
    
    
}



var globalSpeedSet = global(speedSet:0)
var globalColor = global(gColor: UIColor.whiteColor())
var globalCamDistance = global(gCamDistance: 11500)
var globalCamDuration = global(gCamDuration: 0.2)
var globalCamPitch = global(gCamPitch: 60)
var globalArrayStep = global(gArrayStep: 1)
var globalAutoplay = global(gAutoplay: false)
var globalLineAltitude = global(gLineAltitude: 0.0)
var globalSpeed = global(gSpeed: 0.0)
var globalMarkerID = global(gMarkerID: "")
var globalCounter = global(gCounter: 0)
var globalAltitude = global(gAltitude: 0)
var globalHeading = global(gHeading: -60)
var globalRoutePos = global(gRoutePos: 0)


