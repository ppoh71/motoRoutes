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
    @IBOutlet var screenshotButton:UIButton!
    @IBOutlet var mapViewShow: MGLMapView!
    
    // Get the default Realm
    let realm = try! Realm()
    
    // realm object list
    var motoRoute =  Route()
   
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
     
        let x = CFAbsoluteTimeGetCurrent()
        //covert Realm LocationList to Location Master Object
        let _LocationMaster = utils.masterRealmLocation(motoRoute.locationsList)
        print(utils.absolutePeromanceTime(x))
        print(_LocationMaster.count)
        
        //center mapview to route coords
        mapViewShow.zoomLevel = 10
        mapViewShow.camera.heading = 180
        
        mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: _LocationMaster[0].latitude, longitude: _LocationMaster[0].longitude),  animated: false)
        
        mapFx.printRoute(_LocationMaster, mapView: mapViewShow)
        

        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Wait a bit before setting a new camera.
        mapFx.cameraAni(utils.masterRealmLocation(motoRoute.locationsList), mapView: mapViewShow)
        
        

    }
    
    
    // save route
    @IBAction func newScreenshot(sender: UIButton) {
        
        //make new screenshot from actual mapView
        let screenshotFilename = utils.screenshotMap(mapViewShow)
        
        //save new screenshot to realm
        print(motoRoute)
        try! realm.write {
            realm.create(Route.self, value: ["id": motoRoute.id, "image": screenshotFilename], update: true)
            
        }
        

        
    }
    

}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    func mapViewDidFailLoadingMap(mapView: MGLMapView, withError error: NSError) {
        print("Erro r ")
    }
    
    func mapViewWillStartRenderingFrame(mapView: MGLMapView) {
       // print("WillStartRenderingFrame")
    }
    
    func mapViewDidFinishRenderingFrame(mapView: MGLMapView, fullyRendered: Bool) {
       // print("DidFinishRenderingFrame")
    }
    
    func mapViewWillStartLoadingMap(mapView: MGLMapView) {
        //print("WillStartLoadingMap")
        //  print(mapView.debugDescription)
    }
    
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        //print("region changed")
    }
    
    
    func mapViewWillStartRenderingMap(mapView: MGLMapView) {
        //print("will start render map")
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