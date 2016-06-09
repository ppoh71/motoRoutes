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
        
        //print(path)
        
        let image = UIImage(contentsOfFile: path as String)
        
        //print(image)
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
     * resize image by width, no transparency on png
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
    * Scale image with core graphics
    */
    
    class func scaleImgaeCore(image: UIImage) -> UIImage{
        
        let cgImage = image.CGImage
        
        let width = CGImageGetWidth(cgImage) / 2
        let height = CGImageGetHeight(cgImage) / 2
        let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
        let bytesPerRow = CGImageGetBytesPerRow(cgImage)
        let colorSpace = CGImageGetColorSpace(cgImage)
        let bitmapInfo = CGImageGetBitmapInfo(cgImage)
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextSetInterpolationQuality(context, .High)
        
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), cgImage)
        
        let scaledImage = CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0) }
    
        return scaledImage!
    
    }
    
    /*
      draw a line on an image
     
     - parameter type: print for recording and scrren shot use String "Recording" else nil
     
     */
    static func drawLineOnImage(type: String?) -> UIImage{
        
        //let performanceTime = CFAbsoluteTimeGetCurrent()
        
        let drawHeight = 200
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 5, height: drawHeight), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        CGContextTranslateCTM(context, 0, CGFloat(drawHeight));
        CGContextScaleCTM(context, 1.0, -1.0);
       
        
        //get height and color for line

        let LineHeight = utils.getSpeed(globalSpeed.gSpeed)
        let LineColor = colorUtils.polylineColors(utils.getSpeedIndexFull(globalSpeed.gSpeed))
        let LineAltitude  = Int(globalAltitude.gAltitude/10)
        //LineAltitude = random() % 200
        
        //percentage height of line image
        //let percent = 55
       
        let altitudePercent = LineAltitude*40/100
        
        //make rect with height, position midddle due to mapbox marker image settings
        
        
        
        //context stuff
       
        CGContextSetLineWidth(context, 1)
        CGContextMoveToPoint(context,0, 0)
       
        
        
        /**
        * change values hwen recording route and making screenshot of route
        **/
        var rectangle =  CGRect(x: 0, y: 0, width: 0, height: 0)
        
        if let typeX = type where type=="Recording" {
            let heightPercent = LineHeight*15/100
            CGContextSetAlpha(context,0.8);
            CGContextSetStrokeColorWithColor(context, LineColor.CGColor)
            rectangle = CGRect(x: 0, y: drawHeight/2, width: 2, height: 2)
        
        }else{ //default values for printing markers in show mode
            let heightPercent = LineHeight*55/100
            CGContextSetAlpha(context,0.4);
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            rectangle = CGRect(x: 0, y: drawHeight/2, width: 4, height: Int(heightPercent))
        }
        
        
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)
        CGContextSetFillColorWithColor(context,LineColor.CGColor)
        CGContextFillRect(context, rectangle)
        
        /*
        //CGContextDrawPath(context, .FillStroke)
        CGContextSetAlpha(context,0.9);
        let altrectangle = CGRect(x: 2, y: drawHeight/2 + altitudePercent, width: 1, height: 1)
        CGContextMoveToPoint(context,1, 0)
        CGContextSetStrokeColorWithColor(context, UIColor.cyanColor().CGColor)
        CGContextSetFillColorWithColor(context,UIColor.cyanColor().CGColor)
        CGContextAddRect(context, altrectangle)
        CGContextDrawPath(context, .FillStroke)
        */
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
         //print("Image took: \(utils.absolutePeromanceTime(performanceTime)) ")
        //saveImageToFile(img, imageName: "Marker-Speed-\(Int(globalSpeed.gSpeed)).png")
        //print("draw image\(utils.getSpeed(globalSpeed.gSpeed)).png")
        
        return img
        
    }
    
   
    
    class func drawSliderThumb(width:Int, height:Int, lineWidth: Int, color: UIColor, alpha: Int) -> UIImage{
    
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        CGContextTranslateCTM(context, 0, CGFloat(height));
        CGContextScaleCTM(context, 1.0, -1.0);
        
       
        CGContextSetLineWidth(context, CGFloat(lineWidth))
        CGContextMoveToPoint(context,0, 0)
        CGContextSetAlpha(context, CGFloat(alpha));
        
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        
        let rectangle = CGRect(x: 0, y: 0, width: lineWidth, height: height)
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)
        CGContextSetFillColorWithColor(context,color.CGColor)
        CGContextFillRect(context, rectangle)
        
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    
    
    static func makeSpeedometerImage(width: Int, height: Int)-> UIImage{
    
        let colors = ColorPalette.colors
        
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        CGContextTranslateCTM(context, 0, CGFloat(height));
        CGContextScaleCTM(context, 1.0, -1.0);
        
        for (index, color) in colors.enumerate() {
        
            
            let currentColor = colorUtils.hexTorgbColor(color)
            CGContextSetStrokeColorWithColor(context, currentColor.CGColor)
            
            
            
            let rectangle = CGRect(x: 0, y: (height/colors.count)*index, width: width, height: height/colors.count)
            CGContextAddRect(context, rectangle)
            CGContextStrokePath(context)
            CGContextSetFillColorWithColor(context, currentColor.CGColor)
            CGContextFillRect(context, rectangle)

            print(color)
        
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    /*
     * generate spped marker images
     */
    /*
    class func generateSpeedMarker(){
        
        var x:Double = 0;
        
        while x<350 {
            globalSpeed.gSpeed = x
                      x += 1
            //print("key: \(x) ")
        }
    }
    */
    
    /*
     * save imge to file
     */
    class func saveImageToFile(image:UIImage, imageName: String){
        
        //screenShotRoute.image = screenShot
        if let data = UIImagePNGRepresentation(image) {
            let filename = utils.getDocumentsDirectory().stringByAppendingPathComponent(imageName)
            data.writeToFile(filename, atomically: true)
        }
        
        //print("IMAGE SAVED")
    }
    
    
    /**
     * make screenshot and return full filename,
     */
    class func screenshotMap(mapView:MGLMapView) -> String{
        
        
        var filename:String = ""
        
        //take the timestamp for the imagename
        let timestampFilename = String(Int(NSDate().timeIntervalSince1970)) + ".png"
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(mapView.frame.size.width*0.99,mapView.frame.size.height*0.99), false, 0)
        //var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        mapView.drawViewHierarchyInRect(CGRectMake(01, -01, mapView.frame.size.width, mapView.frame.size.height), afterScreenUpdates: true)
        
        let screenShot  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        //resite image 
        let scaledImage = imageUtils.scaleImgaeCore(screenShot)
        
        //screenShotRoute.image = screenShot
        if let data = UIImagePNGRepresentation(scaledImage) {
            filename = utils.getDocumentsDirectory().stringByAppendingPathComponent(timestampFilename)
            data.writeToFile(filename, atomically: true)
        }
        
        //print("filename: \(filename as String)")
        //print(timestampFilename)
        //print(utils.getDocumentsDirectory())
        
        return timestampFilename
        
    }


} // end