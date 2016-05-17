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
    @IBOutlet var cameraSlider:UISlider!{
        didSet{
            cameraSlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        }
    }
    @IBOutlet var routeSlider:RouteSlider!{
        didSet{
           routeSlider.setLabel("0.000", timeText: "00:00")
        }
    }
    @IBOutlet var routeImageView:UIImageView!
    @IBOutlet var AddMarker:UIButton!
    @IBOutlet var MinusMarker:UIButton!
    @IBOutlet var mapViewShow: MGLMapView!
    @IBOutlet var debugLabel: UILabel!
    
    @IBOutlet var optionsButton: UIButton!
    

    
    //add gesture
    var toggleImageViewGesture = UISwipeGestureRecognizer()

    // Get the default Realm
    let realm = try! Realm()
    
    // realm object list
    var motoRoute =  Route()
    var RouteList = RouteMaster()._RouteList

    
    //media stuff
    var markerImageName:String = ""
    
    //slider route value
    var sliderRouteValue = 0
    
    var sliceStart = 0
    var sliceAmount = 1
    var key = 0
    var count:Int = 0
    lazy var timer = NSTimer()
    var timeIntervalMarker = 0.00051
    lazy var performanceTime:Double = 0
    
    //Debug Label
    var debugTimer = NSTimer()
    var debugSeconds = 0
    

    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x = CFAbsoluteTimeGetCurrent()
        
        //color speed label
        screenshotButton.tintColor = globalColor.gColor
        
        //set max on route slider
        routeSlider.maximumValue = Float(motoRoute.locationsList.count-1)
       
        
        //covert Realm LocationList to Location Master Object
        RouteList =  RouteMaster.createMasterLocationRealm(motoRoute.locationsList)
       
        print(utils.absolutePeromanceTime(x))
        print("List count \(RouteList.count)")
        
        //center mapview to route coords
        mapViewShow.zoomLevel = 9
        mapViewShow.camera.heading = 60
 
        
        
        mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: RouteList[0].latitude, longitude: RouteList[0].longitude),  animated: false)
        
        // Toggle Camera recognizer
        toggleImageViewGesture.direction = .Right
        toggleImageViewGesture.addTarget(self, action: #selector(showRouteController.togglePhotoView))
        routeImageView.addGestureRecognizer(toggleImageViewGesture)
        routeImageView.userInteractionEnabled = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //init route slider label

        
        mapUtils.printRouteOneColor(RouteList, mapView: mapViewShow)
        
        //define camera for flyTo ani
        let camera = mapUtils.cameraDestination(RouteList[0].latitude, longitude:RouteList[0].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: 40)
        
        mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        
        
        //mapUtils.cameraAni(utils.masterRealmLocation(motoRoute.locationsList), mapView: mapViewShow)
        
        //Media Objects
        //print("########MediaObjects \(motoRoute.mediaList)")
        
    }

    
    
    
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        
        
        globalCamDistance.gCamDistance = Double(200*currentValue)
        globalCamDuration.gCamDuration = Double(currentValue/1000) + 0.2
//        globalArrayStep.gArrayStep = currentValue/10 > 1 ? currentValue/10 : 1
        globalCamPitch.gCamPitch = currentValue*2 < 80 ? CGFloat(60 ) : 60.0
        
        print("Slider Camera Position \(currentValue)")
        //print("cam distance \(globalCamDistance.gCamDistance )")
        //print("cam duration \(globalCamDuration.gCamDuration)")
        //print("arraystep \(globalArrayStep.gArrayStep)")
        //print("camPitch \(globalCamPitch.gCamPitch)")
        
        //zoom camera also when not flying,
        if(globalAutoplay.gAutoplay==false) {
        
            //get current center coords
            let centerCoords = mapViewShow.centerCoordinate
            
            //define camera and flyTo with zoom level
            let camera = mapUtils.cameraDestination(centerCoords.latitude, longitude:centerCoords.longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: 40)
            mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))

            print("\(mapViewShow.centerCoordinate)")
        }
        
      //  mapViewShow.setZoomLevel(Double(currentValue/10), animated: true)
        
    }
    
    
    //
    @IBAction func sliderRouteChanged(sender: UISlider) {
        
        //get slider value as int
        sliderRouteValue = Int(sender.value)
        
        //routeSlider.setValues()
        //stop camera flightm when selecting new route point
        globalAutoplay.gAutoplay = false
        
        //set the route array start
        sliceStart = sliderRouteValue
        
        mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliderRouteValue,  SpeedLabel: SpeedLabel, routeSlider: routeSlider )
        
        //print("Slider Route \(sliderRouteValue)")

        
    }
    
    @IBAction func addMarker(sender: UIButton) {
        
        //print("Slice Amount \(sliceAmount)")
 
        startMarkerTimer()
    }
    
    
    func updateDebugLabel(){
        
        debugSeconds += 1
        debugLabel.text = "\(debugSeconds) / \(sliceStart) / "
    }
    
    
    
    
    func startMarkerTimer(){
        //var key = self.sliceStart
        performanceTime = CFAbsoluteTimeGetCurrent()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalMarker, target: self, selector: #selector(showRouteController.printIt), userInfo: nil, repeats: true)
        debugTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(showRouteController.updateDebugLabel), userInfo: nil, repeats: true)

    }
    
    
    
    func printIt(){
        
        print("\(sliceStart)")
        let counterStep = sliceAmount
      
        if( RouteList.count > sliceStart+sliceAmount){
            
            mapUtils.printSpeedMarker(RouteList, mapView: mapViewShow,  key:  sliceStart, amount: sliceAmount, RouteSlider: routeSlider)
            sliceStart += sliceAmount
            count+=1
            
            if(count==counterStep){
                timer.invalidate()
                debugTimer.invalidate()
                let flying = mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliceStart, SpeedLabel: SpeedLabel, routeSlider: routeSlider)
                count=0
                print("\(flying)")
                startMarkerTimer()
            }
            

        } else{
        
         //print("All Marker took: \(utils.absolutePeromanceTime(performanceTime)) ")
         timer.invalidate()
         debugTimer.invalidate()
            
        }
    }
    
    
    @IBAction func stopMarker(sender: UIButton){
    
        timer.invalidate()
        debugTimer.invalidate()
        /* for loc in RouteList {
          print("Marker: \(loc.marker)")
        } */
    }
    
    
    @IBAction func removewMarker(sender: UIButton) {
        
        for annotation in mapViewShow.annotations!{
            
            //print("\(annotation.title)")
            mapViewShow.removeAnnotation(annotation)
            
        }
        

        timer.invalidate()
        debugTimer.invalidate()
        sliceStart = 0
        debugSeconds = 0
        
       // print("\(sliceStart)")
    }
    
    
   
    
    // new screenshot
    @IBAction func newScreenshot(sender: UIButton) {
        
        //make new screenshot from actual mapView
        let screenshotFilename = imageUtils.screenshotMap(mapViewShow)
        
        //save new screenshot to realm
        //print(motoRoute)
        try! realm.write {
            realm.create(Route.self, value: ["id": motoRoute.id, "image": screenshotFilename], update: true)
            
        }
    }
    
    
    // new screenshot
    @IBAction func flyRoute(sender: UIButton) {
        
        
        //switch
        globalAutoplay.gAutoplay = globalAutoplay.gAutoplay==false ? true : false
        
        //make route fly
        //print("let it fly")
        mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliderRouteValue, SpeedLabel: SpeedLabel, routeSlider: routeSlider)
        
        
        
    }
    
    
    func togglePhotoView(){
    
    
        let animateX:CGFloat = self.routeImageView.frame.origin.x<100 ? 320 : -320; //animnate x var
        //print("x: \(self.routeImageView.frame.origin.x)")
    
        //aimate view
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.routeImageView.transform = CGAffineTransformMakeTranslation(animateX, 0)
            
            }, completion: nil)
    
        //print("x: \(self.routeImageView.frame.origin.x)")
        
    }
    
    

    
    /*
     * Prepare Segue / camera stuff
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        //prepare for camera/photo store to MediaObhect
        if segue.identifier == "showRouteOptions" {
          //  let destinationController = segue.destinationViewController as! motoRouteOptions
      
            
            
        }
    }
    
    
    /*
     * Close segue
     */
    @IBAction func close(segue:UIStoryboardSegue) {
        
        print("close \(segue.sourceViewController)")
        
        if let optionController = segue.sourceViewController as? motoRouteOptions {
            
            print("close sliceAmount \(optionController.sliceAmount)")
            
            sliceAmount = optionController.sliceAmount
            timeIntervalMarker = optionController.timeIntervalMarker
            
            
        }
    }

    
    
    
    
}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        //Try to reuse the existing ‘pisa’ annotation image, if it exists
        //var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("routeline\(utils.getSpeed(globalSpeed.gSpeed))")
        
        let image = imageUtils.drawLineOnImage()
        let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "routeline\(utils.getSpeed(globalSpeed.gSpeed))")


       
         return annotationImage
 }
    
    
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        
        //print("annotation")
      //  print(" a \(annotation.subtitle!!)")
        
        if let imgNameAnnotation:String = annotation.subtitle!! {
            let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgNameAnnotation)
            let image = imageUtils.loadImageFromPath(imgPath)
        
            //show image
            routeImageView.image = image
            togglePhotoView()
        
            //deselect annotation
        mapView.deselectAnnotation(annotation, animated: false)
        }
        
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
        return 7.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        //let speedIndex =  Int(round(speed/10))
        return colorUtils.polylineColors(globalSpeedSet.speedSet)
    }
    
}