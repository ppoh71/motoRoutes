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
        //let speedIndex = 5
      
        
        switch speedIndex {
        
        //case 0..<5:
          //  return 5
            
        //case 5..<8:
         //  return 8
            
        case 0..<8:
           return 5
        
        case 8..<16:
            return 12
            
        case 12..<50:
            return 14
            
        default:
            return 1
            
        }
    
       // return speedIndex
    
    }
    
    /*
    * get speed km/h mph
    */
    class func getSpeed(speed:Double) -> Int{
        
        let speed = Int(round((speed*3.6))) //kmh
        
        return speed
        
    }
    
    
    /**
    * Sets globalSppedSet by given speed (m/s)
    */
    class func setGlobalSpeedSet(speed:Double){
       
        // define speedIndex and set first Index
        let speedIndex:Int = utils.getSpeedIndex(speed)
        globalSpeedSet.speedSet = speedIndex

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
    * load images by image name and from documantsDirectory
    */
    class func loadImageFromName(imgName: String) -> UIImage? {
        
        guard  imgName.characters.count > 0 else {
        
            print("ERROR: No image name")
            return UIImage()
            
        }
        
        let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgName)
        let image = utils.loadImageFromPath(imgPath)

        return image
        
    }
    
    
    /*
    * resize image by width, no transparncy on png
    */
    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    

    class  func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context, flipVertical)
        CGContextDrawImage(context, newRect, image.CGImage)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    class func drawLineOnImage() -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 200), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // awesome drawing code
        let height = globalLineAltitude.gLineAltitude
        //let rectangle = CGRect(x: 0, y: 0, width: 1, height: height)
        
        
        CGContextMoveToPoint(context, 5, 100)
        CGContextAddLineToPoint(context, 0, 100+CGFloat(height))
       // print(height)
        
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 5)
        CGContextSetAlpha(context,0.6);
        CGContextDrawPath(context, .FillStroke)
        
        
        //CGContextAddRect(context, rectangle)
        
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return img
    
    }
    
    
    
    class func drawSpeedMarkerImage() -> UIImage{
        
       
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 20), false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        let rectangle = CGRect(x: 25, y: 25, width: 25, height: 10)
        
         CGContextAddArc(context, 10, 10, 5, 0.0, CGFloat(M_PI * 2.0), 1)
        
        CGContextSetFillColorWithColor(context, colorStyles.polylineColors(globalSpeedSet.speedSet).CGColor)
        CGContextSetStrokeColorWithColor(context, colorStyles.polylineColors(globalSpeedSet.speedSet).CGColor)
        
        CGContextSetLineWidth(context, 1)
        
        //CGContextAddRect(context, rectangle)
       
        CGContextDrawPath(context, .FillStroke)
        
        
        

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
        
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
            print(utils.getDocumentsDirectory())

            return timestampFilename
            
        }

    
    /**
        Save new route to realm
     
        - parameter locatiobRoute: [CLLocation] List with locations
        - parameter screenshotFilename: filename of screenshot
        - parameter startTimestamp: [starttime unix int
        - parameter distance: distance in m
        - parameter totalTime: total tine in seconds
    
    *
    */
    
    class func saveRouteRealm(LocationsRoute:[CLLocation], MediaObjects: [MediaMaster], screenshotFilename:String, startTimestamp:Int, distance:Double, totalTime:Int ){
    
        // save to realm
        let newRoute = Route()
        
        newRoute.id = UIDevice.currentDevice().identifierForVendor!.UUIDString + "#" + String(startTimestamp)
        newRoute.timestamp = NSDate()
        newRoute.distance = distance
        newRoute.duration = totalTime
        newRoute.image = screenshotFilename
        
        // distance calc
        var locationDistance = 0.0
        var lastLocation = LocationsRoute[0]
        
        //add Locations to Realm Objctes
        for location in LocationsRoute {
            
            
            //calc distance
            locationDistance += location.distanceFromLocation(lastLocation)
            lastLocation = location
            
            print("locationdistance: \(locationDistance)" )
            
            let newLocation = Location()
            
            newLocation.timestamp = location.timestamp
            newLocation.latitude = location.coordinate.latitude
            newLocation.longitude = location.coordinate.longitude
            newLocation.altitude = location.altitude
            newLocation.speed = location.speed
            newLocation.course = location.course
            newLocation.accuracy = location.horizontalAccuracy
            
            newRoute.locationsList.append(newLocation)
            
        }
        
        //add Media to Realm Objctes
        for media in MediaObjects {
            
            let newMedia = Media()
            
            newMedia.latitude = media.latitude
            newMedia.longitude  = media.longitude
            newMedia.timestamp  = media.timestamp
            newMedia.image = media.image
            
            newRoute.mediaList.append(newMedia)
            
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
     *
     * - parameter locatiobRoute: [CLLocation] List with locations
     *
     * - returns: coordBound struct n,e,s,w with geo bounds rectangle for mapbox
     */
    class func getBoundCoords(_locationsMaster:[LocationMaster]) -> MGLCoordinateBounds{
    
        
        print("#################Coords")
        print(_locationsMaster)
        
       //create new bound struct
       var newCoordBound = coordBound()
        
        //loop if we have locations
        guard _locationsMaster.count > 10 else {
            print("GUARD bounds: locationRoute count 0")
            let coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 0, longitude: 0))

            return coordBounds
        }
        
            //init with first vars
            newCoordBound.north = _locationsMaster[0].latitude
            newCoordBound.south = _locationsMaster[0].latitude
            newCoordBound.west = _locationsMaster[0].longitude
            newCoordBound.east = _locationsMaster[0].longitude
           
            //loop fot all coords in a array and set bounds
            for location in _locationsMaster {
               
                //set most west
                if(location.latitude > newCoordBound.north){
                    newCoordBound.north = location.latitude
                }
                
                //set most south
                if(location.latitude < newCoordBound.south){
                    newCoordBound.south = location.latitude
                }
                
                //Set most west
                if(location.longitude < newCoordBound.west){
                    newCoordBound.west = location.longitude
                }
        
                //set most east
                if(location.longitude < newCoordBound.west){
                    newCoordBound.west = location.longitude
                }
            
        }

        print("struct")
        print(newCoordBound)
        
        let coordBounds = MGLCoordinateBoundsMake(CLLocationCoordinate2D(latitude: newCoordBound.south, longitude: newCoordBound.east), CLLocationCoordinate2D(latitude: newCoordBound.north, longitude: newCoordBound.west))
        
        return coordBounds

    }
    
    
    /**
     * Convert CLLocation[] to Location Master Object
     *
     * - parameter locatiobRoute: [CLLocation] List with locations
     *
     * - returns: LocationMaster 
     */
    class func masterLocation(locationsRoute:[CLLocation]) -> [LocationMaster]{
        
        print("#################MasterLocation")
        print(locationsRoute)
        
        var newlocationMaster = [LocationMaster]()
        
        //loop all CLLocation and create and append to LocationMaster
        for location in locationsRoute {
            
            let locationTmp = LocationMaster()
            
            locationTmp.timestamp = location.timestamp
            locationTmp.latitude = location.coordinate.latitude
            locationTmp.longitude = location.coordinate.longitude
            locationTmp.altitude = location.altitude
            locationTmp.speed = location.speed
            locationTmp.course = location.course
            locationTmp.accuracy = location.horizontalAccuracy
            
            newlocationMaster.append(locationTmp)
        
        }
        return newlocationMaster
    }
    
    
    
    /**
     * Convert CLLocation[] to Location Master Object
     *
     * - parameter locatiobRoute: [CLLocation] List with locations
     *
     * - returns: LocationMaster
     */
    class func masterRealmLocation(LocationsList:List<Location>!) -> [LocationMaster]{
        
        var newlocationMaster = [LocationMaster]()
        
        //loop all CLLocation and create and append to LocationMaster
        for location in LocationsList {
            
            let locationTmp = LocationMaster()
            
            locationTmp.timestamp = location.timestamp
            locationTmp.latitude = location.latitude
            locationTmp.longitude = location.longitude
            locationTmp.altitude = location.altitude
            locationTmp.speed = location.speed
            locationTmp.course = location.course
            locationTmp.accuracy = location.accuracy
           
            newlocationMaster.append(locationTmp)
            
        }
        return newlocationMaster
    }
    
    

}