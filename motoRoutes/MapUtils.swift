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
import GLKit


final class MapUtils {
    
    
    //Bound Structure
    struct coordBound{
        var north:Double = 0
        var south:Double = 0
        var west:Double = 0
        var east:Double = 0
    }
    
    
    /*
     * Print route with colored polylines
     */
    class func printRoute(_ _LocationMaster:[LocationMaster]!, mapView:MGLMapView!){
        
        //performacne test
        //let x = CFAbsoluteTimeGetCurrent()
        
        //guard for print routes
        guard _LocationMaster.count > 2 else {
            print("GUARD print routes: not enough routes")
            return
        }
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        // define speedIndex and set first Index
        var speedIndex:Int = Utils.getSpeedIndex(_LocationMaster[0].speed)
        globalSpeedSet.speedSet = speedIndex
        
        //loop through LocationMaster
        for location in _LocationMaster {
            
            //get speed index
            speedIndex = Utils.getSpeedIndex(location.speed)
            
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
                
                print(globalSpeedSet.speedSet)
            }
        }
        
        //print last routes set, for last spped loop
        if(coords.count>0){
            
            //set speedIndex
            globalSpeedSet.speedSet = speedIndex
            
            //print route polygon
            let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
            mapView.addAnnotation(line)
        }
    }
    
    
    class func printRouteOneColor(_ _LocationMaster:[LocationMaster]!, mapView:MGLMapView! ){
        
        // let x = CFAbsoluteTimeGetCurrent()
        
        //guard for print routes
        guard _LocationMaster.count > 2 else {
            print("GUARD print routes: not enough routes")
            return
        }
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        // define speedIndex and set first Index
        let speedIndex:Int = Utils.getSpeedIndex(0)
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
    
    
    class func printMarker(_ _LocationMaster:[LocationMaster]!, mapView:MGLMapView!, key:Int, amount: Int, gap: Int, funcType: FuncTypes) {
        
        //let x = CFAbsoluteTimeGetCurrent()
        
        //define sliced Array
        let sliceEnd = key+amount
        let _LocationSlice = _LocationMaster[key...sliceEnd-1]
        var count = 0
        
        //guard
        guard _LocationMaster.count > key+amount else {
            print("GUARD print routes: not enough routes \(_LocationMaster.count) .. \(key+amount) .. \(amount)")
            return
        }
        
        for master in _LocationSlice{
            
            if master.marker == false {
                
                // print only every n marker, defined by gap
                count = count > gap ? 0 : count
                
                if(count==0){
                   addNewAnnotation(mapView, location: master)
                }
                count = count + 1
            }
        }
    }

    
    static func addNewAnnotation(_ mapView:MGLMapView, location: LocationMaster){
        
        //set speed and altiude globals
        globalSpeed.gSpeed = location.speed
        globalAltitude.gAltitude = location.altitude
        
        let newMarker = MGLPointAnnotation()
        newMarker.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        newMarker.title = "SpeedAltMarker"
        mapView.addAnnotation(newMarker)
        //location.marker = true
        
    }
    
    
    class func printSingleSpeedMarker( _ mapView:MGLMapView!, latitude: Double, longitude: Double, speed: Double){
        
        let newMarker = MGLPointAnnotation()
        newMarker.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        globalSpeed.gSpeed = speed
        mapView.addAnnotation(newMarker)
    }
    
    

    class func cameraDestination(_ latitude:CLLocationDegrees, longitude:CLLocationDegrees, fromDistance:Double, pitch:CGFloat, heading:Double) -> MGLMapCamera {
        
        let destination = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = MGLMapCamera(lookingAtCenter: destination, fromDistance: fromDistance, pitch: pitch, heading: heading)
        return camera
    }
    
    

    class func cameraAni(_ _LocationMaster:[LocationMaster]!, mapView:MGLMapView!){

        let cameray = MapUtils.cameraDestination(_LocationMaster[0].latitude, longitude:_LocationMaster[0].longitude, fromDistance:2300, pitch:60, heading:0)
        mapView.fly(to: cameray) {
            //code
        }
    }
    
    
    
    class func flyToLoactionSimple(_ latitude: Double, longitude: Double, mapView: MGLMapView!, distance: Double, pitch: Double){
    
        let cameray = MapUtils.cameraDestination(latitude, longitude: longitude, fromDistance: distance, pitch: CGFloat(pitch), heading:0)
        mapView.fly(to: cameray) {
            //finish code
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
    
    //Struct to hold static var, to identify running instances fo function and stop if needed
    struct Holder {
        static var staticInstance = ""
    }
    
    class func flyOverRoutes(_ _LocationMaster:[LocationMaster]!, mapView:MGLMapView!, n: Int, routeSlider: RouteSlider?, initInstance: String!, identifier: String, speedoMeter: Speedometer? ) {
        
        
        let count = _LocationMaster.count
        //var pitchCamera:CGFloat = 20.0
        var headingCourse:Double = _LocationMaster[n].course+globalHeading.gHeading
        //var arrayStep:Int = 5 // play ever n location from arr
        //var plabckCameraDuration:Double = 0.2
        // var cameraDistance = globalCamDistance.gCamDistance
        var distance = 0.0
        //print("INIT Instance: \(initInstance) / \(identifier)")
        

        
        //assign instance to global static
        Holder.staticInstance = initInstance
        
        
        /**
         *  Camera fly to fx
         **/
        func fly( _ nx:Int, pitch: CGFloat, heading:Double, instance: String){
            
            var n = nx
            let currentInstance:String = instance
            
            //print("FLY Instance: \(instance)")
            
            /* check if there are marker on the route point, when in autofly mode */
            if(_LocationMaster[n].marker == false && globalAutoplay.gAutoplay == true) {
                
                //  print("Notify send")
                let arrayN = [n]
                NotificationCenter.default.post(name: Notification.Name(rawValue: markerNotSetNotificationKey), object: arrayN)
                
            }
            
            
            //assign course of locationfor camera animation
            headingCourse = _LocationMaster[n].course+globalHeading.gHeading
            
            //get next array key by amoutn of arraySteps; default 1
            let nextIndex = n+globalArrayStep.gArrayStep < _LocationMaster.count ? n+globalArrayStep.gArrayStep : _LocationMaster.count-1
            
            //get distance from LocationMaster
            distance = _LocationMaster[n].distance
            
            //time spend on road
            let elapsedTime = _LocationMaster[nextIndex].timestamp.timeIntervalSince(_LocationMaster[0].timestamp as Date)
            let timespendString = Utils.clockFormat(Int(elapsedTime))
            
            //define camera for flyTo ani
            let camera = MapUtils.cameraDestination(_LocationMaster[n].latitude, longitude:_LocationMaster[n].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: heading)
            let speed = _LocationMaster[n].speed
            let speedIndex = Utils.getSpeedIndexFull(speed)
            
            globalSpeedSet.speedSet = speedIndex
            
            //update speedometer
            speedoMeter?.moveSpeedo(Double(Utils.getSpeed(_LocationMaster[n].speed)))
            
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
                //print("Slider Move \(n)")
                tmpRouteSlider.setLabel((Utils.distanceFormat(distance)), timeText: timespendString)
            }
            
            
            /**
             * Let it fly
             **/
            
            mapView.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {

                if( Holder.staticInstance != currentInstance){
                    // print("NOT EQUAL \( Holder.staticInstance) - \(currentInstance)")
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
    class func getBoundCoords(_ _locationsMaster:[LocationMaster]) -> (coordbound: MGLCoordinateBounds, coordboundArray: [CLLocationCoordinate2D], distance: Double, distanceFactor: Double) {
        
        
        //print("#################Coords")
        //print(_locationsMaster)
        
        //create new bound struct
        var newCoordBound = coordBound()
        var coordBounds = MGLCoordinateBounds()
        var coordBoundArray = [CLLocationCoordinate2D]()
        var distance = 0.0
        var distanceFactor = 1.8
        
        //loop if we have locations
        guard _locationsMaster.count > 4 else {
            print("GUARD bounds: locationRoute count 0")
            let coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 0, longitude: 0))
            
            return (coordBounds, coordBoundArray, distance, distanceFactor)
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
            if(location.longitude > newCoordBound.east){
                newCoordBound.east = location.longitude
            }
            
        }
        
        //make boundigbox as MGL Object and as simple Points Array
        coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: newCoordBound.south, longitude: newCoordBound.east), CLLocationCoordinate2D(latitude: newCoordBound.north, longitude: newCoordBound.west))
        
        coordBoundArray = [CLLocationCoordinate2D(latitude: newCoordBound.south, longitude: newCoordBound.east), CLLocationCoordinate2D(latitude: newCoordBound.north, longitude: newCoordBound.west), CLLocationCoordinate2D(latitude: newCoordBound.north, longitude: newCoordBound.east), CLLocationCoordinate2D(latitude: newCoordBound.south, longitude: newCoordBound.west)]
        
        
        
        //calc distances of boundigbox rectangle and orientation of rect (horizontal/portrai)
        //to get the correct zoomfactor for map
        let locationSE = CLLocation(latitude: newCoordBound.south, longitude: newCoordBound.east)
        let locationNW = CLLocation(latitude: newCoordBound.north, longitude: newCoordBound.west)
        let locationNE = CLLocation(latitude: newCoordBound.north, longitude: newCoordBound.east)
        let locationSW = CLLocation(latitude: newCoordBound.south, longitude: newCoordBound.west)
        
        // calc diagonal distance of boudnig box
        distance = locationNW.distance(from: locationSE)
        
        
        //cal distance horizontal/portrait bounding box orientation/ NW -> SW ort NW -> NE
        let distanceNorthSouth = locationNW.distance(from: locationSW)
        let distanceNorthEast = locationNW.distance(from: locationNE)
        
        distanceFactor = distanceNorthSouth > distanceNorthEast ? 1.3 : distanceFactor
        
        
        return (coordBounds, coordBoundArray, distance, distanceFactor)
        
    }
    
    
    /*
     * calculate the center point of multiple latitude longitude coordinate-pairs
     */
    class func getCenterFromBoundig(_ LocationPoints: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{
        
        var centerPoint = CLLocationCoordinate2D()
        
        //loop if we have locations
        guard LocationPoints.count > 3 else{
            print("GUARD getCenterFromBounding")
            centerPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0);
            return centerPoint
        }
        
        var x:Float = 0.0;
        var y:Float = 0.0;
        var z:Float = 0.0;
        
        for points in LocationPoints {
            
            let lat = GLKMathDegreesToRadians(Float(points.latitude));
            let long = GLKMathDegreesToRadians(Float(points.longitude));
            
            x += cos(lat) * cos(long);
            y += cos(lat) * sin(long);
            z += sin(lat);
        }
        
        x = x / Float(LocationPoints.count);
        y = y / Float(LocationPoints.count);
        z = z / Float(LocationPoints.count);
        
        let resultLong = atan2(y, x);
        let resultHyp = sqrt(x * x + y * y);
        let resultLat = atan2(z, resultHyp);
        
        centerPoint = CLLocationCoordinate2D(latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))), longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong))));
        
        return centerPoint;
    }
    
    
}
