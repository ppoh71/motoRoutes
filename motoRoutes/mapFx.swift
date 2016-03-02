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
    
    
    
    
    
    class func cameraAni(motoRoutes:List<Location>!, mapView:MGLMapView!){
    
        
        //let middleCoord:Location = motoRoutes[Int(round(Double(motoRoutes.count/2)))]
        
      //  let destination = CLLocationCoordinate2D(latitude: motoRoutes[0].latitude, longitude: motoRoutes[0].longitude)
        
      //  let destination2 = CLLocationCoordinate2D(latitude: motoRoutes[motoRoutes.count-1].latitude, longitude: motoRoutes[motoRoutes.count-1].longitude)
        
        //let camera = MGLMapCamera(lookingAtCenterCoordinate: destination, fromEyeCoordinate: destination2, eyeAltitude: 20000)
       // let camera2 = MGLMapCamera(lookingAtCenterCoordinate: destination2, fromDistance: 5000, pitch: 20, heading: 0)
      
     
        //let camera = MGLMapCamera(lookingAtCenterCoordinate: destination, fromDistance: 6000, pitch: 80, heading: 110)
        
        
        let camerax = mapFx.cameraDestination(motoRoutes[0].latitude, longitude:motoRoutes[0].longitude, fromDistance:5000, pitch:20, heading:0)
        
        
        let cameray = mapFx.cameraDestination(motoRoutes[motoRoutes.count-1].latitude, longitude:motoRoutes[motoRoutes.count-1].longitude, fromDistance:5000, pitch:20, heading:0)
        
        
        mapView.flyToCamera(camerax) {
            // Optionally catch a connecting flight
            //  print("connection flight")
            mapView.flyToCamera(cameray){
                
            } 
        }
  
      
        /*
        //create camera the map view is showing.
        let camera = MGLMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: middleCoord.latitude, longitude: middleCoord.longitude), fromDistance: 12000, pitch: 25, heading: 0)
        
        
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 6, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        */
    
    }
    
}