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
        print("Printing Route took \(utils.absolutePeromanceTime(x)) milliseconds")
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
        
        
        let cameray = mapFx.cameraDestination(_LocationMaster[_LocationMaster.count/2].latitude, longitude:_LocationMaster[_LocationMaster.count/2].longitude, fromDistance:10000, pitch:30, heading:0)
        
        
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
    *
    *
    **/
    class func flyOverRoutes(_LocationMaster:[LocationMaster]!, mapView:MGLMapView!) {
    
    
        let count = _LocationMaster.count
        var n = 0
        var pitchCamera:CGFloat = 60.0
        var pitch:CGFloat = 10
 
        
        func fly(var n:Int, pitch: CGFloat){
        
            let camera = mapFx.cameraDestination(_LocationMaster[n].latitude, longitude:_LocationMaster[n].longitude, fromDistance:3000, pitch: pitchCamera, heading:0)
            
            mapView.flyToCamera(camera) {
                
                if(n<count){
                    print(arc4random() % 100)
                   // pitch = CGFloat(arc4random() % 100)
                    n++
                    fly(n, pitch: pitchCamera)
                }
            }
        }
        
    
       fly(n, pitch: pitchCamera)
        

    }
    
    
    
}