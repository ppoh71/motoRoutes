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
import MapKit
import Mapbox


class addRouteController: UIViewController {
    
    // managedObjectContext var
    //var managedObjectContext: NSManagedObjectContext?

    //Outlets
    @IBOutlet var cancelButton:UIButton!
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
        
        //timer.invalidate()
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

        timeLabel.text = numberFormats.clockFormat(totalTime)
        distanceLabel.text = "\(distance)"
        
        //location updates
        latitudeLabel.text = "La: \(latitude)"
        longitudeLabel.text = "Lo: \(longitude)"
        altitudeLabel.text = "Al: \(speed)"
        accuracyLabel.text = "\(accuracy)"
        
       
        
        if UIApplication.sharedApplication().applicationState == .Active {
             print("timer active ", totalTime)
        } else {
             print("timer background", totalTime)
        }

    }

    
    
    //
    // save motoRoute to core data
    //
    func saveRoute() {
        
        
        // save to realm
        let newRoute = Route()
        
        newRoute.timestamp = NSDate()
        newRoute.distance = distance
        newRoute.duration = totalTime
        
        for location in locationsRoute {
            
            let newLocation = Location()
           
            newLocation.timestamp = location.timestamp
            newLocation.latitude = location.coordinate.latitude
            newLocation.longitude = location.coordinate.longitude
            newLocation.altitude = location.altitude
            newLocation.speed = location.speed
            
            newRoute.locationsList.append(newLocation)
        
        }
        
        // Get the default Realm
        let realm = try! Realm()
        // You only need to do this once (per thread)
        
        // Add to the Realm inside a transaction
        try! realm.write {
            realm.add(newRoute)
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
        saveRoute()
        timer.invalidate() //stop timer
        
    }
    
    
    
    //
    // Debug Stuff
    //
    
    //Debug animate Label Action
    @IBAction func showDebug2(sender: UIButton) {
        
        var animateX:CGFloat = 0; //animnate x var
        
        //switch button function
        if(debugButton.currentTitle=="-"){
            
            debugButton.setTitle("+", forState: UIControlState.Normal)
            animateX = -235
            
        } else{
            
            debugButton.setTitle("-", forState: UIControlState.Normal)
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
            print(location)
            
            if location.horizontalAccuracy < 20 && locationActive==true {
                
                //update distance and coords if locationActive
                if self.locationsRoute.count > 0 {
                    distance += location.distanceFromLocation(self.locationsRoute.last!)
                    
                    //set chords for routes
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locationsRoute.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    //create Polyline
                    let line = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
                    mapView.addAnnotation(line)
                    
                    //center mapview by new coord
                    mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),  zoomLevel: 12,  animated: false)
                }
                
                 //save location to locationRoute array object
                self.locationsRoute.append(location)
                
            }
            
            
            //get current location on start and stop after updating location
            if(locationActive==false){
    
               mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),  zoomLevel: 12, animated: true)
               //locationManager.stopUpdatingLocation();
               print("Center map in startup")
            }
            
            //set debug vars
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            altitude = location.altitude
            accuracy = location.horizontalAccuracy
            speed = location.speed
        }
        
        
        if UIApplication.sharedApplication().applicationState == .Active {
            print("App is Foreground. New location is %@", second)
        } else {
            print("App is backgrounded. New location is %@", second)
        }
        
        
    }
}


// MARK: - MKMapViewDelegate
extension addRouteController: MGLMapViewDelegate {
    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 5.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        print("Color Annotion by speed: \(speed)")
        return colorStyles.polylineColors(speed*3.6)
    }
}