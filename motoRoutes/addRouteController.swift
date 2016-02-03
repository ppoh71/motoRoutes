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
    @IBOutlet weak var mapView: MKMapView!
    
    
 
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
    var locationActive = false
    
    
    
    
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
        altitudeLabel.text = "Al: \(altitude)"
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
        
        print("extension")
        
        for location in locations {
            
            print(location.coordinate.longitude)
            print(location.coordinate.latitude)
            print(location.altitude)
            print(location.speed)
            print(location.horizontalAccuracy)
            print("**********************")
            
            if location.horizontalAccuracy < 20 {
                
                //update distance and coords if locationActive
                if self.locationsRoute.count > 0 && locationActive==true{ //
                    distance += location.distanceFromLocation(self.locationsRoute.last!)
                    
                    //set chords for routes
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locationsRoute.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    //add map routes
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                    
                    //center map region
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
               
                }
                
                 //get current location on start and stop after updating location
                 if(locationActive==false){
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                     mapView.setRegion(region, animated: true)
                    
                     locationManager.stopUpdatingLocation();
                 }
                
                //save location to locationRoute array object
                self.locationsRoute.append(location)
                
            } // end horizontalAccur
            
            
            //set debug vars
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            altitude = location.altitude
            accuracy = location.horizontalAccuracy
            
        }
        
        
        if UIApplication.sharedApplication().applicationState == .Active {
            print("App is Foreground. New location is %@", second)
        } else {
            print("App is backgrounded. New location is %@", second)
        }
        
    }
}


// MARK: - MKMapViewDelegate
extension addRouteController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        print("mapview it is")
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5
        return renderer
    }
}