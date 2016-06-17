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
import pop


let markerNotSetNotificationKey = "motoRoutes.MarkerNotSet"


class showRouteController: UIViewController {
    
    //Outlets
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var flyButton:UIButton!
    //@IBOutlet var SpeedLabel:UILabel!
    @IBOutlet var DistanceLabel:UILabel!
    @IBOutlet var TimeLabel:UILabel!
    @IBOutlet var AltitudeLabel:UILabel!

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
    var markersSet = [MarkerAnnotation]()
    
    //media stuff
    var markerImageName:String = ""
    
    //slider route value
    var sliderRouteValue = 0
    var sliceStart = 0
    var sliceAmount = 1
    var key = 0
    var count:Int = 0
    var timer = NSTimer()
    var timeIntervalMarker = 0.05
    var performanceTime:Double = 0
    
    //Debug Label
    var debugTimer = NSTimer()
    var debugSeconds = 0
    
    //init custom speedometer
    var speedoMeter = Speedometer()
    var cameraCustomSlider = CameraSliderCustom()
    
    //make screenshot
    var typeMarker = ""
    var msgOverlay: MsgOverlay!
    

    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x = CFAbsoluteTimeGetCurrent()
        

        // MODEL: set max on route slider
        routeSlider.maximumValue = Float(motoRoute.locationsList.count-1)
       
        //MODEL: covert Realm LocationList to Location Master Object
        RouteList =  RouteMaster.createMasterLocationRealm(motoRoute.locationsList)
       
        //print(utils.absolutePeromanceTime(x))
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
        
        //init Msg Overlay
        msgOverlay = NSBundle.mainBundle().loadNibNamed("MsgOverlay", owner: self, options: nil)[0] as? MsgOverlay
        msgOverlay.center = AnimationEngine.offScreenLeftPosition
        msgOverlay.delegate = self
        msgOverlay.msgType = .Save
        self.view.addSubview(msgOverlay)
        
        
        //Setup Custom UI
        cameraCustomSlider.addTarget(self, action: #selector(showRouteController.cameraSliderValueChanged), forControlEvents: .ValueChanged)
        setupCustomUI()
        
    }
    


    
    override func viewDidAppear(animated: Bool) {
        
        //Listen from FlyoverRoutes if Markers are set
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showRouteController.switchFromFly2PrintMarker), name: markerNotSetNotificationKey, object: nil)
        
        //print the route in 1 color
        mapUtils.printRouteOneColor(RouteList, mapView: mapViewShow)
        
        //define camera and set it to startpoint
        let camera = mapUtils.cameraDestination(RouteList[0].latitude, longitude:RouteList[0].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: RouteList[0].course + globalHeading.gHeading)
        
        mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        
    }
    
    
    //
    // view will disappear, stop everythink
    //
    override func viewWillDisappear(animated:Bool) {
        
        stopAll()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    
    //int and setup custom controlls
    func setupCustomUI(){
        
        //get screensize
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        //init Speedometer
        let speedoHeight = screenHeight/2
        let speedoWidth:Int = 6
        speedoMeter.frame = CGRect(x: (Int(screenWidth) - speedoWidth), y: 0, width: speedoWidth, height: Int(speedoHeight))
        speedoMeter.setup(speedoWidth, height: Int(speedoHeight))
        
        
        //init and setup custom camera slider
        let frameSizeCameraSlider = 40 //extra space for slidethumb image
        let cameraCustomHeightMinus = CGFloat(60)
        cameraCustomSlider.frame = CGRect(x: (Int(screenWidth) - frameSizeCameraSlider), y: Int(screenHeight/2), width: frameSizeCameraSlider, height: Int(speedoHeight - cameraCustomHeightMinus))
        cameraCustomSlider.setup(speedoWidth, height: Int(speedoHeight - cameraCustomHeightMinus), frameWidth: frameSizeCameraSlider)
        
        //add Subviews
        view.addSubview(speedoMeter)
        view.addSubview(cameraCustomSlider)

    }
    
    
    //custom camera value changed
    func cameraSliderValueChanged(){
        
        //print("current value target print")
        //print(cameraCustomSlider.currentValue)
        
        let currentValue = cameraCustomSlider.currentValue
        
        globalCamDistance.gCamDistance = Double(200*currentValue)
        //print( globalCamDistance.gCamDistance)
        globalCamDuration.gCamDuration = Double(currentValue/1000) + 0.2
        //globalArrayStep.gArrayStep = currentValue/10 > 1 ? currentValue/10 : 1
        globalCamPitch.gCamPitch = currentValue*2 < 80 ? CGFloat(60 ) : 60.0
        
        //zoom camera also when not flying,
        if( globalAutoplay.gAutoplay==false && flyButton.selected==false ) {
            
            //get current center coords
            let centerCoords = mapViewShow.centerCoordinate
            
            //define camera and flyTo with zoom level
            let camera = mapUtils.cameraDestination(centerCoords.latitude, longitude:centerCoords.longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: globalHeading.gHeading)
            mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
            
            // print("\(mapViewShow.centerCoordinate)")
        }
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
        //print("touch down stopall()")
    }
    
    //touch event for rourte slider
    func touchUpRouteSlide(){
        //StartStop(true)
        //print("touch up slide, nothing")
    }
    
    //update debug label
    func updateDebugLabel(){
        //print("dwbug")
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
    
    func dispatch(){
    
        
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.printMarker()
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                // self.msgOverlay.textLabel.text = "\(marker.latitude)"
            }
        }

    
    
    }
    
    //stop all running Timer flying cameras
    func stopAll(){
        //print("stopAll")
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
            //print("Notify received Func \(receivedKey)")
            stopAll()
            StartStop(true)
        }
            //print("Notify received Func \(nRoute)")
    }
    
    //printing speedmarker on the map
    func printMarker(){
        
        
        print("paztch")
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        
        let counterStep = 1 // when to fly next marker
   
        //if not at end of array
        if( self.RouteList.count > self.sliceStart+self.sliceAmount){
            
            //Print Marker if not already set
            if(self.RouteList[self.sliceStart].marker==false){
            
               print("timer running and printeing routes \(self.sliceStart)")
                
                //print marker
                
                
                
                  let tmpMarkers = mapUtils.printSpeedMarker(self.RouteList, mapView: self.mapViewShow,  key:  self.sliceStart, amount: self.sliceAmount)
                  self.markersSet.appendContentsOf(tmpMarkers)
                  self.unsetMarker(&self.markersSet)

                
                self.sliceStart += self.sliceAmount //move array to next route
                self.count+=1 //counter to center map, fly camer to marker
                
                
                //fly camera to current marker
                if(self.count==counterStep){
                    
                    print("stop")
                    
                    //stop timer, flyto route and re-init timer, set counter to zero
                    //self.timer.invalidate()
                    mapUtils.flyOverRoutes(self.RouteList, mapView: self.mapViewShow, n: self.sliceStart, routeSlider: self.routeSlider, initInstance: utils.getUniqueUUID(), identifier: "i2", speedoMeter: self.speedoMeter)
                    self.count=0
                   //self.startMarkerTimer()
                }
                
                
                
            
            } else{ //if marker is already set
            
                print("marker already set start fly")
                
                self.stopAll()
                self.startFlytoAuto()
                //start flyto with autoplay
            }
     
        } else{ // end of array
         print("All Marker took: ")
         self.stopAll()
            //print(RouteList[0].marker)
        }
        
        
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                // self.msgOverlay.textLabel.text = "\(marker.latitude)"
            }
        }

        //print("MARKERS SET \(markersSet.count)")
        
    }
    
    
    //delete older marker when there are to many
    func unsetMarker(inout markersSet: [MarkerAnnotation]){
    
        let markerAmount = 150
        let markerToDelete = 1
        
        if(markersSet.count > markerAmount) {
        
            let markerSlice = markersSet[0...markerToDelete]
            
            for marker in markerSlice {
                let annotation = marker.annotaion
                //print(annotation)
                mapViewShow.removeAnnotation(annotation)
                
                markersSet.removeAtIndex(0) // remove deleted markers from array
                RouteList[marker.key].marker = false
            //    print("delete marker \(index) \(markersSet.count) \(mremove.annotaion)")
            }
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
        
        //print("play button \(sender.selected)")
        
        StartStop(sender.selected )
        
        
        //switch
        //globalAutoplay.gAutoplay = globalAutoplay.gAutoplay==false ? true : false
        
        //make route fly
        //print("let it fly")
        //mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliderRouteValue, SpeedLabel: SpeedLabel, routeSlider: routeSlider)
        
    }
   
    
    @IBAction func createAlleMarker(){
        
        msgOverlay.msgType = .Print
        msgOverlay.setupView()
        
        AnimationEngine.animationToPosition(msgOverlay, position: AnimationEngine.screenCenterPosition)
        
        //mapUtils.printSpeedMarker(RouteList, mapView: mapViewShow,  key:  0, amount: RouteList.count-5)
    
    
    }
    
    
    func printAllMarker(){
    

    
        //mapViewShow.hidden = true
        
         //  let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(1) * Double(NSEC_PER_SEC)))
        
 
        //for marker in self.RouteList{
        // mapUtils.printSingleSpeedMarker(self.mapViewShow, latitude: marker.latitude, longitude: marker.longitude, speed: marker.speed)
            //msgOverlay.saveButton.backgroundColor = colorUtils.randomColor()
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                mapUtils.printSpeedMarker(self.RouteList, mapView: self.mapViewShow,  key:  0, amount: self.RouteList.count-5)
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    // self.msgOverlay.textLabel.text = "\(marker.latitude)"
                }
            }

           // print("printing... \(marker.latitude)")
            
           // mapUtils.printSpeedMarker(RouteList, mapView: mapViewShow,  key:  0, amount: RouteList.count-5)

     
        //}

            
    }
    
    
    
    @IBAction func removewMarker(sender: UIButton) {
        
        //delete all annotations
        for annotation in mapViewShow.annotations!{
            mapViewShow.removeAnnotation(annotation)
        }
        
        //Set marker bool to false, to print new marker
        for marker in RouteList{
            marker.marker = false
        }
    }
    
    // new screenshot
    @IBAction func newScreenshot(sender: UIButton) {
        
      
        let screenshotFilename = imageUtils.screenshotMap(self.mapViewShow)
        
        //save new screenshot to realm
        //print(motoRoute)
        try! self.realm.write {
            self.realm.create(Route.self, value: ["id": self.motoRoute.id, "image": screenshotFilename], update: true)
            
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
        
        //unwind
        if segue.identifier == "unwindExitShowRoute" {
           //print("unwinding")
        }
    }
    

    @IBAction func unwindTo(unwindSegue: UIStoryboardSegue) {
    
        //print("unwind seague \(unwindSegue)")
        
    }
    
    
    
    /*
     * Close segue
     */
    @IBAction func close(segue:UIStoryboardSegue) {
        
        //print("close \(segue.sourceViewController)")
        
        if let optionController = segue.sourceViewController as? motoRouteOptions {
            
            //print("close sliceAmount \(optionController.sliceAmount)")
            
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
        //print(typeMarker)
        let image = imageUtils.drawLineOnImage(typeMarker)
        let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "routeline\(utils.getSpeed(globalSpeed.gSpeed))")
        
        return annotationImage
        
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
       // print("regionDidChangeAnimated")
        
    }
    
    func mapViewRegionIsChanging(mapView: MGLMapView) {
        //print("region is chanhing")
    }
    
    
    func mapView(mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        //print("region will change")
    }
    
    func mapViewWillStartLoadingMap(mapView: MGLMapView) {
        //print("mapViewWillStartLoadingMap")
    }
    
    func mapViewDidFinishRenderingMap(mapView: MGLMapView, fullyRendered: Bool) {
        //print("mapViewDidFinishRenderingMap")
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
        return 6.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        //let speedIndex =  Int(round(speed/10))
        return colorUtils.polylineColors(utils.getSpeedIndexFull(globalSpeed.gSpeed))
    }
    
}

extension showRouteController: msgOverlayDelegate{
    
    func pressedResume() {
        print("pressed resume")
        AnimationEngine.hideMsgOverlay(msgOverlay)

    }
    
    func pressedSave(){
        print("pressed save")
        printAllMarker()
        //msgOverlay.saveButton.backgroundColor = colorUtils.randomColor()
    }
}