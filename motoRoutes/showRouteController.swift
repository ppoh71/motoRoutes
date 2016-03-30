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
    @IBOutlet var flyButton:UIButton!
    @IBOutlet var SpeedLabel:UILabel!
    @IBOutlet var DistanceLabel:UILabel!
    @IBOutlet var TimeLabel:UILabel!
    @IBOutlet var AltitudeLabel:UILabel!
    @IBOutlet var cameraSlider:UISlider!
    
    @IBOutlet var mapViewShow: MGLMapView!
    
    // Get the default Realm
    let realm = try! Realm()
    
    // realm object list
    var motoRoute =  Route()
    var _LocationMaster = [LocationMaster]()
    
    //media stuff
    var markerImageName:String = ""
    
    
    //
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        
        
        globalCamDistance.gCamDistance = Double(50*currentValue)
        globalCamDuration.gCamDuration = Double(currentValue/1000) + 0.2
        globalArrayStep.gArrayStep = currentValue/10 > 1 ? currentValue/10 : 1
        globalCamPitch.gCamPitch = currentValue*2 < 80 ? CGFloat(currentValue*2 ) : 20.0
        
        print("Slider \(currentValue)")
        print("cam distance \(globalCamDistance.gCamDistance )")
        print("cam duration \(globalCamDuration.gCamDuration)")
        print("arraystep \(globalArrayStep.gArrayStep)")
        print("camPitch \(globalCamPitch.gCamPitch)")
        
    }
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        screenshotButton.tintColor = globalColor.gColor
        
        let x = CFAbsoluteTimeGetCurrent()
        //covert Realm LocationList to Location Master Object
        _LocationMaster = utils.masterRealmLocation(motoRoute.locationsList)
        
        print(utils.absolutePeromanceTime(x))
        print(_LocationMaster.count)
        
        //center mapview to route coords
        mapViewShow.zoomLevel = 9
        mapViewShow.camera.heading = 60
        
        mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: _LocationMaster[0].latitude, longitude: _LocationMaster[0].longitude),  animated: false)
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        mapFx.printRoute(_LocationMaster, mapView: mapViewShow)
        
        // Wait a bit before setting a new camera.
        mapFx.cameraAni(utils.masterRealmLocation(motoRoute.locationsList), mapView: mapViewShow)
        
        
        //Media Objects
        print("########MediaObjects \(motoRoute.mediaList)")
        
        
        for media in motoRoute.mediaList {
            
            let newMarker = MGLPointAnnotation()
            newMarker.coordinate = CLLocationCoordinate2DMake(media.latitude, media.longitude)
            newMarker.title = media.image
            
            markerImageName =  media.image
            
            mapViewShow.addAnnotation(newMarker)
            
        }
        
    }
    
    
    // new screenshot
    @IBAction func newScreenshot(sender: UIButton) {
        
        //make new screenshot from actual mapView
        let screenshotFilename = utils.screenshotMap(mapViewShow)
        
        //save new screenshot to realm
        print(motoRoute)
        try! realm.write {
            realm.create(Route.self, value: ["id": motoRoute.id, "image": screenshotFilename], update: true)
            
        }
    }
    
    
    // new screenshot
    @IBAction func flyRoute(sender: UIButton) {
        
        //make route fly
        print("let it fly")
        mapFx.flyOverRoutes(_LocationMaster, mapView: mapViewShow, SpeedLabel: SpeedLabel, DistanceLabel: DistanceLabel, TimeLabel: TimeLabel, AltitudeLabel: AltitudeLabel)
        
    }
    
    
}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        // Try to reuse the existing ‘pisa’ annotation image, if it exists
        let image = utils.loadImageFromName(markerImageName)
        let thumb = utils.resizeImage(image!, newWidth: 50)
        
        
        //let image = UIImage(named: "ic_info_48pt")!
        
        let  annotationImage = MGLAnnotationImage(image: thumb, reuseIdentifier: "pisa")
        
        
        // if annotationImage == nil {
        // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
        //     var image = annotationImage
        
        // The anchor point of an annotation is currently always the center. To
        // shift the anchor point to the bottom of the annotation, the image
        // asset includes transparent bottom padding equal to the original image
        // height.
        //
        // To make this padding non-interactive, we create another image object
        // with a custom alignment rect that excludes the padding.
        //      image = image!.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image!.size.height/2, 0))
        
        // Initialize the ‘pisa’ annotation image with the UIImage we just loaded
        //    annotationImage = MGLAnnotationImage(image: image!)
        //  }
        
        return annotationImage
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped
        return true
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