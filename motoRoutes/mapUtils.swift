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
        let x = CFAbsoluteTimeGetCurrent()
        
        //guard for print routes
        guard _LocationMaster.count > 2 else {
            print("GUARD print routes: not enough routes")
            return
        }
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        // define speedIndex and set first Index
        var speedIndex:Int = utils.getSpeedIndex(_LocationMaster[20].speed)
        globalSpeedSet.speedSet = speedIndex
        
        //temp speed
        //var tempSpeedIndex = speedIndex
        
        //reset global spped set to zero
        
        
        
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
            print("counts: \(coords.count) - sppedindex \(globalSpeedSet.speedSet) ")
            
        }
        
        print(" coord count  \(_LocationMaster.count)")
        print("Printing Route took \(utils.absolutePeromanceTime(x)) milliseconds")

    }
    
    
    class func printRouteOneColor(_LocationMaster:[LocationMaster]!, mapView:MGLMapView! ){
        
        
        //performacne test
        let x = CFAbsoluteTimeGetCurrent()
        
        //guard for print routes
        guard _LocationMaster.count > 2 else {
            print("GUARD print routes: not enough routes")
            return
        }
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        // define speedIndex and set first Index
        var speedIndex:Int = utils.getSpeedIndex(_LocationMaster[20].speed)
        globalSpeedSet.speedSet = speedIndex
        
        
        //loop through LocationMaster
        for location in _LocationMaster {
     
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))

        }
        
        //print route polygon
        let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
        mapView.addAnnotation(line)
        
        
        print(" coord count  \(_LocationMaster.count)")
        print("Printing Route took \(utils.absolutePeromanceTime(x)) milliseconds")
        
    }

    
    /**
    *   Print Route MArker on Route
     
        - parameter LocationMaster: LocationMaster Object
        - parameter mapView: current Mapview
    *
    **/
    class func printSpeedMarker(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!, key:Int, amount: Int, RouteSlider: UISlider?){
    
        
        //guard 
        guard _LocationMaster.count > key+amount else {
            print("GUARD print routes: not enough routes \(_LocationMaster.count) .. \(key+amount) .. \(amount)")
            return
        }
        
        var indexKex = key
        
        //define sliced Array
        let sliceEnd = key+amount
        let _LocationSlice = _LocationMaster[key+1...sliceEnd]
        
        
        print("MARKER PRINT \(key+1) .. \(key+amount) / Count: \(_LocationSlice.count)")
        
        for (index, master) in _LocationSlice.enumerate() {
           
            print("enum \(_LocationSlice.enumerate())")
            //set speed and altiude globals
            globalSpeed.gSpeed = master.speed
            globalAltitude.gAltitude = master.altitude
            
            
            if master.marker == false {
            
                //Update UILabel Distance
                if let tmpRouteSlider = RouteSlider {
                    // tmpTimeLabel.textColor =  colorUtils.polylineColors(speedIndex)
                    tmpRouteSlider.setValue(Float(indexKex), animated: true)
                    indexKex += 1
                }
                
                let newMarker = MGLPointAnnotation()
                newMarker.coordinate = CLLocationCoordinate2DMake(master.latitude, master.longitude)
                   //newMarker.subtitle = "route marker"
                    //newMarker.subtitle = "SpeedMarker\(key)"
                    //newMarker.description = media.image
            
                master.marker = true

                mapView.addAnnotation(newMarker)
                print("DISPATCH \(index)")
                
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
     *  - parameter DistanceLabel: Optional UILabel to display distance text
     *  - parameter TimeLable: Optional UILabel to display elapsed text
     *
     **/
    class func flyOverRoutes(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!, n: Int, SpeedLabel:UILabel?, DistanceLabel:UILabel?, TimeLabel:UILabel?, AltitudeLabel: UILabel?, RouteSlider: UISlider? ) {
        
        
        let count = _LocationMaster.count
        //var n = 0
        //var pitchCamera:CGFloat = 20.0
        var headingCourse:Double = 40.0
        //var arrayStep:Int = 5 // play ever n location from arr
        //var plabckCameraDuration:Double = 0.2
        // var cameraDistance = globalCamDistance.gCamDistance
        var distance = 0.0
        var timeeSpent = 0
        
        
        /**
         *  Camera fly to fx
         **/
        func fly( nx:Int, pitch: CGFloat, heading:Double){
            
            var n = nx
            //assign course of locationfor camera animation
            //headingCourse = _LocationMaster[n].course
            
            
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
            let camera = mapUtils.cameraDestination(_LocationMaster[n].latitude, longitude:_LocationMaster[n].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: heading)
            let speed = _LocationMaster[n].speed
            let speedIndex = utils.getSpeedIndex(speed)
            
            
            /**
            *  Update Lables / Slider
            **/
            
            //Update UILabel Speed
            if let tmpSpeedLabel = SpeedLabel {
                tmpSpeedLabel.textColor =  colorUtils.polylineColors(speedIndex)
                tmpSpeedLabel.text =  " \(utils.getSpeed(_LocationMaster[n].speed))"
            }
            
            //Update UILabel Distance
            if let tmpDistanceLabel = DistanceLabel {
                //tmpDistanceLabel.text =  " \(utils.distanceFormat(distance))"
                tmpDistanceLabel.text =  " alt \(_LocationMaster[n].altitude)"
            }
            
            //Update UILabel Distance
            if let tmpTimeLabel = TimeLabel {
                // tmpTimeLabel.textColor =  colorUtils.polylineColors(speedIndex)
                tmpTimeLabel.text =  " \(timespendString)"
            }
            
            //Update UILabel Distance
            if let tmpRouteSlider = RouteSlider {
                // tmpTimeLabel.textColor =  colorUtils.polylineColors(speedIndex)
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
        
        
        print("#################Coords")
        print(_locationsMaster)
        
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
        
        print("struct")
        print(newCoordBound)
        
        let coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: newCoordBound.south, longitude: newCoordBound.east), CLLocationCoordinate2D(latitude: newCoordBound.north, longitude: newCoordBound.west))
        
        return coordBounds
        
    }

    
    
}