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


let markerNotSetNotificationKey = "motoRoutes.MarkerNotSet"


class showRouteController: UIViewController {
    
    //Outlets
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var screenshotButton:UIButton!
    @IBOutlet var flyButton:UIButton!
    //@IBOutlet var SpeedLabel:UILabel!
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
    var timer = NSTimer()
    var timeIntervalMarker = 0.00051
    var performanceTime:Double = 0
    
    //Debug Label
    var debugTimer = NSTimer()
    var debugSeconds = 0
    
    var speedoMeter = Speedometer()
    

    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x = CFAbsoluteTimeGetCurrent()
        
        //color speed label
        screenshotButton.tintColor = globalColor.gColor
        
        
        //get screensize
        /*
        l
        let speedoWidth = 10
        let SpeedometerImage = imageUtils.makeSpeedometerImage(speedoWidth, height: Int(screenHeight))
        speedoMeter = UIImageView(image: SpeedometerImage)
        speedoMeter.frame = CGRect(x: 0, y: 0, width: speedoWidth, height: Int(screenHeight))
        speedoMeter.tag = 1
        view.addSubview(speedoMeter)
        */
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //let screenWidth = screenSize.width
        var  screenHeight = screenSize.height/2
        //screenHeight = 200
        let speedoWidth:Int = 10
        print("Screenheigth \(screenHeight)")
        speedoMeter.backgroundColor = UIColor.blueColor()
        
        speedoMeter.frame = CGRect(x: 0, y: 100, width: speedoWidth, height: Int(screenHeight))
        speedoMeter.setup(speedoWidth, height: Int(screenHeight))
        
        view.addSubview(speedoMeter)
        
        
        //set max on route slider
        routeSlider.maximumValue = Float(motoRoute.locationsList.count-1)
       
        //covert Realm LocationList to Location Master Object
        RouteList =  RouteMaster.createMasterLocationRealm(motoRoute.locationsList)
       
        print(utils.absolutePeromanceTime(x))
        print("List count \(RouteList.count)")
        
        //center mapview to route coords
        mapViewShow.zoomLevel = 9
        mapViewShow.camera.heading = globalHeading.gHeading
 
        mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: RouteList[0].latitude, longitude: RouteList[0].longitude),  animated: false)
        
        // Toggle Camera recognizer
        toggleImageViewGesture.direction = .Right
        toggleImageViewGesture.addTarget(self, action: #selector(showRouteController.togglePhotoView))
        routeImageView.addGestureRecognizer(toggleImageViewGesture)
        routeImageView.userInteractionEnabled = true
        
        //slider drag end of route slider
        routeSlider.addTarget(self, action: #selector(showRouteController.touchUpRouteSlide), forControlEvents: UIControlEvents.TouchUpInside)
        routeSlider.addTarget(self, action: #selector(showRouteController.touchUpRouteSlide), forControlEvents: UIControlEvents.TouchUpOutside)
        routeSlider.addTarget(self, action: #selector(showRouteController.touchDowntRouteSlide), forControlEvents: UIControlEvents.TouchDown)
        
        //Listen from FlyoverRoutes if Markers are set
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showRouteController.switchFromFly2PrintMarker), name: markerNotSetNotificationKey, object: nil)
        
    }
    

    
    override func viewDidAppear(animated: Bool) {
        
        //print the route in 1 color
        mapUtils.printRouteOneColor(RouteList, mapView: mapViewShow)
        
        //define camera and set for flyTo ani
        let camera = mapUtils.cameraDestination(RouteList[0].latitude, longitude:RouteList[0].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: RouteList[0].course + globalHeading.gHeading)
        
        mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        
        //mapUtils.cameraAni(utils.masterRealmLocation(motoRoute.locationsList), mapView: mapViewShow)
        //Media Objects
        //print("########MediaObjects \(motoRoute.mediaList)")
    }

    
    
    //Camera Slider value changes
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        
        globalCamDistance.gCamDistance = Double(200*currentValue)
        globalCamDuration.gCamDuration = Double(currentValue/1000) + 0.2
//      globalArrayStep.gArrayStep = currentValue/10 > 1 ? currentValue/10 : 1
        globalCamPitch.gCamPitch = currentValue*2 < 80 ? CGFloat(60 ) : 60.0
        
        //zoom camera also when not flying,
        if( globalAutoplay.gAutoplay==false && flyButton.selected==false ) {
        
            //get current center coords
            let centerCoords = mapViewShow.centerCoordinate
            
            //define camera and flyTo with zoom level
            let camera = mapUtils.cameraDestination(centerCoords.latitude, longitude:centerCoords.longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: 40)
            mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))

           // print("\(mapViewShow.centerCoordinate)")
        }
        
      //  mapViewShow.setZoomLevel(Double(currentValue/10), animated: true)
        
    }
    
    
    //Route Slider value changed
    @IBAction func sliderRouteChanged(sender: UISlider) {
        
        //get slider value as int
        sliceStart = Int(sender.value)
        
        //routeSlider.setValues()
        //stop camera flightm when selecting new route point
        globalAutoplay.gAutoplay = false
        
        //fly to route n destination
        mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliceStart, routeSlider: routeSlider, initInstance: utils.getUniqueUUID(), identifier: "i1", speedoMeter: speedoMeter)
        //print("Slider Route value \(sliderRouteValue)")
        
       

        
    }
    

    //touch event for rourte slider
    func touchDowntRouteSlide(){
        stopAll()
        print("touch down stopall()")
    }
    
    //touch event for rourte slider
    func touchUpRouteSlide(){
        //StartStop(true)
        print("touch up slide, nothing")
    }
    
    //update debug label
    func updateDebugLabel(){
        print("dwbug")
        debugSeconds += 1
        debugLabel.text = "\(debugSeconds) / \(sliceStart) "
    }
    
    
    //start marker timer
    func startMarkerTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalMarker, target: self, selector: #selector(showRouteController.printMarker), userInfo: nil, repeats: true)
    }
    
    //start debug timer
    func startDebugTimer(){
        debugTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(showRouteController.updateDebugLabel), userInfo: nil, repeats: true)
    }
    
    
    //stop all running Timer flying cameras
    func stopAll(){
        print("stopAll")
        timer.invalidate()
        debugTimer.invalidate()
        globalAutoplay.gAutoplay =  false
        flyButton.selected = false
    }
    
    //notifycenter func: when no marker while flying over routesm switch to stop all and start marker printing
    func switchFromFly2PrintMarker(notification: NSNotification){
        
        //get object from notification
        let arrayObject =  notification.object as! [AnyObject]
        
        if let receivedKey = arrayObject[0] as? Int {
        
            //set new sliceStartKey
            sliceStart = receivedKey
            print("Notify received Func \(receivedKey)")
            stopAll()
            StartStop(true)
        }
            //print("Notify received Func \(nRoute)")
    }
    
    //function print marker
    func printMarker(){
        
        let counterStep = sliceAmount // when to fly next marker
   
        //if not at end of array
        if( RouteList.count > sliceStart+sliceAmount){
            
            //Print Marker if not already set
            if(RouteList[sliceStart].marker==false){
            
                print("timer running and printeing routes \(sliceStart)")
                
                
                //print marker
                mapUtils.printSpeedMarker(RouteList, mapView: mapViewShow,  key:  sliceStart, amount: sliceAmount)
                sliceStart += sliceAmount //move array to next route
                count+=1 //counter to center map, fly camer to marker
                
                //fly camera to current marker
                if(count==counterStep){
                    
                    //stop timer, flyto route and re-init timer, set counter to zero
                    timer.invalidate()
                    mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliceStart, routeSlider: routeSlider, initInstance: utils.getUniqueUUID(), identifier: "i2", speedoMeter: speedoMeter)
                    count=0
                    startMarkerTimer()
                }
            
            } else{ //if marker is already set
            
                print("marker already set start fly")
                
                stopAll()
                startFlytoAuto()
                //start flyto with autoplay
            }
     

        } else{ // end of array
         //print("All Marker took: \(utils.absolutePeromanceTime(performanceTime)) ")
         stopAll()
        }
    }
    
    
    //start auto fly over routes when marker are set
    func startFlytoAuto(){
        
        flyButton.selected = true
        globalAutoplay.gAutoplay =  true
        
        //make route fly
        mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliceStart, routeSlider: routeSlider, initInstance: utils.getUniqueUUID(), identifier: "i3", speedoMeter: speedoMeter)
    
    }
    

    
    //start/stop button function
    func StartStop(active: Bool){
        

        
        if (active){
            startMarkerTimer()
            startDebugTimer()
            flyButton.selected = true
            
        } else{
             stopAll()
              }
        
    }
    
    
    // new screenshot
    @IBAction func flyRoute(sender: UIButton) {
        
      
        
        sender.selected = !sender.selected;
        sender.highlighted = !sender.highlighted
        
        print("play button \(sender.selected)")
        
        StartStop(sender.selected )
        
        
        //switch
        //globalAutoplay.gAutoplay = globalAutoplay.gAutoplay==false ? true : false
        
        //make route fly
        //print("let it fly")
        //mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliderRouteValue, SpeedLabel: SpeedLabel, routeSlider: routeSlider)
        
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
        
        
        /*
        if let imgNameAnnotation:String = annotation.subtitle!! {
            let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgNameAnnotation)
            let image = imageUtils.loadImageFromPath(imgPath)
        
            //show image
            routeImageView.image = image
            togglePhotoView()
        
            //deselect annotation
        mapView.deselectAnnotation(annotation, animated: false)
        }
 */
        
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
        return colorUtils.polylineColors(utils.getSpeedIndexFull(globalSpeed.gSpeed))
    }
    
}