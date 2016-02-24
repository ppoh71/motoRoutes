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
   
    
    /**
    * make screenshot and return full filename,
    */
    class func screenshotMap(mapView:MGLMapView) -> String{
    
         
            var filename:String = ""
            
            //take the timestamp for the imagename
            let timestampFilename = String(Int(NSDate().timeIntervalSince1970)) + ".png"
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(mapView.frame.size.width*0.99,mapView.frame.size.height*0.70), false, 0)
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


    

}