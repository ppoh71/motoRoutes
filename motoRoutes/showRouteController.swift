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
    @IBOutlet var routeSlider:UISlider!
    @IBOutlet var routeImageView:UIImageView!
    
    @IBOutlet var mapViewShow: MGLMapView!
    
    //add gesture
    var toggleImageViewGesture = UISwipeGestureRecognizer()

    
    // Get the default Realm
    let realm = try! Realm()
    
    // realm object list
    var motoRoute =  Route()
    var _LocationMaster = [LocationMaster]()
    
    //media stuff
    var markerImageName:String = ""
    
    //slider route value
    var sliderRouteValue = 0
    
    
    //
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        
        
        globalCamDistance.gCamDistance = Double(200*currentValue)
        globalCamDuration.gCamDuration = Double(currentValue/1000) + 0.2
        globalArrayStep.gArrayStep = currentValue/10 > 1 ? currentValue/10 : 1
        globalCamPitch.gCamPitch = currentValue*2 < 80 ? CGFloat(60 ) : 60.0
        
        print("Slider Camera Position \(currentValue)")
        print("cam distance \(globalCamDistance.gCamDistance )")
        print("cam duration \(globalCamDuration.gCamDuration)")
        print("arraystep \(globalArrayStep.gArrayStep)")
        print("camPitch \(globalCamPitch.gCamPitch)")
        
    }
    
    
    //
    @IBAction func sliderRouteChanged(sender: UISlider) {
        sliderRouteValue = Int(sender.value)
        
        globalAutoplay.gAutoplay = false
        
        mapFx.flyOverRoutes(_LocationMaster, mapView: mapViewShow, n: sliderRouteValue,  SpeedLabel: SpeedLabel, DistanceLabel: DistanceLabel, TimeLabel: TimeLabel, AltitudeLabel: AltitudeLabel, RouteSlider: routeSlider )
        
        print("Slider Route \(sliderRouteValue)")

        
    }
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //color speed label
        screenshotButton.tintColor = globalColor.gColor
        
        //set max on route slider
        routeSlider.maximumValue = Float(motoRoute.locationsList.count-1)
        
        
        //let x = CFAbsoluteTimeGetCurrent()
        //covert Realm LocationList to Location Master Object
        _LocationMaster = utils.masterRealmLocation(motoRoute.locationsList)
        
        //print(utils.absolutePeromanceTime(x))
        print(_LocationMaster.count)
        
        //center mapview to route coords
        mapViewShow.zoomLevel = 9
        mapViewShow.camera.heading = 60


        
        mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: _LocationMaster[0].latitude, longitude: _LocationMaster[0].longitude),  animated: false)
        
        // Toggle Camera recognizer
        toggleImageViewGesture.direction = .Right
        toggleImageViewGesture.addTarget(self, action: #selector(showRouteController.togglePhotoView))
        routeImageView.addGestureRecognizer(toggleImageViewGesture)
        routeImageView.userInteractionEnabled = true
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        mapFx.printRoute(_LocationMaster, mapView: mapViewShow)
        
        //mapFx.cameraAni(utils.masterRealmLocation(motoRoute.locationsList), mapView: mapViewShow)
        
        
        //Media Objects
        //print("########MediaObjects \(motoRoute.mediaList)")
        
        
        for media in _LocationMaster {
            
            let newMarker = MGLPointAnnotation()

            newMarker.coordinate = CLLocationCoordinate2DMake(media.latitude, media.longitude)
            newMarker.subtitle = "route marker"
            // newMarker.subtitle = media.image
            // newMarker.description = media.image
            
            globalLineAltitude.gLineAltitude = media.altitude
            globalSpeed.gSpeed = media.speed
            
            //markerImageName =  media.image
      
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
        
        
        //switch
        globalAutoplay.gAutoplay = globalAutoplay.gAutoplay==false ? true : false
        
        //make route fly
        print("let it fly")
        mapFx.flyOverRoutes(_LocationMaster, mapView: mapViewShow, n: sliderRouteValue, SpeedLabel: SpeedLabel, DistanceLabel: DistanceLabel, TimeLabel: TimeLabel, AltitudeLabel: AltitudeLabel, RouteSlider: routeSlider)
        
        
        
    }
    
    
    func togglePhotoView(){
    
    
        let animateX:CGFloat = self.routeImageView.frame.origin.x<100 ? 320 : -320; //animnate x var
        print("x: \(self.routeImageView.frame.origin.x)")
    
        //aimate view
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.routeImageView.transform = CGAffineTransformMakeTranslation(animateX, 0)
            
            }, completion: nil)
    
        print("x: \(self.routeImageView.frame.origin.x)")
        
    }
    
}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    
  
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        // Try to reuse the existing ‘pisa’ annotation image, if it exists
        //let image = utils.loadImageFromName(markerImageName)
       //  var image = UIImage(named: "line.png")!
       //let divheight = CGFloat((rand()%20)+1)
       let image = utils.drawLineOnImage()

       let  annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "routeline\(utils.getSpeed(globalSpeed.gSpeed))")
       
        // print("divheight: \(globalLineAltitude.gLineAltitude)")
        /*
         if annotationImage == nil {
            
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
          //  var image = UIImage(named: "line2")!
            var image = utils.drawLineOnImage()
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
                
         
            
           // image = utils.scaleImage(image, toSize: CGSizeMake(1,divheight))
            //image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(13, 37, 13, 37))
            //image = image.resizableImageWithCapInsets(UIEdgeInsets(top: 8, left: 8, bottom: image.size.height*2, right: 8), resizingMode: .Stretch)
            
            //let thumb = utils.resizeImage(image, newWidth: rand(0, 50))
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "line-\(divheight)")
        
            print(image.size.height)

        }
       */
         return annotationImage
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        
        print("annotation")
      //  print(" a \(annotation.subtitle!!)")
        let imgNameAnnotation = annotation.subtitle!!
        let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgNameAnnotation)
        let image = utils.loadImageFromPath(imgPath)
        
        //show image
        routeImageView.image = image
        togglePhotoView()
        
        //deselect annotation
        mapView.deselectAnnotation(annotation, animated: false)
        
        
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
        return colorStyles.polylineColors(0)
    }
    
}