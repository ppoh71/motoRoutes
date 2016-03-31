//
//  utils.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 16.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RealmSwift
import Mapbox


class mapFx {
    
    
    
    
    /*
    
    Print route with colored polylines
    
    - parameter LocationMaster: LocationMaster Object
    - parameter mapView: current Mapview
    
    */
    
    class func printRoute(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!){
        
        
        //performacne test
        let x = CFAbsoluteTimeGetCurrent()
        
        // define speedIndex
        var speedIndex:Int = 0
        
        //guard for print routes
        guard _LocationMaster.count > 2 else {
            print("GUARD print routes: not enough routes")
            return
        }
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        //reset global spped set to zero
        globalSpeedSet.speedSet = 0
        
        //loop through LocationMaster
        for location in _LocationMaster {
            
            //get speed index
            speedIndex = utils.getSpeedIndex(location.speed)
            
            //add locations to coord with the same speedIndex
            if(speedIndex == globalSpeedSet.speedSet){
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
            } else{ // if the speedIndex is different, ad the last location and print the route
                
                //add first location with diff speedIndex to mind gaps
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
                //set new speedindex, needed for coloring the route
                globalSpeedSet.speedSet = speedIndex
                
                //print route polygon
                let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                mapView.addAnnotation(line)
                
                //reset coord after printing the route, add last coord to connect poylines
                coords = [CLLocationCoordinate2D]()
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
            }
            
        }
        
        //print last routes set, for last spped loop
        if(coords.count>0){
            
            //set speedIndex
            globalSpeedSet.speedSet = speedIndex
            
            //print route polygon
            let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
            mapView.addAnnotation(line)
            
            //print the coords for the last run
            print("counts: \(coords.count) - sppedindex \(globalSpeedSet.speedSet) ")
            
        }
        
        print(" coord count  \(_LocationMaster.count)")
        // print("Printing Route took \(utils.absolutePeromanceTime(x)) milliseconds")
    }
    
    
    /*
    * create camera from location, distance, pitch and heading
    * can use for cameraflyto animations
    */
    class func cameraDestination(latitude:CLLocationDegrees, longitude:CLLocationDegrees, fromDistance:Double, pitch:CGFloat, heading:Double) -> MGLMapCamera {
        
        let destination = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = MGLMapCamera(lookingAtCenterCoordinate: destination, fromDistance: fromDistance, pitch: pitch, heading: heading)
        
        return camera
    }
    
    
    
    /*
    * print route
    */
    
    class func cameraAni(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!){
        
        
        //get coord bounds for route, nortwest & souteast
        //let coordBounds = utils.getBoundCoords(_LocationMaster)
        
        //set visible bounds
        // mapView.setVisibleCoordinateBounds(coordBounds, animated: true)
        
        
        //let camerax = mapFx.cameraDestination(_LocationMaster[0].latitude, longitude:_LocationMaster[0].longitude, fromDistance:12000, pitch:60, heading:300)
        
        
        let cameray = mapFx.cameraDestination(_LocationMaster[0].latitude, longitude:_LocationMaster[0].longitude, fromDistance:2300, pitch:60, heading:0)
        
        
        mapView.flyToCamera(cameray) {
            // Optionally catch a connecting flight
            //  print("connection flight")
            // mapView.flyToCamera(cameray){
            // mapView.setVisibleCoordinateBounds(coordBounds, animated: true)
            
            // }
        }
    }
    
    
    
    /**
     *   Fly Camera over route
     *
     *  - parameter LocationMaster: Array of [LocationMaster] with tghe MasterLocation Object
     *  - parameter mapView: MGLMapView! Object
     *  - parameter SpeedLabel: Optional UILabel to display speed text
     *  - parameter DistanceLabel: Optional UILabel to display distance text
     *  - parameter TimeLable: Optional UILabel to display elapsed text
     *
     **/
    class func flyOverRoutes(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!, n: Int, SpeedLabel:UILabel?, DistanceLabel:UILabel?, TimeLabel:UILabel?, AltitudeLabel: UILabel?, RouteSlider: UISlider? ) {
        
        
        let count = _LocationMaster.count
        //var n = 0
        //var pitchCamera:CGFloat = 20.0
        var headingCourse:Double = 0.0
        //var arrayStep:Int = 5 // play ever n location from arr
        //var plabckCameraDuration:Double = 0.2
        // var cameraDistance = globalCamDistance.gCamDistance
        var distance = 0.0
        var timeeSpent = 0
        
        
        /**
         *  Camera fly to fx
         **/
        func fly(var n:Int, pitch: CGFloat, heading:Double){
            
            
            //assign course of locationfor camera animation
            headingCourse = _LocationMaster[n].course
            
            /**
             *  Get some Data for Lables and Stuff
             **/
             
             //Distrance Calc from A B
            let nextIndex = n+globalArrayStep.gArrayStep < _LocationMaster.count ? n+globalArrayStep.gArrayStep : _LocationMaster.count-1
            let _locationA = CLLocation(latitude: _LocationMaster[n].latitude, longitude: _LocationMaster[n].longitude)
            let _locationB = CLLocation(latitude: _LocationMaster[nextIndex].latitude, longitude: _LocationMaster[nextIndex].longitude)
            
            //set distance
            distance += _locationA.distanceFromLocation(_locationB)
            
            
            //time spend on road
            let elapsedTime = _LocationMaster[nextIndex].timestamp.timeIntervalSinceDate(_LocationMaster[0].timestamp)
            let timespendString = utils.clockFormatShort(Int(elapsedTime))
            
            //define camera for flyTo ani
            let camera = mapFx.cameraDestination(_LocationMaster[n].latitude, longitude:_LocationMaster[n].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: heading)
            let speed = _LocationMaster[n].speed
            let speedIndex = utils.getSpeedIndex(speed)
            
            
            /**
            *  Update Lables / Slider
            **/
            
            //Update UILabel Speed
            if let tmpSpeedLabel = SpeedLabel {
                tmpSpeedLabel.textColor =  colorStyles.polylineColors(speedIndex)
                tmpSpeedLabel.text =  " \(utils.getSpeed(_LocationMaster[n].speed))"
            }
            
            //Update UILabel Distance
            if let tmpDistanceLabel = DistanceLabel {
                // tmpDistanceLabel.textColor =  colorStyles.polylineColors(speedIndex)
                tmpDistanceLabel.text =  " \(utils.distanceFormat(distance))"
            }
            
            //Update UILabel Distance
            if let tmpTimeLabel = TimeLabel {
                // tmpTimeLabel.textColor =  colorStyles.polylineColors(speedIndex)
                tmpTimeLabel.text =  " \(timespendString)"
            }
            
            //Update UILabel Distance
            if let tmpRouteSlider = RouteSlider {
                // tmpTimeLabel.textColor =  colorStyles.polylineColors(speedIndex)
                tmpRouteSlider.setValue(Float(n), animated: true)
            }
            
            /**
            * Let it fly
            **/
            
            mapView.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {
                // mapView.flyToCamera(camera, withDuration: plabckCameraDuration) {
                
                // loop until end of array
                if(n+globalArrayStep.gArrayStep < _LocationMaster.count && globalAutoplay.gAutoplay == true){
                    n = n+globalArrayStep.gArrayStep
                    fly(n, pitch: globalCamPitch.gCamPitch, heading: headingCourse)
                }
            }
        }
        
        // start the whole thing
        fly(n, pitch: globalCamPitch.gCamPitch, heading: headingCourse)
        
    }
    
    
}