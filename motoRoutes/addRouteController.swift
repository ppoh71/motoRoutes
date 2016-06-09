//
//  addRouteController.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 21.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import RealmSwift
import Mapbox
import Crashlytics
import pop


let saveOverlaytNotificationKey = "motoRoutes.saveOverlay"

class addRouteController: UIViewController {
    
    
    //Outlets
    @IBOutlet var debugButton:UIButton!
    @IBOutlet var debugView:UIView!
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var distanceLabel:UILabel!
    @IBOutlet var accuracyLabel:UILabel!
    @IBOutlet var altitudeLabel:UILabel!
    @IBOutlet var longitudeLabel:UILabel!
    @IBOutlet var latitudeLabel:UILabel!
    @IBOutlet var recRouteBtn:UIButton!
    @IBOutlet var saveRouteBtn:UIButton!
    @IBOutlet var screenShotRoute:UIImageView!
    @IBOutlet var mapView:MGLMapView!
    

    @IBOutlet weak var screenshotButtonConstraint: NSLayoutConstraint!

    
    //location manager
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .AutomotiveNavigation
        _locationManager.distanceFilter = 10.0  // Movement threshold for new events
        _locationManager.allowsBackgroundLocationUpdates = true // allow in background
        
        return _locationManager
    }()
    
    //route, location and timer vars
    lazy var locationsRoute = [CLLocation]()
    lazy var locationsRouteInactive = [CLLocation]()
    lazy var timer = NSTimer()
    var second = 0
    var distance = 0.0
    var latitude:Double = 0
    var longitude:Double = 0
    var altitude:Double = 0
    var accuracy:Double = 0
    var speed:Double = 0
    var recordingActive:Bool = false
    var cnt = 20
    var savedRoute:Results<Route>!
   
    
    //start timestamp of route start
    var startTimestamp:Int = 0
    var startLocationTimestamp:Int = 0
    
    //current time timestamp
    var currentTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970)
    }
   
    //total time in sec /starttimstamp - currenttimestamp
    var totalTime:Int = 0

    // needs review & cleanup
    var AppActive = true //is app active or in background
    var ActiveTime = 0.0 //seconds the app is active after coming form background
    
    
    //media
    var MediaObjects = [MediaMaster]()
    
    //svaeing and making screenshot
    var centerBoundsAnimation = false
    
    //Msg Overlay
    var msgOverlay: MsgOverlay!
    //var animEngine: AnimationEngine!
    
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //map camera init settings
        mapView.zoomLevel = 9
        mapView.camera.heading = 60
        
        
        //init Msg Overlay
        msgOverlay = NSBundle.mainBundle().loadNibNamed("MsgOverlay", owner: self, options: nil)[0] as? MsgOverlay
        msgOverlay.center = AnimationEngine.offScreenLeftPosition
        msgOverlay.delegate = self
        self.view.addSubview(msgOverlay)
        
        //init aniEngine
       //self.animEngine = AnimationEngine(constraints: [screenshotButtonConstraint])
        
        // Add UIApplicationWillResignActiveNotification observer
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(addRouteController.resigningActive),
            name: UIApplicationWillResignActiveNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(addRouteController.becomeActive),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
        
    }
    
    
    func resigningActive(){
    
        print("###################resigningActive")
        AppActive = false;
        ActiveTime = 0
        
    }
    
    func becomeActive(){
        
        print("###################become Active")
        AppActive = false;
        ActiveTime = CFAbsoluteTimeGetCurrent()
    }
    
    
    //
    // view will appesar
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //allow location use
        locationManager.requestAlwaysAuthorization()
        
        print(recordingActive)
        
        //get current user location for startup
        if CLLocationManager.locationServicesEnabled() {
             locationManager.startUpdatingLocation()
        }
        
       //self.animEngine.animateOnScreen(2)

        
        //Listen to save from overlay notification
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addRouteController.saveRouteToRealm), name: saveOverlaytNotificationKey, object: nil)
  
    }

    
    //
    // view will disappear, stop location updates and timer
    //
    override func viewWillDisappear(animated:Bool) {
  
        //locationManager.stopUpdatingLocation(); //stop locations
        // timer.invalidate() //stop timer
        print("view will appear")
        super.viewWillDisappear(animated)
    }
    
    
    //
    // start function
    //
    func startLocationUpdates() {
        // init Location manger
        //get current user location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation() // start location manager
            recordingActive = true // set start of location manager true
            startTimestamp = Int(NSDate().timeIntervalSince1970) // get timestamp for timer
        }
    }
    
    func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
           target: self,
           selector: #selector(addRouteController.perSecond(_:)),
           userInfo: nil,
           repeats: true)
    }
    
    func pauseLocationUpdates(){
        locationManager.stopUpdatingLocation();
        mapView.showsUserLocation = false
        timer.invalidate()
    }
    
    
    func resumeLocationUpdates(){
        locationManager.startUpdatingLocation();
        mapView.showsUserLocation = true
        startTimer()
    }
    
    
    //
    // timer update per second
    //
    func perSecond(timer: NSTimer) {
        
        second += 1
        totalTime = currentTimestamp - startTimestamp

        timeLabel.text = utils.clockFormat(totalTime)
        distanceLabel.text = "\(utils.distanceFormat(distance)) km"
        
        //location updates
        latitudeLabel.text = "La: \(latitude)"
        longitudeLabel.text = "Lo: \(longitude)"
        altitudeLabel.text = "Speed: \(round(speed))"
        accuracyLabel.text = "Acc: \(accuracy)"
    }

    
    func showSaveOverlay(){
        AnimationEngine.animationToPosition(msgOverlay, position: AnimationEngine.screenCenterPosition)
    }
    
    func hideShowOverlay(){
        AnimationEngine.animationToPosition(msgOverlay, position: AnimationEngine.offScreenLeftPosition)
    }
    
    
    //
    // preppare to save motoRoute to core data
    //
    func prepareSaveRoute() {
        
        pauseLocationUpdates()
        
        //make routre model
        let RouteList = RouteMaster.createMasterFromCLLocation(locationsRoute)

        //get bounds, centerpoints, of the whole Route
        let Bounds = mapUtils.getBoundCoords(RouteList)
        let coordArray = Bounds.coordboundArray
        //let coordBounds = Bounds.coordbound
        let distanceDiagonal = Bounds.distance
        let distanceFactor = Bounds.distanceFactor

        //get centerpoint
        let centerPoint = mapUtils.getCenterFromBoundig(coordArray)

        //define camera and set it to startpoint
        let camera = mapUtils.cameraDestination(centerPoint.latitude, longitude:centerPoint.longitude, fromDistance: distanceDiagonal*distanceFactor, pitch: globalCamPitch.gCamPitch, heading: 0)
        
        //animate camera to center point, launch save overlay
        mapView.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {
            
            self.showSaveOverlay()
        
        }
        
    }
 
    
    
    //make ScreenShot and save to realm
    func saveRouteToRealm(){
    
        //make screenshot from active
        let screenshotFilename = imageUtils.screenshotMap(self.mapView)
        
        //save rout to realm
       let routeRealmID = realmUtils.saveRouteRealm(self.locationsRoute, MediaObjects: self.MediaObjects, screenshotFilename: screenshotFilename, startTimestamp: self.startTimestamp, distance: self.distance, totalTime: self.totalTime )
        
        //load saved realm object passit to seague for showcontroller
        savedRoute = realmUtils.getRealmByID(routeRealmID)
        performSegueWithIdentifier("goFromAdd2Show", sender: nil)
        print(savedRoute)
        
    }
    

    //
    // @IBAction
    //
    
    // press on rec Button and start rec of route
    @IBAction func startRecRoute(sender: UIButton) {
    
        second = 0
        distance = 0.0
        locationsRoute.removeAll(keepCapacity: false)
        startTimer()
        startLocationUpdates()
    }
    

    // save route
    @IBAction func saveRoute(sender: UIButton) {
        
        //save route
        if(locationsRoute.count>2){
            prepareSaveRoute()
            timer.invalidate() //stop timer
            print("saved")
        } else{
          print("not saved")
        }
        
        
    }
    
    
    
    //
    // Debug Stuff
    //
    
    //Debug animate Label Action
    @IBAction func showDebug2(sender: UIButton) {
        
        
        print("debug view")
        
        var animateX:CGFloat = 0; //animnate x var
        
        //switch button function
        if(debugButton.currentTitle=="+"){
            
            debugButton.setTitle("-", forState: UIControlState.Normal)
            animateX = -280
            
        } else{
            
            debugButton.setTitle("+", forState: UIControlState.Normal)
            animateX = -0
        }
        
        //aimate view
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.debugView.transform = CGAffineTransformMakeTranslation(animateX, 0)
            
            }, completion: nil)
    }
    

    /*
    * Prepare Segue / camera stuff
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        //prepare for camera/photo store to MediaObhect
        if segue.identifier == "showCamera" {
            let destinationController = segue.destinationViewController as! motoRouteCamera
            destinationController.latitude = latitude
            destinationController.longitude = longitude
        }
        
        //prepare for camera/photo store to MediaObhect
        if segue.identifier == "goFromAdd2Show" {
            let destinationController = segue.destinationViewController as! showRouteController

            destinationController.motoRoute = savedRoute[0]
            
        }
        
        
        
        
    }
    
    
    /*
    * Close segue
    */
    @IBAction func close(segue:UIStoryboardSegue) {
       
        if let cameraController = segue.sourceViewController as? motoRouteCamera {
            if let MediaObjectsCamera:[MediaMaster]! = cameraController.MediaObjects {
              
                MediaObjects += MediaObjectsCamera
                
             print( "##################\(MediaObjects)")
            }
        }
    }

    
    
}


// MARK: - CLLocationManagerDelegate
extension addRouteController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Location Update:")
        print(ActiveTime)
        
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
          /*  print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            print("Active \(locationActive)") */
            print("**********************")

   
            //set location vars
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            altitude = location.altitude
            accuracy = location.horizontalAccuracy
            speed = location.speed
            
            
            /*
            *   get current location on start
            *   and center map to it
            *   write first location into locationsRoute[]
            */
            if(recordingActive==false){
                
                // geet center coords from location
                let centerCoords = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
                //center map
                mapView.setCenterCoordinate(centerCoords,  zoomLevel: 12, animated: true)
                
                print("Center map in startup")
            }
            
            
            /*
            *    if we have certain accuracy
            *    start recording locations
            */
            if location.horizontalAccuracy < 50 && recordingActive==true {
                
                cnt += 1 //update location counter
                
                //save startup location to locationRoute array object
                if locationsRoute.count==0{
                    self.locationsRoute.append(location)
                }
                
                
                //calc distance for display only
                distance += location.distanceFromLocation(self.locationsRoute.last!)
              
                //set chords for routes
                //var coords = [CLLocationCoordinate2D]()
                //coords.append(self.locationsRoute.last!.coordinate)
                //coords.append(location.coordinate)
                
                //set GlobalSpeepSet
                //utils.setGlobalSpeedSet(location.speed)
                
                //set rather marker than print route
//              let newMarker = MGLPointAnnotation()
//              newMarker.coordinate = location.coordinate
//              mapView.addAnnotation(newMarker)
                
                mapUtils.printSingleSpeedMarker(mapView, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, speed: location.speed)
                
                //center map
                if(cnt==21){
                   // mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),  animated: true)
                  
                    
                   let camera = mapUtils.cameraDestination(location.coordinate.latitude, longitude: location.coordinate.longitude, fromDistance:6500, pitch:60, heading:0)
                   mapView.setCamera(camera, animated: true)
                   cnt=0 //reset counter
                }
                
                /* check if app is active and not in background */
                if UIApplication.sharedApplication().applicationState == .Active {
                    
                    //print missing coords when app was in background
                    /*if(locationsRouteInactive.count > 2){
                        
                        //covert Realm LocationList to Location Master Object
                        let _LocationMaster = utils.masterLocation(locationsRouteInactive)
                        
                        //print to map
                        mapUtils.printRoute(_LocationMaster, mapView: mapView)
                        
                        //reset locationsRouteInactive
                        locationsRouteInactive = [CLLocation]()
                        
                    }*/
                    
                    //create Polyline and add route
                    //let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                    //mapView.addAnnotation(line)
                    
                    

                    
                   //center mapview after every n loction update
                    
                    /*if(cnt==20){
                        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),  animated: true)
                        cnt=0 //reset counter
                    }*/
 
                 
                } else{ //save loactions when app is in background
                    print("app not active, no map centering")
                    
                    //save locations while inactive
                    //locationsRouteInactive.append(location)
                    
                    //cnt=0 //keep counter to zero in backgroud
                    
                } 
                
                //save location to locationRoute array object
                self.locationsRoute.append(location)
                
            }
        
        }
        
    }
}


// MARK: - MKMapViewDelegate
extension addRouteController: MGLMapViewDelegate {
    
    
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        //Try to reuse the existing ‘pisa’ annotation image, if it exists
        //var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("Marker-Speed-\(utils.getSpeed(globalSpeed.gSpeed)).png")
        
        //if annotationImage == nil {
        
        let image = imageUtils.drawLineOnImage("Recording")
        //let  image = UIImage(named: "Marker-Speed-\(utils.getSpeed(globalSpeed.gSpeed)).png")!
        
        let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "routeline\(utils.getSpeed(globalSpeed.gSpeed))")

        
        //}
        
        return annotationImage
    }

    
    func mapViewRegionIsChanging(mapView: MGLMapView) {
        print("region is chanhing")
    }

    
    func mapView(mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        print("region will change")
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        
        //save the route and make screenshot, when route is centered
        if centerBoundsAnimation == true {
        
            saveRouteToRealm()
            centerBoundsAnimation = false
        
        }
        print("regio did  change animated")
    }
    
    func mapViewDidFailLoadingMap(mapView: MGLMapView, withError error: NSError) {
        print("failed loading mapr")
    }
   
    func mapViewDidStopLocatingUser(mapView: MGLMapView) {
         print("failed loading mapr")
    }


    func mapViewWillStartLoadingMap(mapView: MGLMapView) {
        print("mapViewWillStartLoadingMap")
    }
    
    func mapViewDidFinishRenderingMap(mapView: MGLMapView, fullyRendered: Bool) {
        print("mapViewDidFinishRenderingMap")
    }
    
    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 5.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
       let speedIndex =  utils.getSpeedIndex(speed)
       return colorUtils.polylineColors(speedIndex)
    }
    
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.whiteColor()
    }
    
}

extension addRouteController: msgOverlayDelegate{

    func pressedResume() {
        print("pressed resume")
        //roll back overlay
        AnimationEngine.animationToPosition(msgOverlay, position: AnimationEngine.offScreenLeftPosition)
        resumeLocationUpdates()
    }
    
    func pressedSave(){
        print("pressed save")
        saveRouteToRealm()
    }
    
    
}

