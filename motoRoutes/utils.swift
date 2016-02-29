//
//  utils.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 16.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import CoreLocation
import RealmSwift
import Mapbox



public class utils {


    /*
    * define the speedIndex. km/h / 10 = Index for speedcolors
    */
    class func getSpeedIndex(speed:Double) -> Int{
    
        let speedIndex = Int(round((speed*3.6)/10))
    
        return speedIndex
    
    }
    

    /*
    * helper get Document Directory
    */
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        //print("Path: \(documentsDirectory)")
        return documentsDirectory
    }
 
    
    /*
    * load images from path and return image
    */
    class func loadImageFromPath(path: NSString) -> UIImage? {
        
        print(path)
        
        let image = UIImage(contentsOfFile: path as String)
        
        print(image)
        if image == nil {
            
           print("missing image at: \(path)")
        }
        //print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
        
    }
    

    /*
    * check for connectivity, only wifi ?!
    */
    class func isConnected() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        
        return isReachable && !needsConnection
        
    }
    
    
    
    /*
    * return full clock time hh:mm:ss
    */
    static func clockFormat(totalSeconds:Int) -> String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
    }
    
    /*
    * return full short clock time mm:ss
    */
    static func clockFormatShort(totalSeconds:Int) -> String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
        
    }

    /*
    *   Performance time helper
    */
    class func absolutePeromanceTime(x:Double) -> String {
    
         let x = (CFAbsoluteTimeGetCurrent() - x) * 1000.0
         return  "Took \(x) milliseconds"
    
    }
   
    /*
    *   Performance time helper
    */
    class func distanceFormat(distance:Double) -> String {
        
        let dist = String(format: "%.3f", distance/1000)
        
        return  dist
        
    }
    
    /**
    * make screenshot and return full filename,
    */
    class func screenshotMap(mapView:MGLMapView) -> String{
    
         
            var filename:String = ""
            
            //take the timestamp for the imagename
            let timestampFilename = String(Int(NSDate().timeIntervalSince1970)) + ".png"
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(mapView.frame.size.width*0.99,mapView.frame.size.height*0.50), false, 0)
            //var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
            mapView.drawViewHierarchyInRect(CGRectMake(-01, -01, mapView.frame.size.width, mapView.frame.size.height), afterScreenUpdates: true)
      
            let screenShot  = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            
                //screenShotRoute.image = screenShot
                if let data = UIImagePNGRepresentation(screenShot) {
                    filename = utils.getDocumentsDirectory().stringByAppendingPathComponent(timestampFilename)
                    data.writeToFile(filename, atomically: true)
                }
            
            print("filename: \(filename as String)")
            print(timestampFilename)
            return filename
            
        }

    
    /**
    * save new route to realm
    */
    class func saveRouteRealm(locationsRoute:[CLLocation], screenshotFilename:String, startTimestamp:Int, distance:Double, totalTime:Int ){
    
        // save to realm
        let newRoute = Route()
        
        newRoute.id = UIDevice.currentDevice().identifierForVendor!.UUIDString + "#" + String(startTimestamp)
        newRoute.timestamp = NSDate()
        newRoute.distance = distance
        newRoute.duration = totalTime
        newRoute.image = screenshotFilename
        
        for location in locationsRoute {
            
            let newLocation = Location()
            
            newLocation.timestamp = location.timestamp
            newLocation.latitude = location.coordinate.latitude
            newLocation.longitude = location.coordinate.longitude
            newLocation.altitude = location.altitude
            newLocation.speed = location.speed
            newLocation.accuracy = location.horizontalAccuracy
            
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
    


    
    //Bound Structure
    struct coordBound{
        var north:Double = 0
        var south:Double = 0
        var west:Double = 0
        var east:Double = 0
    }
    
    /**
     * Get most north, south, west & east coords
     * to create bound rectangle
     * by location array
     */
    class func getBoundCoords(locationsRoute:[CLLocation]) -> coordBound{
    
       //create new bound struct
       var newCoordBound = coordBound()
        
        //loop if we have locations
        if(locationsRoute.count > 0) {
            
            //init with first vars
            newCoordBound.north = locationsRoute[0].coordinate.latitude
            newCoordBound.south = locationsRoute[0].coordinate.latitude
            newCoordBound.west = locationsRoute[0].coordinate.longitude
            newCoordBound.east = locationsRoute[0].coordinate.longitude
           
            //loop fot all coords in a array and set bounds
            for location in locationsRoute {
               
                //set most west
                if(location.coordinate.latitude > newCoordBound.north){
                    newCoordBound.north = location.coordinate.latitude
                }
                
                //set most south
                if(location.coordinate.latitude < newCoordBound.south){
                    newCoordBound.south = location.coordinate.latitude
                }
                
                //Set most west
                if(location.coordinate.longitude < newCoordBound.west){
                    newCoordBound.west = location.coordinate.longitude
                }
        
                //set most east
                if(location.coordinate.longitude < newCoordBound.west){
                    newCoordBound.west = location.coordinate.longitude
                }
            
        }
        }
        print("struct")
        print(newCoordBound)
        
        return newCoordBound

    }
    
    

}