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
    * print route
    */
    class func printRoute(motoRoutes:List<Location>!, mapView:MGLMapView!){
        
        // define speedIndex
        var speedIndex:Int = 0
        
        //get middel coord for camera animation
        let middleCoord:Location = motoRoutes[Int(round(Double(motoRoutes.count/2)))]
        
        
        //init coords
        var coords = [CLLocationCoordinate2D]()
        var cnt = 0
        
        
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: motoRoutes[0].latitude, longitude: motoRoutes[0].longitude),  zoomLevel: 8, direction: 40, animated: true)
        
        for location in motoRoutes {
            
            //get speed index
            speedIndex = utils.getSpeedIndex(location.speed)
            
            //add locations to coord woth the same speedIndex
            if(speedIndex == globalSpeedSet.speedSet){
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
            } else{ // if the speedIndex is different, at the last location and print the route
                
                cnt++
                
                //add first location with diff speedIndex to mind gaps
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
                //set new speedindex, also needed for coloring the routes
                globalSpeedSet.speedSet = speedIndex
                
                //print route polygon
                let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                mapView.addAnnotation(line)
                
                //print the coords for the last run
                print("counts: \(coords.count) - sppedindex \(globalSpeedSet.speedSet) - cnt \(cnt) ")
                
                coords = [CLLocationCoordinate2D]()
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
            }
            
        }
        
        
        if(coords.count>0){
            
            //set speedIndex
            globalSpeedSet.speedSet = speedIndex
            
            //print route polygon
            let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
            mapView.addAnnotation(line)
            
            //print the coords for the last run
            print("counts: \(coords.count) - sppedindex \(globalSpeedSet.speedSet) ")
            
        }
        //center mapview by new coord
        //zoom camaera to whole map
        
        
        print(" coord count  \(motoRoutes.count)")
        print(" coord \(Int(round(Double(motoRoutes.count/2))))")
        print("middel coord \(middleCoord)")
  
        
    }
    
    
    class func cameraAni(motoRoutes:List<Location>!, mapView:MGLMapView!){
    
        let middleCoord:Location = motoRoutes[Int(round(Double(motoRoutes.count/2)))]
        
        let sanJose = CLLocationCoordinate2D(latitude: motoRoutes[motoRoutes.count-1].latitude, longitude: motoRoutes[motoRoutes.count-1].longitude)
        let camera = MGLMapCamera(lookingAtCenterCoordinate: sanJose, fromEyeCoordinate: sanJose, eyeAltitude: 12000)
        mapView.flyToCamera(camera) {
            // Optionally catch a connecting flight
        }
        
        /*
        //create camera the map view is showing.
        let camera = MGLMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: middleCoord.latitude, longitude: middleCoord.longitude), fromDistance: 12000, pitch: 25, heading: 0)
        
        
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 6, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        */
    
    }
    
}