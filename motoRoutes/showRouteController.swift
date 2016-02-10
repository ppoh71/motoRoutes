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
    var speed:Double = 0 // need to draw colors on route

    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("showRouteController")
        //print(motoRoute)
        print(motoRoute.locationsList)
        
        //set chords for routes from
        var coords = [CLLocationCoordinate2D]()
        
        for location in motoRoute.locationsList {
            
            // keep only the last 2 coors in array, to draw colored speed sequcnces
            // + better performance of coord drawing
            if(coords.count==2){
               coords.removeAtIndex(0)
            }
            
            coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            
            //get speed for polyline color in mapview func
            speed = location.speed
           
            //create Polyline and add as annotation
            let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
            mapViewShow.addAnnotation(line)
            
        }
        
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
        return 5.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        return colorStyles.polylineColors(speed*3.6)
    }
}