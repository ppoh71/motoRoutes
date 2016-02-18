//
//  showRouteController.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 01.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import RealmSwift
import Mapbox
import Crashlytics

class showRouteController: UIViewController {
    
    //Outlets
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var mapViewShow: MGLMapView!
    
    // realm object list
    var motoRoute =  Route()
    var speed:Int = 0 // need to draw colors on route
    var speedIndex:Int = 0
    var speedSet:Int = 0
    var speedDictonary = [[(Int, [CLLocationCoordinate2D])]]()
    
    struct routeInfo {
        var speed : Int
        var routes : [CLLocationCoordinate2D]
    }

    
    var routeSpeeds = [routeInfo]()
    var middleCoord = Location()
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //init speedIndex
        speedSet = utils.getSpeedIndex(motoRoute.locationsList[0].speed)
        
        print("route counts: \(motoRoute.locationsList.count) ")

        //init coords
        var coords = [CLLocationCoordinate2D]()
        var cnt = 0
        
        
        for location in motoRoute.locationsList {
            
            //get speed index
            speedIndex = utils.getSpeedIndex(location.speed)
            
            //add locations to coord woth the same speedIndex
            if(speedIndex == speedSet){
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
            } else{ // if the speedIndex is different, at the last location and print the route
            
                cnt++
                
                //add first location with diff speedIndex to mind gaps
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
       
                //set new speedindex, also needed for coloring the routes
                speedSet = speedIndex
                
                //print route polygon
                let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                mapViewShow.addAnnotation(line)

                //print the coords for the last run
                print("counts: \(coords.count) - sppedindex \(speedSet) - cnt \(cnt) ")
                
                coords = [CLLocationCoordinate2D]()
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            
                

            }
            
        }
        
        
        if(coords.count>0){
            
            //set speedIndex
            speedSet = speedIndex
            
            //print route polygon
            let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
            mapViewShow.addAnnotation(line)
            
            //print the coords for the last run
            print("counts: \(coords.count) - sppedindex \(speedSet) ")

        }
        
      
        
        //center mapview by new coord
        //zoom camaera to whole map
        middleCoord = motoRoute.locationsList[Int(round(Double(motoRoute.locationsList.count/2)))]
        
        print(" coord count  \(motoRoute.locationsList.count)")
        print(" coord \(Int(round(Double(motoRoute.locationsList.count/2))))")
        print("middel coord \(middleCoord)")
        
            mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: middleCoord.latitude, longitude: middleCoord.longitude),  zoomLevel: 10, direction: 40, animated: true)
        
       


        
       // mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: motoRoute.locationsList[0].latitude, longitude: motoRoute.locationsList[0].longitude),  zoomLevel: 13,  animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Wait a bit before setting a new camera.
    
        //create camera the map view is showing.
        let camera = MGLMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: middleCoord.latitude, longitude: middleCoord.longitude), fromDistance: 12000, pitch: 25, heading: 0)
        
        // Animate the camera movement over 5 seconds.
        mapViewShow.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    
    }
    

}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 8.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        //let speedIndex =  Int(round(speed/10))
        
        return colorStyles.polylineColors(speedSet)
    }
}