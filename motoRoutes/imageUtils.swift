//
//  imageUtils.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 15.04.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import Mapbox



class imageUtils{


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
        let image = imageUtils.loadImageFromPath(imgPath)
        
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
    
    
    /*
     * scale image with also png with/alpha
     */
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
    
    
    /*
     * draw a line on an image
     */
    class func drawLineOnImage() -> UIImage{
        
        let performanceTime = CFAbsoluteTimeGetCurrent()
        
        let drawHeight = 200
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: drawHeight), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        CGContextTranslateCTM(context, 0, CGFloat(drawHeight));
        CGContextScaleCTM(context, 1.0, -1.0);
       
        
        //get height and color for line

        let LineHeight = utils.getSpeed(globalSpeed.gSpeed)
        let LineColor = colorUtils.polylineColors(utils.getSpeedIndexFull(globalSpeed.gSpeed))
        let LineAltitude  = Int(globalAltitude.gAltitude/10)
        
        //percentage height of line image
        let percent = 35
        let heightPercent = LineHeight*percent/100
        let altitudePercent = LineAltitude*60/100
        
        //make rect with height, position midddle due to mapbox marker image settings
        let rectangle = CGRect(x: 0, y: drawHeight/2, width: 1, height: Int(heightPercent))
        
       
        let altrectangle = CGRect(x: 0, y: (drawHeight/2), width: 1, height: altitudePercent)
        
        //context stuff
       
        CGContextSetLineWidth(context, 5)
        CGContextMoveToPoint(context,0, 0)
        
        
        CGContextAddRect(context, rectangle)
        CGContextSetStrokeColorWithColor(context, LineColor.CGColor)
        CGContextDrawPath(context, .FillStroke)
        
        
        CGContextSetLineWidth(context, 2)
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextAddRect(context, altrectangle)
        CGContextDrawPath(context, .FillStroke)
        
    
        
         CGContextSetAlpha(context,0.4);
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
         print("Image took: \(utils.absolutePeromanceTime(performanceTime)) ")
        //saveImageToFile(img, imageName: "Marker-Speed-\(Int(globalSpeed.gSpeed)).png")
        //print("draw image\(utils.getSpeed(globalSpeed.gSpeed)).png")
        
        return img
        
    }
    
    
    
    /*
     * generate spped marker images
     */
    class func generateSpeedMarker(){
        
        var x:Double = 0;
        
        while x<350 {
            globalSpeed.gSpeed = x
            var img = imageUtils.drawLineOnImage()
            x += 1
            print("key: \(x) ")
        }
    }
    
    /*
     * save imge to file
     */
    class func saveImageToFile(image:UIImage, imageName: String){
        
        //screenShotRoute.image = screenShot
        if let data = UIImagePNGRepresentation(image) {
            let filename = utils.getDocumentsDirectory().stringByAppendingPathComponent(imageName)
            data.writeToFile(filename, atomically: true)
        }
        
        print("IMAGE SAVED")
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


} // end