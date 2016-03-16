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


class addRouteController: UIViewController {
    
    // managedObjectContext var
    //var managedObjectContext: NSManagedObjectContext?

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
    var cnt = 0
   
    
    //start timestamp of route start
    var startTimestamp:Int = 0
    var startLocationTimestamp:Int = 0
    
    //current time timestamp
    var currentTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970)
    }
   
    //total time in sec /starttimstamp - currenttimestamp
    var totalTime:Int = 0

    
    
    var AppActive = true //is app active or in background
    var ActiveTime = 0.0 //seconds the app is active after coming form background
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Add UIApplicationWillResignActiveNotification observer
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "resigningActive",
            name: UIApplicationWillResignActiveNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "becomeActive",
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
    
    //
    // timer update per second
    //
    func perSecond(timer: NSTimer) {
        
        second++
        
        totalTime = currentTimestamp - startTimestamp

        timeLabel.text = utils.clockFormat(totalTime)
        distanceLabel.text = "\(utils.distanceFormat(distance)) km"
        
        //location updates
        latitudeLabel.text = "La: \(latitude)"
        longitudeLabel.text = "Lo: \(longitude)"
        altitudeLabel.text = "Speed: \(round(speed))"
        accuracyLabel.text = "Acc: \(accuracy)"
    }

    
    
    //
    // save motoRoute to core data
    //
    func saveRoute() {
        
        //stop locatoin updates, don‘t move
        locationManager.stopUpdatingLocation();
        
        //dont show user location, no blue dot on screenshot
        mapView.showsUserLocation = false
        
        //stop timer
        timer.invalidate()
        
        print("Location Route")
        print(locationsRoute)
                
        //get the middle coord of the whole route
        let middleCoord = locationsRoute[Int(round(Double(locationsRoute.count/2)))]
        
        
        //get coord bounds for route, nortwest & souteast
        
        let coordBounds = utils.getBoundCoords(utils.masterLocation(locationsRoute))
        
        //set visible bounds
        self.mapView.setVisibleCoordinateBounds(coordBounds, animated: true)
        
        
        //create cameras for animations
        let camerax = mapFx.cameraDestination(locationsRoute[0].coordinate.latitude, longitude:locationsRoute[0].coordinate.longitude, fromDistance:4000, pitch:40, heading:60)
        let cameraz = mapFx.cameraDestination(middleCoord.coordinate.latitude, longitude:middleCoord.coordinate.longitude, fromDistance:6000, pitch:40, heading:0)
        let cameray = mapFx.cameraDestination(locationsRoute[locationsRoute.count-1].coordinate.latitude, longitude:locationsRoute[locationsRoute.count-1].coordinate.longitude, fromDistance:11000, pitch:20, heading:30)
        
        print("Bound")
        print(coordBounds)
        
        //camera animation -> screenshot -> save route to realm
        
        mapView.flyToCamera(camerax) {
            
            self.mapView.flyToCamera(cameray){
                self.mapView.flyToCamera(cameraz){
                    print("finish camera animation")
                    
                    //set to bounds
                   // self.mapView.setVisibleCoordinateBounds(coordBounds, animated: true)
                    
                    //make screenshot and get image name
                    let screenshotFilename = utils.screenshotMap(self.mapView)
                    
                    //save rout to realm
                    utils.saveRouteRealm(self.locationsRoute, screenshotFilename: screenshotFilename, startTimestamp: self.startTimestamp, distance: self.distance, totalTime: self.totalTime )
                    
                }
            }
        }
       
    }
 

    //
    // @IBAction
    //
    
    // press on rec Button and start rec of route
    @IBAction func startRecRoute(sender: UIButton) {
    
        second = 0
        distance = 0.0
        locationsRoute.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "perSecond:",
            userInfo: nil,
            repeats: true)
        
        startLocationUpdates()
    }
    

    // save route
    @IBAction func saveRoute(sender: UIButton) {
        
        //save route
        if(locationsRoute.count>2){
            saveRoute()
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
    
    @IBAction func unwindToAddRoute(segue:UIStoryboardSegue) {
        
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
                get current location on start 
                and center map to it
                write first location into locationsRoute[]
            */
            if(recordingActive==false){
                
                // geet center coords from location
                let centerCoords = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
                //center map
                mapView.setCenterCoordinate(centerCoords,  zoomLevel: 12, animated: true)
                
                print("Center map in startup")
            }
            
            
            /*
                if we have certain accuracy
                start recording locations
            */
            if location.horizontalAccuracy < 50 && recordingActive==true {
                
                cnt++ //update location counter
                
                //save startup location to locationRoute array object
                if locationsRoute.count<1 {
                    self.locationsRoute.append(location)
                }
                
                
                //update distance and coords if locationActive
                //if self.locationsRoute.count > 0 {
                    
                    distance += location.distanceFromLocation(self.locationsRoute.last!)
                  
                    //set chords for routes
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locationsRoute.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    
                    /* check if app is active and not in background */
                    if UIApplication.sharedApplication().applicationState == .Active {
                        
                        //print missing coords when app was in background
                        if(locationsRouteInactive.count > 2){
                            
                            //covert Realm LocationList to Location Master Object
                            let _LocationMaster = utils.masterLocation(locationsRouteInactive)
                            
                            //print to map
                            mapFx.printRoute(_LocationMaster, mapView: mapView)
                            
                            //reset locationsRouteInactive
                            locationsRouteInactive = [CLLocation]()
                            
                        }
                        
                        //create Polyline and add route
                        let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                        mapView.addAnnotation(line)
                        
                        
                       //center mapview after every n loction update
                        if(cnt==20){
                            mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),  animated: true)
                            
                            cnt=0 //reset counter
                        }
                     
                    } else{ //save loactions when app is in background
                        print("app not active, no map centering")
                        
                        //save locations while inactive
                        locationsRouteInactive.append(location)
                        
                        cnt=0 //keep counter to zero in backgroud
                        
                    } 
                    
                    //save location to locationRoute array object
                    self.locationsRoute.append(location)
                
                //} // loaction.Route.count
    
            }
        
        }
        
    }
}


// MARK: - MKMapViewDelegate
extension addRouteController: MGLMapViewDelegate {
    


    func mapViewDidFailLoadingMap(mapView: MGLMapView, withError error: NSError) {
        print("failed loading mapr")
    }
   
    func mapViewDidStopLocatingUser(mapView: MGLMapView) {
         print("failed loading mapr")
    }

    
    
    func mapViewDidFinishRenderingFrame(mapView: MGLMapView, fullyRendered: Bool) {
       // print("DidFinishRenderingFrame")
    }
    
    func mapViewWillStartLoadingMap(mapView: MGLMapView) {
       // print("WillStartLoadingMap")
       //  print(mapView.debugDescription)
    }
    
    func mapViewWillStartRenderingFrame(mapView: MGLMapView) {
       // print("WillStartRenderingFrame")

        //print(mapView.description)
        //print(mapView)
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
       // print("region changed")

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
        return 5.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
       let speedIndex =  utils.getSpeedIndex(speed)
       return colorStyles.polylineColors(speedIndex)
    }
    
}

