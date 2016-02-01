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

class showRouteController: UIViewController {
    
    //Outlets
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    // realm object list
    var motoRoute =  Route()

    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("showRouteController")
        print(motoRoute.locationsList)
        //timer.invalidate()
        
        
        //set chords for routes from
        var coords = [CLLocationCoordinate2D]()
        
        for location in motoRoute.locationsList {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        
        //add map routes
        mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
        
        print(coords)
        
        
        //center map region
        let startLocation = CLLocationCoordinate2DMake(motoRoute.locationsList[0].latitude, motoRoute.locationsList[0].longitude)
        let region = MKCoordinateRegionMakeWithDistance(startLocation, 3000, 3000)
        mapView.setRegion(region, animated: true)

        
        
    }

}


// MARK: - MKMapViewDelegate
extension showRouteController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        print("mapview it is")
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5
        return renderer
    }
}