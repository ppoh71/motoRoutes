//
//  globals.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20/02/16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit





//Enum function types
enum FuncTypes: String {
    case Recording
    case PrintMarker
    case PrintBaseHeight
    case PrintAltitude
    case PrintCircles
    case PrintStartEnd
    case Default
}


//dirty globl vars
final class Global {
    
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



var globalSpeedSet = Global(speedSet:0)
var globalColor = Global(gColor: UIColor.whiteColor())
var globalCamDistance = Global(gCamDistance: 11500)
var globalCamDuration = Global(gCamDuration: 0.2)
var globalCamPitch = Global(gCamPitch: 60)
var globalArrayStep = Global(gArrayStep: 1)
var globalAutoplay = Global(gAutoplay: false)
var globalLineAltitude = Global(gLineAltitude: 0.0)
var globalSpeed = Global(gSpeed: 0.0)
var globalMarkerID = Global(gMarkerID: "")
var globalCounter = Global(gCounter: 0)
var globalAltitude = Global(gAltitude: 0)
var globalHeading = Global(gHeading: -60)
var globalRoutePos = Global(gRoutePos: 0)


