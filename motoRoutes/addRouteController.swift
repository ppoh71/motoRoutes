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
    lazy var timer = NSTimer()
    var second = 0
    var distance = 0.0
    var latitude:Double = 0
    var longitude:Double = 0
    var altitude:Double = 0
    var accuracy:Double = 0
    var speed:Double = 0
    var locationActive:Bool = false
   
    
    //start timestamp of route start
    var startTimestamp:Int = 0
    var startLocationTimestamp:Int = 0
    
    //current time timestamp
    var currentTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970)
    }

   
    //total time in sec /starttimstamp - currenttimestamp
    var totalTime:Int = 0
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //
    // view will appesar
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //allow location use
        locationManager.requestAlwaysAuthorization()
        
        print(locationActive)
        
        //get current user location for startup
        if CLLocationManager.locationServicesEnabled() {
             locationManager.startUpdatingLocation()
        }

    }

    //
    // view will disappear, stop location updates and timer
    //
    override func viewWillDisappear(animated:Bool) {
  
        locationManager.stopUpdatingLocation(); //stop locations
        timer.invalidate() //stop timer
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
            locationActive = true // set start of location manager true
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
        altitudeLabel.text = "Speed: \(speed)"
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
        
        //get the middle coord of the whole route
        let middleCoord = locationsRoute[Int(round(Double(locationsRoute.count/2)))]
        
        let coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: locationsRoute[0].coordinate.latitude, longitude: locationsRoute[0].coordinate.longitude), CLLocationCoordinate2D(latitude: locationsRoute[locationsRoute.count-1].coordinate.latitude, longitude: locationsRoute[locationsRoute.count-1].coordinate.longitude))
        
         self.mapView.setVisibleCoordinateBounds(coordBounds, animated: true) 
        
        //create cameras for animations
        let camerax = mapFx.cameraDestination(locationsRoute[0].coordinate.latitude, longitude:locationsRoute[0].coordinate.longitude, fromDistance:5000, pitch:40, heading:60)
        
        let cameraz = mapFx.cameraDestination(middleCoord.coordinate.latitude, longitude:middleCoord.coordinate.longitude, fromDistance:8000, pitch:40, heading:0)
        
        let cameray = mapFx.cameraDestination(locationsRoute[locationsRoute.count-1].coordinate.latitude, longitude:locationsRoute[locationsRoute.count-1].coordinate.longitude, fromDistance:5000, pitch:20, heading:30)
        
        print("Bound")
        print(coordBounds)
        
        //camera animation -> screenshot -> save route to realm
        mapView.flyToCamera(camerax) {
            
            self.mapView.flyToCamera(cameray){
                self.mapView.flyToCamera(cameraz){
                    print("finish camera animation")
                    
                    
                   
                    
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
    
    

}


// MARK: - CLLocationManagerDelegate
extension addRouteController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Location Update:")
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            print("Active \(locationActive)")
            print("**********************")

   
            //set location vars
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            altitude = location.altitude
            accuracy = location.horizontalAccuracy
            speed = location.speed
            

            if location.horizontalAccuracy < 50 && locationActive==true {
                
                //update distance and coords if locationActive
                if self.locationsRoute.count > 0 {
                    
                    distance += location.distanceFromLocation(self.locationsRoute.last!)
                  
                    //set chords for routes
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locationsRoute.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    
                    if UIApplication.sharedApplication().applicationState == .Active {
                       
                        //create Polyline
                        let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                        mapView.addAnnotation(line)
                        
                        
                        //center mapview by new coord
                        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),  animated: true)
                    } else{
                        print("app not active, no map centering")
                    }
                    
                    
                    
                }
                
                 //save location to locationRoute array object
                self.locationsRoute.append(location)
                
            }
            
            
            //get current location on start and stop after updating location
            if(locationActive==false){
                
               let centerCoords = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
               mapView.setCenterCoordinate(centerCoords,  zoomLevel: 12, animated: true)
               //locationManager.stopUpdatingLocation();
               print("Center map in startup")
                
                //let camera fly

                //cameraFly(centerCoords)

               //cameraFly(centerCoords)

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
        print("region changed")
        print(mapView.styleClasses)
        print(mapView.styleURL)
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
       let speedIndex =  Int(round(speed/10))
       return colorStyles.polylineColors(speedIndex)
    }
    
}

