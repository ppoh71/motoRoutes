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
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = 10.0  // Movement threshold for new events
        _locationManager.allowsBackgroundLocationUpdates = true // allow in background
        
        return _locationManager
    }()
    
    //route, location and timer vars
    lazy var locationsRoute = [CLLocation]()
    lazy var locationsRouteInactive = [CLLocation]()
    lazy var timer = Timer()
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
    var routeRealmID = ""
   
    
    //start timestamp of route start
    var startTimestamp:Int = 0
    var startLocationTimestamp:Int = 0
    
    //current time timestamp
    var currentTimestamp: Int {
        return Int(Date().timeIntervalSince1970)
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
    
    var funcType = FuncTypes.Recording
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //map camera init settings
        mapView.zoomLevel = 9
        mapView.camera.heading = 60
    }
    
    
    deinit {
        print("deinit called")
    }

    
    //
    // view will appesar
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //allow location use
        locationManager.requestAlwaysAuthorization()
        
        print(recordingActive)
        
        //get current user location for startup
        if CLLocationManager.locationServicesEnabled() {
             locationManager.startUpdatingLocation()
        }
        
        
        //init Msg Overlay
        msgOverlay = Bundle.main.loadNibNamed("MsgOverlay", owner: self, options: nil)?[0] as? MsgOverlay
        msgOverlay.center = AnimationEngine.offScreenLeftPosition
        msgOverlay.delegate = self
        msgOverlay.msgType = .save
        self.view.addSubview(msgOverlay)
    }

    
    //
    // view will disappear, stop location updates and timer
    //
    override func viewWillDisappear(_ animated:Bool) {
        print("addRoute will disappear")
        super.viewWillDisappear(animated)
        pauseLocationUpdates()
        
        view.subviews.forEach {
            $0.removeFromSuperview()
        }

    }
    
    // helper functions
    func startupLocationUpdates() {
        //init Location manger & get current user location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation() // start location manager
            recordingActive = true // set start of location manager true
            startTimestamp = Int(Date().timeIntervalSince1970) // get timestamp for timer
        }
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1,
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
    

    
    // timer update per second
    //
    func perSecond(_ timer: Timer) {
        
        second += 1
        totalTime = currentTimestamp - startTimestamp

        timeLabel.text = Utils.clockFormat(totalTime)
        distanceLabel.text = "\(Utils.distanceFormat(distance)) km"
        
        //location updates
        latitudeLabel.text = "La: \(latitude)"
        longitudeLabel.text = "Lo: \(longitude)"
        altitudeLabel.text = "Speed: \(round(speed))"
        accuracyLabel.text = "Acc: \(accuracy)"
    }

    
    //
    // preppare to save motoRoute to core data
    //
    func prepareSaveRoute() {
        
        pauseLocationUpdates()
        
        //make routre model
        let RouteList = RouteMaster.createMasterFromCLLocation(locationsRoute)

        //get bounds, centerpoints, of the whole Route
        let Bounds = MapUtils.getBoundCoords(RouteList)
        let coordArray = Bounds.coordboundArray
        //let coordBounds = Bounds.coordbound
        let distanceDiagonal = Bounds.distance
        let distanceFactor = Bounds.distanceFactor
        
        if(coordArray.count > 0){

            //get centerpoint
            let centerPoint = MapUtils.getCenterFromBoundig(coordArray)

            //define camera and set it to startpoint
            let camera = MapUtils.cameraDestination(centerPoint.latitude, longitude:centerPoint.longitude, fromDistance: distanceDiagonal*distanceFactor, pitch: globalCamPitch.gCamPitch, heading: 0)
            
                //animate camera to center point, launch save overlay
                mapView.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {
                    
                    self.msgOverlay.msgType = .save
                    self.msgOverlay.setupView()
                    AnimationEngine.showViewAnimCenterPosition(self.msgOverlay)
                }
            
        } else{
            
            self.msgOverlay.msgType = .resume
            self.msgOverlay.setupView()
            AnimationEngine.showViewAnimCenterPosition(self.msgOverlay)
        }
            
    }
    
    //make ScreenShot and save to realm
    func saveRouteToRealm(){
        let id = UUID().uuidString
        
        //make screenshot from active
        let screenshotFilename = ImageUtils.screenshotMap(self.mapView, id: id)
        
        //save rout to realm and get reamlID
        routeRealmID = RealmUtils.saveRouteRealm(id, LocationsRoute: self.locationsRoute, MediaObjects: self.MediaObjects, screenshotFilename: screenshotFilename, startTimestamp: self.startTimestamp, distance: self.distance, totalTime: self.totalTime )
        
        //load saved realm object passit to seague for showcontroller
        savedRoute = RealmUtils.getRealmByID(routeRealmID)
        performSegue(withIdentifier: "goFromAdd2Show", sender: nil)
    }
    
    // press on rec Button and start rec of route
    @IBAction func startRecRoute(_ sender: UIButton) {
        second = 0
        distance = 0.0
        locationsRoute.removeAll(keepingCapacity: false)
        startTimer()
        startupLocationUpdates()
    }
    

    // save route
    @IBAction func saveRoute(_ sender: UIButton) {
        //save route
        if(locationsRoute.count>2){
            prepareSaveRoute()
            timer.invalidate() //stop timer
            print("saved")
        } else{
          print("not saved")
        }
    }
    
    /*
    * Prepare Segue / camera stuff
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        print("segue 1 \(segue.identifier)")
               
        
        //prepare for camera/photo store to MediaObhect
        if segue.identifier == "showCamera" {
            let destinationController = segue.destination as! motoRouteCamera
            destinationController.latitude = latitude
            destinationController.longitude = longitude
        }
        
        //prepare for camera/photo store to MediaObhect
        if segue.identifier == "goFromAdd2Show" {
            let destinationController = segue.destination as! showRouteController

            destinationController.motoRoute = savedRoute[0]
        }
    }
    
    
    /*
    * Close segue
    */
    @IBAction func close(_ segue:UIStoryboardSegue) {
        
        print("segue close")
        
        if let cameraController = segue.source as? motoRouteCamera {
            if (cameraController.MediaObjects.count > 0) {
                MediaObjects += cameraController.MediaObjects
                print( "##################\(MediaObjects)")
            }
        }
    }

    
    //
    // Debug Stuff
    //
    @IBAction func showDebug2(_ sender: UIButton) {
        
        print("debug view")
        
        var animateX:CGFloat = 0; //animnate x var
        
        //switch button function
        if(debugButton.currentTitle=="+"){
            
            debugButton.setTitle("-", for: UIControlState())
            animateX = -280
            
        } else{
            
            debugButton.setTitle("+", for: UIControlState())
            animateX = -0
        }
        
        //aimate view
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.debugView.transform = CGAffineTransform(translationX: animateX, y: 0)
            
            }, completion: nil)
    }
    
} //end class


// MARK: - CLLocationManagerDelegate
extension addRouteController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
                mapView.setCenter(centerCoords,  zoomLevel: 12, animated: true)
                
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
                distance += location.distance(from: self.locationsRoute.last!)
                
                MapUtils.printSingleSpeedMarker(mapView, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, speed: location.speed)
                
                //center map
                if(cnt>20){
                   // mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),  animated: true)
                    
                   let camera = MapUtils.cameraDestination(location.coordinate.latitude, longitude: location.coordinate.longitude, fromDistance:6500, pitch:60, heading:0)
                   mapView.setCamera(camera, animated: true)
                   cnt=0 //reset counter
                }
                
                //save location to locationRoute array object
                self.locationsRoute.append(location)
                
            }
        }
    }
}


// MARK: - MKMapViewDelegate
extension addRouteController: MGLMapViewDelegate {
    
    
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        //Try to reuse the existing ‘pisa’ annotation image, if it exists
        //var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("Marker-Speed-\(utils.getSpeed(globalSpeed.gSpeed)).png")
        
        //if annotationImage == nil {
        
        let image = ImageUtils.drawLineOnImage(funcType)
        //let  image = UIImage(named: "Marker-Speed-\(utils.getSpeed(globalSpeed.gSpeed)).png")!
        
        let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "routeline\(Utils.getSpeed(globalSpeed.gSpeed))")
      
        //}
        
        return annotationImage
    }

    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        print("region is chanhing")
    }

    
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        print("region will change")
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        
        print("regio did  change animated")
    }
    

   
    func mapViewDidStopLocatingUser(_ mapView: MGLMapView) {
         print("failed loading mapr")
    }


    func mapViewWillStartLoadingMap(_ mapView: MGLMapView) {
        print("mapViewWillStartLoadingMap")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MGLMapView, fullyRendered: Bool) {
        print("mapViewDidFinishRenderingMap")
    }
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 5.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
       let speedIndex =  Utils.getSpeedIndex(speed)
       return ColorUtils.polylineColors(speedIndex)
    }
    
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.white
    }
    
}

extension addRouteController: msgOverlayDelegate{

    func pressedResume() {
        print("pressed resume")
        //roll back overlay
        cnt=20
        AnimationEngine.hideViewAnim(msgOverlay)
        resumeLocationUpdates()
    }
    
    func pressedSave(){
        print("pressed save")
        saveRouteToRealm()
    }
}

