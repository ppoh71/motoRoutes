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
    
    
 
    //location manager
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .AutomotiveNavigation
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
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
        
    }

    
    //
    // start function
    //
    func startLocationUpdates() {
        // init Location manger
        locationManager.startUpdatingLocation()
    }
    
    //
    // timer update per second
    //
    func perSecond(timer: NSTimer) {
        
        second++
        //let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        //timeLabel.text = timeFormatted(second)
        timeLabel.text = numberFormats.clockFormat(second)
        
        distanceLabel.text = "\(distance)"
        
        // let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        //let paceQuantity = HKQuantity(unit: paceUnit, intValue: seconds / distance)
        // accuracyLabel.text = "Pace: " + paceQuantity.description
       
        //location updates
        latitudeLabel.text = "La: \(latitude)"
        longitudeLabel.text = "Lo: \(longitude)"
        altitudeLabel.text = "Al: \(numberFormats.primaryLong(longitude, lat: latitude))"
        accuracyLabel.text = "\(accuracy)"
        
        //print(distance)
    }
    
    //
    // make clock from seconds
    //
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    
    //
    // save motoRoute to core data
    //
    func saveRoute() {
        
        
        // save to realm
        let newRoute = Route()
        
        newRoute.timestamp = NSDate()
        newRoute.distance = distance
        newRoute.duration = second
        
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
            
            //if location.horizontalAccuracy < 20 {
            //update distance
            if self.locationsRoute.count > 0 {
                distance += location.distanceFromLocation(self.locationsRoute.last!)
            }
            
            //set debug vars
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            altitude = location.altitude
            accuracy = location.horizontalAccuracy
            
            //save location
            self.locationsRoute.append(location)
            
          //  print(locationsRoute)
            
            // }
        }
    }


}