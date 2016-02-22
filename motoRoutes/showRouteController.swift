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
        
        
        mapFx.printRoute(motoRoute.locationsList, mapView: mapViewShow)
        

        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Wait a bit before setting a new camera.
    
        
        mapFx.cameraAni(motoRoute.locationsList, mapView: mapViewShow)
        
        //create camera the map view is showing.
      //  let camera = MGLMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: middleCoord.latitude, longitude: middleCoord.longitude), fromDistance: 12000, pitch: 25, heading: 0)
        
        // Animate the camera movement over 5 seconds.
       // mapViewShow.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    
    }
    

}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    func mapViewDidFailLoadingMap(mapView: MGLMapView, withError error: NSError) {
        print("Erro r ")
    }
    
    func mapViewWillStartRenderingFrame(mapView: MGLMapView) {
        print("WillStartRenderingFrame")
    }
    
    func mapViewDidFinishRenderingFrame(mapView: MGLMapView, fullyRendered: Bool) {
        print("DidFinishRenderingFrame")
    }
    
    func mapViewWillStartLoadingMap(mapView: MGLMapView) {
        print("WillStartLoadingMap")
        //  print(mapView.debugDescription)
    }
    
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        print("region changed")
    }
    
    
    func mapViewWillStartRenderingMap(mapView: MGLMapView) {
        print("will start render map")
    }

    
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
        
        return colorStyles.polylineColors(globalSpeedSet.speedSet)
    }
}