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
import MapKit
import Mapbox

class showRouteController: UIViewController {
    
    //Outlets
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet weak var mapView: MGLMapView!
    
    
    // realm object list
    var motoRoute =  Route()
    
    var speed:Double = 0 // need to draw colors on route

    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("showRouteController")
        print(motoRoute)
        print(motoRoute.locationsList)
        //timer.invalidate()
        
        
        //set chords for routes from
        var coords = [CLLocationCoordinate2D]()
        
        for location in motoRoute.locationsList {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            
            
            //get speed for polyline color in mapview func
            speed = location.speed
            
            //create Polyline
            let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
            
            mapView.addAnnotation(line)
            
        }
        
        
        //center mapview by new coord
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: motoRoute.locationsList[0].latitude, longitude: motoRoute.locationsList[0].longitude),  zoomLevel: 11,  animated: false)
        
        /*
        //add map routes
        mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
        
        print(coords)
        
        
        //center map region
        let startLocation = CLLocationCoordinate2DMake(motoRoute.locationsList[0].latitude, motoRoute.locationsList[0].longitude)
        let region = MKCoordinateRegionMakeWithDistance(startLocation, 3000, 3000)
        mapView.setRegion(region, animated: true)

*/

        
        
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
        return 4.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        print("Color Annotion by speed: \(speed)")
        var polyColor:UIColor = colorStyles.polylineColors(speed*3.6)
        print(polyColor)
        
        return polyColor //speed mps to kmh
    }
}