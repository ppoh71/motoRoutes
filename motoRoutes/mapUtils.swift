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


class mapUtils {
    
    
    //Bound Structure
    struct coordBound{
        var north:Double = 0
        var south:Double = 0
        var west:Double = 0
        var east:Double = 0
    }
    
    
    /*
    
    Print route with colored polylines
    
    - parameter LocationMaster: LocationMaster Object
    - parameter mapView: current Mapview
    
    */
    
    class func printRoute(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!){
        
        
        //performacne test
   //     let x = CFAbsoluteTimeGetCurrent()
        
        //guard for print routes
        guard _LocationMaster.count > 2 else {
            print("GUARD print routes: not enough routes")
            return
        }
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        // define speedIndex and set first Index
        var speedIndex:Int = utils.getSpeedIndex(_LocationMaster[0].speed)
        globalSpeedSet.speedSet = speedIndex
        
        //temp speed
        //var tempSpeedIndex = speedIndex
        //reset global spped set to zero
        
        //loop through LocationMaster
        for location in _LocationMaster {
            
            //get speed index
            speedIndex = utils.getSpeedIndex(location.speed)
            
       
            print("\(globalSpeedSet.speedSet)")
            
            //add locations to coord with the same speedIndex
            if(speedIndex == globalSpeedSet.speedSet){
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
                
            } else{ // if the speedIndex is different, ad the last location and print the route
                
                //add first location with diff speedIndex to mind gaps
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
                //print route polygon
                let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                mapView.addAnnotation(line)
                
                //set new speedindex, needed for coloring the route
                globalSpeedSet.speedSet = speedIndex
                
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
            //print("counts: \(coords.count) - sppedindex \(globalSpeedSet.speedSet) ")
            
        }
        
        //print(" coord count  \(_LocationMaster.count)")
        //print("Printing Route took \(utils.absolutePeromanceTime(x)) milliseconds")

    }
    
    
    class func printRouteOneColor(_LocationMaster:[LocationMaster]!, mapView:MGLMapView! ){
        
        
        //performacne test
       // let x = CFAbsoluteTimeGetCurrent()
        
        //guard for print routes
        guard _LocationMaster.count > 2 else {
            print("GUARD print routes: not enough routes")
            return
        }
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        // define speedIndex and set first Index
        let speedIndex:Int = utils.getSpeedIndex(_LocationMaster[20].speed)
        globalSpeedSet.speedSet = speedIndex
        
        
        //loop through LocationMaster
        for location in _LocationMaster {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        //print route polygon
        let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
        mapView.addAnnotation(line)
        
        //print(" coord count  \(_LocationMaster.count)")
        //print("Printing Route took \(utils.absolutePeromanceTime(x)) milliseconds")
    }

    
    /**
    *   Print Route aArker on Route
     
        - parameter LocationMaster: LocationMaster Object
        - parameter mapView: current Mapview
    *
    **/
    class func printSpeedMarker(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!, key:Int, amount: Int){
    
        
        //guard 
        guard _LocationMaster.count > key+amount else {
            print("GUARD print routes: not enough routes \(_LocationMaster.count) .. \(key+amount) .. \(amount)")
            return
        }
        
        //define sliced Array
        let sliceEnd = key+amount
        let _LocationSlice = _LocationMaster[key...sliceEnd-1]
        
        //print("MARKER PRINT \(key+1) .. \(key+amount) / Count: \(_LocationSlice.count)")
        
        for master in _LocationSlice {
           
            //print("enum \(_LocationSlice.enumerate())")
            //set speed and altiude globals
            globalSpeed.gSpeed = master.speed
            globalAltitude.gAltitude = master.altitude
            
            if master.marker == false {
            
                let newMarker = MGLPointAnnotation()
                newMarker.coordinate = CLLocationCoordinate2DMake(master.latitude, master.longitude)
                   //newMarker.subtitle = "route marker"
                    //newMarker.subtitle = "SpeedMarker\(key)"
                    //newMarker.description = media.image
            
                mapView.addAnnotation(newMarker)
                
                //mark marker as printed "true" back in MasterRoute Array
                master.marker = true
                
            }
         }
    
    }
    
    
    class func printSingleSpeedMarker( mapView:MGLMapView!, latitude: Double, longitude: Double, speed: Double){
    
    
        let newMarker = MGLPointAnnotation()
        
        newMarker.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        //   newMarker.subtitle = "route marker"
       // newMarker.subtitle = "SpeedMarker\(key)"
        // newMarker.description = media.image
        
        //globalLineAltitude.gLineAltitude = master.altitude
        globalSpeed.gSpeed = speed
       // globalMarkerID.gMarkerID = "\(master.timestamp.timeIntervalSince1970)-\(master.latitude)"
        
        //addSpeedMarker(newMarker)
        mapView.addAnnotation(newMarker)
        // master.marker = true
    
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
        
        
        let cameray = mapUtils.cameraDestination(_LocationMaster[0].latitude, longitude:_LocationMaster[0].longitude, fromDistance:2300, pitch:60, heading:0)
        
        
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
     *
     *
     **/
    class func flyOverRoutes(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!, n: Int, routeSlider: RouteSlider?, initInstance: String!, identifier: String, speedoMeter: Speedometer? ) -> Bool{
        
        
        let count = _LocationMaster.count
        //var pitchCamera:CGFloat = 20.0
        var headingCourse:Double = _LocationMaster[n].course+globalHeading.gHeading
        //var arrayStep:Int = 5 // play ever n location from arr
        //var plabckCameraDuration:Double = 0.2
        // var cameraDistance = globalCamDistance.gCamDistance
        var distance = 0.0
        print("INIT Instance: \(initInstance) / \(identifier)")
        
        //Struct to hold static var, to identify running instances fo function and stop if needed
        struct Holder {
            static var staticInstance = ""
        }
        
        //assign instance to global static
        Holder.staticInstance = initInstance

        
        /**
         *  Camera fly to fx
         **/
        func fly( nx:Int, pitch: CGFloat, heading:Double, instance: String){
            
            var n = nx
            let currentInstance:String = instance
            
            print("FLY Instance: \(instance)")
            
            /* check if there are marker on the route point, when in autofly mode */
            if(_LocationMaster[n].marker == false && globalAutoplay.gAutoplay == true) {
                
                print("Notify send")
                let arrayN = [n]
                NSNotificationCenter.defaultCenter().postNotificationName(markerNotSetNotificationKey, object: arrayN)
                
            }
 
            
            //assign course of locationfor camera animation
            headingCourse = _LocationMaster[n].course+globalHeading.gHeading

            //get next array key by amoutn of arraySteps; default 1
            let nextIndex = n+globalArrayStep.gArrayStep < _LocationMaster.count ? n+globalArrayStep.gArrayStep : _LocationMaster.count-1
            
            //get distance from LocationMaster
            distance = _LocationMaster[n].distance
            
            //time spend on road
            let elapsedTime = _LocationMaster[nextIndex].timestamp.timeIntervalSinceDate(_LocationMaster[0].timestamp)
            let timespendString = utils.clockFormat(Int(elapsedTime))
            
            //define camera for flyTo ani
            let camera = mapUtils.cameraDestination(_LocationMaster[n].latitude, longitude:_LocationMaster[n].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: heading)
            let speed = _LocationMaster[n].speed
            let speedIndex = utils.getSpeedIndexFull(speed)
            
            globalSpeedSet.speedSet = speedIndex
            
            //update speedometer
            speedoMeter?.moveSpeedo(Double(utils.getSpeed(_LocationMaster[n].speed)))
            
            /**
            *  Update Lables / Slider
            **/
            
            //Update UILabel Speed
//            if let tmpSpeedLabel = SpeedLabel {
//                tmpSpeedLabel.textColor =  colorUtils.polylineColors(speedIndex)
//                tmpSpeedLabel.text =  " \(utils.getSpeed(_LocationMaster[n].speed))"
//            }
            
            
            //Update UILabel in Slider
            if let tmpRouteSlider = routeSlider {
                // tmpTimeLabel.textColor =  colorUtils.polylineColors(speedIndex)
                tmpRouteSlider.setValue(Float(n), animated: true)
                print("Slider Move \(n)")
                tmpRouteSlider.setLabel((utils.distanceFormat(distance)), timeText: timespendString)
            }
            
            
            /**
            * Let it fly
            **/
            
            mapView.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {
                // mapView.flyToCamera(camera, withDuration: plabckCameraDuration) {
                
                //create instance to track loop func call
                
                print("LOOP INSTANCE \( Holder.staticInstance) - \(currentInstance)")
                
                if( Holder.staticInstance != currentInstance){
                     print("NOT EQUAL \( Holder.staticInstance) - \(currentInstance)")
                }
                
                
                // loop until end of array or if a new instance is set, kill teh old one by comapre staticInstance with curren one
                if(n+globalArrayStep.gArrayStep < _LocationMaster.count && globalAutoplay.gAutoplay == true && currentInstance == Holder.staticInstance ){
                    
                    n = n+globalArrayStep.gArrayStep
                   
                    fly(n, pitch: globalCamPitch.gCamPitch, heading: headingCourse, instance: currentInstance)
                }
        
            }
        }
        
        // start the whole thing
        fly(n, pitch: globalCamPitch.gCamPitch, heading: headingCourse, instance: initInstance)
        
        return true // when all done
        
    }
    
    
    /**
     * Get most north, south, west & east coords
     * to create bound rectangle
     * by location array
     *
     * - parameter locatiobRoute: [CLLocation] List with locations
     *
     * - returns: coordBound struct n,e,s,w with geo bounds rectangle for mapbox
     */
    class func getBoundCoords(_locationsMaster:[LocationMaster]) -> MGLCoordinateBounds{
        
        
        //print("#################Coords")
        //print(_locationsMaster)
        
        //create new bound struct
        var newCoordBound = coordBound()
        
        //loop if we have locations
        guard _locationsMaster.count > 10 else {
            print("GUARD bounds: locationRoute count 0")
            let coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 0, longitude: 0))
            
            return coordBounds
        }
        
        //init with first vars
        newCoordBound.north = _locationsMaster[0].latitude
        newCoordBound.south = _locationsMaster[0].latitude
        newCoordBound.west = _locationsMaster[0].longitude
        newCoordBound.east = _locationsMaster[0].longitude
        
        //loop fot all coords in a array and set bounds
        for location in _locationsMaster {
            
            //set most west
            if(location.latitude > newCoordBound.north){
                newCoordBound.north = location.latitude
            }
            
            //set most south
            if(location.latitude < newCoordBound.south){
                newCoordBound.south = location.latitude
            }
            
            //Set most west
            if(location.longitude < newCoordBound.west){
                newCoordBound.west = location.longitude
            }
            
            //set most east
            if(location.longitude < newCoordBound.west){
                newCoordBound.west = location.longitude
            }
            
        }
        
        //print("struct")
        print(newCoordBound)
        
        let coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: newCoordBound.south, longitude: newCoordBound.east), CLLocationCoordinate2D(latitude: newCoordBound.north, longitude: newCoordBound.west))
        
        return coordBounds
        
    }

    
    
}