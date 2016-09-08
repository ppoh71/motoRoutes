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



final class imageUtils{
    
    
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
    class func drawLineOnImage(funcType: FuncTypes) -> UIImage{
        
        //def vars
        let drawHeight = 200
        //var rectangle =  CGRect(x: 0, y: 0, width: 0, height: 0)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 5, height: drawHeight), false, 0)
        var context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        CGContextTranslateCTM(context, 0, CGFloat(drawHeight));
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //get height and color for line
        let LineHeight = utils.getSpeed(globalSpeed.gSpeed)
        let LineColor = colorUtils.polylineColors(utils.getSpeedIndexFull(globalSpeed.gSpeed))
        let LineAltitude  = globalAltitude.gAltitude
        //LineAltitude = round(1000 * LineAltitude) / 1000
    
        //context stuff
        CGContextSetLineWidth(context, 1)
        
        //switch some func cases for image height
        switch funcType {
            
        case .Recording:
            //print("Recording")
            drawCircle(&context!, height: drawHeight, LineColor: LineColor)
            
        case .PrintCircles:
            //print("Recording")
            drawCircle(&context!, height: drawHeight, LineColor: LineColor)
        
        case .PrintBaseHeight:
            //print("Base")
            drawLine(&context!, drawHeight: drawHeight/2, LineHeight: LineHeight, LineColor: LineColor, perCent: 15, alpha: 0.3)

        case .PrintMarker:
            //print("PrintMarker")
            drawLine(&context!, drawHeight: drawHeight/2, LineHeight: LineHeight, LineColor: LineColor, perCent: 55, alpha: 0.4)
           
        case .PrintAltitude:
             //print("PrintAltitude \(LineAltitude)")
            //get height idsplay quotient
            //let altQuo = globalHighestAlt.gHighestAlt - globalLowestAlt.gLowesttAlt
            //let altDiffQuo = altQuo/Double(drawHeight)
            
            var newLineHeight = (LineAltitude - globalLowestAlt.gLowesttAlt) * Double(drawHeight) / (globalHighestAlt.gHighestAlt - globalLowestAlt.gLowesttAlt)
            
            guard newLineHeight > 0 else {
                break
            }
            
            //print(Int(LineAltitude/altDiffQuo))
            drawLine(&context!, drawHeight: (drawHeight/2) , LineHeight: Int(newLineHeight), LineColor: UIColor.whiteColor(), perCent: 30, alpha: 0.3)
        
        default:
            break
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    
    /* helper func draw circle line */
    static func drawCircle (inout context:CGContext, height:Int, LineColor : UIColor) {
        CGContextAddArc(context, 2.5, CGFloat(height/2), 1, 0, CGFloat(M_PI * 2), 0)
        CGContextSetFillColorWithColor(context,LineColor.CGColor)
        CGContextSetStrokeColorWithColor(context,LineColor.CGColor)
        CGContextDrawPath(context, .FillStroke)
    }
    
    
    /* helper func draw pixel line */
    static func drawLine (inout context: CGContext, drawHeight: Int, LineHeight: Int, LineColor: UIColor, perCent: Int, alpha: Double) {
        
        let heightPercent = LineHeight*perCent/100
        
        CGContextMoveToPoint(context,0, 0)
        CGContextSetAlpha(context, CGFloat(alpha));
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        let rectangle = CGRect(x: 0, y: drawHeight, width: 4, height: Int(heightPercent))
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)
        CGContextSetFillColorWithColor(context,LineColor.CGColor)
        CGContextFillRect(context, rectangle)
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