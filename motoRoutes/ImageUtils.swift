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

final class ImageUtils{
    
    /*
     * load images from path and return image
     */
    class func loadImageFromPath(_ path: NSString) -> UIImage? {
        let image = UIImage(contentsOfFile: path as String)
        
        if image == nil {
            print("missing image at: \(path)")
            return UIImage()
        } else{
            return image
        }
    }
    
    /*
     * load images by image name and from documantsDirectory
     */
    class func loadImageFromName(_ imgName: String) -> UIImage? {
        guard  imgName.characters.count > 0 else {
            print("ERROR: No image name")
            return UIImage()
        }
        
        let imgPath = Utils.getDocumentsDirectory().appendingPathComponent(imgName)
        let image = ImageUtils.loadImageFromPath(imgPath as NSString)
        
        return image
    }

    /*
     * resize image by width, no transparency on png
     */
    class func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    /*
     * scale image with also png with/alpha
     */
    class  func scaleImage(_ image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .high
        
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        context?.concatenate(flipVertical)
        context?.draw(image.cgImage!, in: newRect)
        
        let newImage = UIImage(cgImage: (context?.makeImage()!)!)
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /*
     * Scale image with core graphics
     */
    class func scaleImgaeCore(_ image: UIImage) -> UIImage{
        let cgImage = image.cgImage
        let width = (cgImage?.width)! / 3
        let height = (cgImage?.height)! / 3
        let bitsPerComponent = cgImage?.bitsPerComponent
        let bytesPerRow = cgImage?.bytesPerRow
        let colorSpace = cgImage?.colorSpace
        let bitmapInfo = cgImage?.bitmapInfo
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent!, bytesPerRow: bytesPerRow!, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        
        context!.interpolationQuality = .high
        context?.draw(cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
        
        let scaledImage = context?.makeImage().flatMap { UIImage(cgImage: $0) }
        
        return scaledImage!
    }
    
    /*
     draw a line on an image
     */
    class func drawLineOnImage(_ funcType: FuncTypes) -> UIImage{
        let drawHeight = 200
        //var rectangle =  CGRect(x: 0, y: 0, width: 0, height: 0)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 5, height: drawHeight), false, 0)
        var context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        context?.translateBy(x: 0, y: CGFloat(drawHeight));
        context?.scaleBy(x: 1.0, y: -1.0);
        
        //get height and color for line
        let LineHeight = Utils.getSpeed(globalSpeed.gSpeed)
        let LineColor = ColorUtils.polylineColors(Utils.getSpeedIndexFull(globalSpeed.gSpeed))
        let LineAltitude  = globalAltitude.gAltitude
        //LineAltitude = round(1000 * LineAltitude) / 1000
    
        //context stuff
        context?.setLineWidth(1)
        
        //switch some func cases for image height
        switch funcType {
            
        case .Recording:
            //print("Recording")
            drawCircle(&context!, width: 5, height: drawHeight, LineColor: LineColor)
            
        case .PrintCircles:
            //print("Recording")
            drawCircle(&context!, width: 5, height: drawHeight, LineColor: LineColor)
        
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
            
            let newLineHeight = (LineAltitude - globalLowestAlt.gLowesttAlt) * Double(drawHeight) / (globalHighestAlt.gHighestAlt - globalLowestAlt.gLowesttAlt)
            
            guard newLineHeight > 0 else {
                break
            }
            
            //print(Int(LineAltitude/altDiffQuo))
            drawLine(&context!, drawHeight: (drawHeight/2) , LineHeight: Int(newLineHeight), LineColor: UIColor.white, perCent: 30, alpha: 0.3)
        
        default:
            break
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    class func dotColorMarker(_ width: Int, height: Int, color: UIColor) -> UIImage {
    
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        var context = UIGraphicsGetCurrentContext()
        
        drawCircle(&context!, width: width, height: height, LineColor: color)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img!
    }
    
    /* helper func draw circle line */
    static func drawCircle (_ context:inout CGContext, width: Int, height:Int, LineColor : UIColor) {
        context.addArc(center: CGPoint(x: CGFloat(width/2), y: CGFloat(height/2)), radius:  CGFloat(width/2)-1, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        context.setFillColor(LineColor.cgColor)
        context.setStrokeColor(LineColor.cgColor)
        context.drawPath(using: .fillStroke)
    }
    
    /* helper func draw pixel line */
    static func drawLine (_ context: inout CGContext, drawHeight: Int, LineHeight: Int, LineColor: UIColor, perCent: Int, alpha: Double) {
        let heightPercent = LineHeight*perCent/100
        
        context.move(to: CGPoint(x: 0, y: 0))
        context.setAlpha(CGFloat(alpha));
        context.setStrokeColor(UIColor.white.cgColor)
        let rectangle = CGRect(x: 0, y: drawHeight, width: 4, height: Int(heightPercent))
        context.addRect(rectangle)
        context.strokePath()
        context.setFillColor(LineColor.cgColor)
        context.fill(rectangle)
    }
    
    class func drawSliderThumb(_ width:Int, height:Int, lineWidth: Int, color: UIColor, alpha: Int) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        context?.translateBy(x: 0, y: CGFloat(height));
        context?.scaleBy(x: 1.0, y: -1.0);
        
        context?.setLineWidth(CGFloat(lineWidth))
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.setAlpha(CGFloat(alpha));
        
        context?.setStrokeColor(color.cgColor)
        
        let rectangle = CGRect(x: 0, y: 0, width: lineWidth, height: height)
        context?.addRect(rectangle)
        context?.strokePath()
        context?.setFillColor(color.cgColor)
        context?.fill(rectangle)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    static func makeSpeedometerImage(_ width: Int, height: Int)-> UIImage{
        let colors = ColorPalette.colors
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        //flipp-coords
        context?.translateBy(x: 0, y: CGFloat(height));
        context?.scaleBy(x: 1.0, y: -1.0);
        
        for (index, color) in colors.enumerated() {
            let currentColor = ColorUtils.hexTorgbColor(color)
            context?.setStrokeColor(currentColor.cgColor)
            let rectangle = CGRect(x: 0, y: (height/colors.count)*index, width: width, height: height/colors.count)
            context?.addRect(rectangle)
            context?.strokePath()
            context?.setFillColor(currentColor.cgColor)
            context?.fill(rectangle)
            
            print(color)
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
        
    /*
     * save imge to file
     */
    class func saveImageToFile(_ image:UIImage, imageName: String){
        //screenShotRoute.image = screenShot
        if let data = UIImagePNGRepresentation(image) {
            let filename = Utils.getDocumentsDirectory().appendingPathComponent(imageName)
            let write = (try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])) != nil
            
            print("\(write) - \(filename)")
        }
    }
    
    /*
     * save imge to file
     */
    class func saveGoogleImageToFile(_ image:UIImage, key: Int, id: String) {
        if UIImagePNGRepresentation(image) != nil {
            ImageUtils.createDirectory(id)
            let filename = Utils.getDocumentsDirectory().appendingPathComponent("/\(id)/\(key).jpeg")
            
            try? UIImageJPEGRepresentation(image, 0.75)!.write(to: URL(fileURLWithPath: filename), options: [.atomic])
            print("\(write) - \(filename)")
        }
    }
    
    class func createDirectory(_ directoy: String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directoy)
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            print("created directory")
        }else{
            print("Already dictionary created.")
        }
    }
    
    /**
     * make screenshot and return full filename,
     */
    class func screenshotMap(_ mapView:MGLMapView, id: String) -> String{
        let filename = id + ".png"
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: mapView.frame.size.width*0.99,height: mapView.frame.size.height*0.99), false, 0)
        mapView.drawHierarchy(in: CGRect(x: 01, y: -01, width: mapView.frame.size.width, height: mapView.frame.size.height), afterScreenUpdates: true)
        
        let screenShot  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //resize image
        let scaledImage = ImageUtils.scaleImgaeCore(screenShot!)
        
        //screenShotRoute.image = screenShot
        if let data = UIImagePNGRepresentation(scaledImage) {
            let filenameDirectory = Utils.getDocumentsDirectory().appendingPathComponent(filename)
            try? data.write(to: URL(fileURLWithPath: filenameDirectory), options: [.atomic])
        }
        
        return filename
    }
} // end
