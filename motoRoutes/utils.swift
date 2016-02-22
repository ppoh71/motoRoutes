//
//  utils.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 16.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RealmSwift
import Mapbox


class utils {

    
    //define the speedIndex. km/h / 10 = Index for speedcolors
    class func getSpeedIndex(speed:Double) -> Int{
    
        let speedIndex = Int(round((speed*3.6)/10))
    
        return speedIndex
    
    }
    
    //helper get Document Directory
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        //print("Path: \(documentsDirectory)")
        return documentsDirectory
    }
 
    
    //load images from path and return image
    class func loadImageFromPath(path: NSString) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path as String)
        
        if image == nil {
            
           // print("missing image at: \(path)")
        }
        //print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
        
    }
    
    
    //return full clock time hh:mm:ss
    static func clockFormat(totalSeconds:Int) -> String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
    }
    
    //return full short clock time mm:ss
    static func clockFormatShort(totalSeconds:Int) -> String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
        
}