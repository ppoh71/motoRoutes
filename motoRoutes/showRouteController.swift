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
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("showRouteController")
        //print(motoRoute)
        //print(motoRoute.locationsList)
        
        //init speed set
        speedSet = Int(round(motoRoute.locationsList[0].speed/10))
        

        //init coords
        var coords = [CLLocationCoordinate2D]()
        
        
        for location in motoRoute.locationsList {
            
       
            //get speed index
            speedIndex = Int(round(location.speed/10))
            
           
            
          print("################### \(speedIndex) - \(speedSet)")
//            print(location)
//            print("################### \(speedIndex) - \(speedSet)")
            
            if(speedIndex == speedSet){ //put coord of same speed into choords
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                //print(coords)
            } else{
            
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                routeSpeeds.append(routeInfo(speed: speedSet, routes: coords))  //set dictonary for speed
                
                
               //   print("########## change")
                
//                print("########## \(speedSet)")
             //    print(routeSpeeds)
//                
                speedSet = speedIndex //set new speedindex
                coords = [CLLocationCoordinate2D]() //empty coords to get new coord for this speedindex
                
              //   print(coords)
                
                coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                
                //print(coords)
            
            }
            
            //append last elemnt, due it's not going into else statement
            routeSpeeds.append(routeInfo(speed: speedSet, routes: coords))  //set dictonary for speed
            

            // print("speedSet: \(speedSet)  speedIndex: \(speedIndex)" )
         
            /*
            // + better performance of coord drawing
            if(coords.count==3){
               coords.removeAtIndex(0)
            }
            
            coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            */
            
        }
        
      // print(speedDictonary)
      // print("############################ ")
       
        for speedRoutes in routeSpeeds {
          //  print("\(speedSet) ")
          //  print("\(speedRoutes.routes) ############################ ")
            
            var coords:[CLLocationCoordinate2D] = speedRoutes.routes
            
              speed = speedRoutes.speed
            
              let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
               mapViewShow.addAnnotation(line)

          }
      
        
        
        //create Polyline and add as annotation
        //let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
        //mapViewShow.addAnnotation(line)

      
        //center mapview by new coord
        mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: motoRoute.locationsList[0].latitude, longitude: motoRoute.locationsList[0].longitude),  zoomLevel: 13,  animated: false)
        
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
        
        return colorStyles.polylineColors(speed)
    }
}