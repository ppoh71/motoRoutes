//
//  addRouteController.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 21.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import Foundation


class addRouteController: UIViewController {

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
    @IBOutlet var recRoute:UIButton!
    
 
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
    
    //location and timer vars
    lazy var locationsRoute = [CLLocation]()
    lazy var timer = NSTimer()
    var second = 0
    var distance = 0.0
    var latitude:Double = 0
    var longitude:Double = 0
    var altitude:Double = 0
    
    

    
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
        timeLabel.text = timeFormatted(second)
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        distanceLabel.text = distanceQuantity.description
        
        // let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        //let paceQuantity = HKQuantity(unit: paceUnit, intValue: seconds / distance)
        // accuracyLabel.text = "Pace: " + paceQuantity.description

        //location updates
        latitudeLabel.text = "La: \(latitude)"
        longitudeLabel.text = "Lo: \(longitude)"
        altitudeLabel.text = "Al: \(altitude)"
        
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
    // save route to core data
    //
    func saveRoute() {
        // 1
        
        
        let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Route", inManagedObjectContext: managedObjectContext!) as! Route
        savedRun.distance = distance
        savedRun.duration = second
        savedRun.timestamp = NSDate()
        
        
        // 2
        var savedLocations = [Location]()
        for location in locationsRoute {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location",
                inManagedObjectContext: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        // 3
        var error: NSError?
        let success = managedObjectContext!.save(&error)
        if !success {
            print("Could not save the run!")
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
            
            print(location)
            
            //if location.horizontalAccuracy < 20 {
            //update distance
            if self.locationsRoute.count > 0 {
                distance += location.distanceFromLocation(self.locationsRoute.last!)
            }
            
            //set debug vars
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            altitude = location.altitude
            
            
            //save location
            self.locationsRoute.append(location)
            
            print(locationsRoute)
            
            // }
        }
    }


}