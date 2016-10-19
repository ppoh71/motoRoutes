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


final class Utils {
    
    /*
     * get Time stamp
     */
    class func getTimestamp()->Int{
        
           return Int(Date().timeIntervalSince1970)
    }

    
    class func getUniqueUUID()->String{
        return  UUID().uuidString
    }
    
    /*
    * define the speedIndex. km/h / 10 = Index for speedcolors
    */
    class func getSpeedIndex(_ speed:Double) -> Int{
    
        let speedIndex = Int(round((speed*3.6)/10))
        //let speedIndex = 5
      
        switch speedIndex {
        
        case 0:
            return 12
            
        case 1..<7:
           return 2
        
        case 8..<16:
            return 8
            
        case 12..<50:
            return 12
            
        default:
            return 1
            
        }
    
       // return speedIndex
    
    }
    
    /*
     * define the speedIndex. km/h / 10 = Index for speedcolors
     */
    class func getSpeedIndexFull(_ speed:Double) -> Int{
        
        let speedIndex = Int(round((speed*3.6)/10))
        //let speedIndex = 5
        
        return speedIndex
        
    }
    
    /*
    * get speed km/h mph
    */
    class func getSpeed(_ speed:Double) -> Int{
        
        let speed = Int(round((speed*3.6))) //kmh
        //not 0 in return
        //speed = speed == 0 ? 120 : speed
        return speed
    }
    
    /*
     * get speed Double km/h mph
     */
    class func getSpeedDouble(_ speed:Double) -> Double{
        
        let speed = round((speed*3.6)) //kmh
        //not 0 in return
        //speed = speed == 0 ? 120 : speed
        return speed
    }
    
    /*
     * get speed km/h mph
     */
    class func getSpeedString(_ speed:Double) -> String{
        let speed = speed*3.6//kmh
        
        return String(format: "%.2f", speed)
    }
    
    /*
     * get stringformat from double
     */
    class func getDoubleString(_ double:Double) -> String{
        return String(format: "%.2f", double)
    }
    
    /**
    * Sets globalSppedSet by given speed (m/s)
    */
    class func setGlobalSpeedSet(_ speed:Double){
       
        // define speedIndex and set first Index
        let speedIndex:Int = Utils.getSpeedIndex(speed)
        globalSpeedSet.speedSet = speedIndex

    }
    

    /*
    * helper get Document Directory
    */
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        //print("Path: \(documentsDirectory)")
        return documentsDirectory as NSString
    }
 
    
    
    /*
    * return full clock time hh:mm:ss
    */
    static func clockFormat(_ totalSeconds:Int) -> String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        var time: String
        
        if(hours<1){
           time = String(format: "%02d:%02d", minutes, seconds)
        } else {
             time = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        return time
    }
    
    /*
    * return full short clock time mm:ss
    */
    static func clockFormatShort(_ totalSeconds:Int) -> String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
        
    }

    
    /* 
    *   Performance time helper
    */
    class func absolutePeromanceTime(_ x:Double) -> String {
    
         let x = (CFAbsoluteTimeGetCurrent() - x) * 1000.0
         return  "Took \(x) milliseconds"
    }
    
   
    /*
    *   distance Formate
    */
    class func distanceFormat(_ distance:Double) -> String {
        
        let dist = String(format: "%.3f", distance/1000)
        return  dist
    }
    
    

    
    class func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
        
        //print("DISPATCH_TIME_NOW \(DISPATCH_TIME_NOW)")
    }
    
    
        


}
