//
//  colorStyles.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 05.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

//Struct
struct ColorPalette {
    static let  colors:[String] = ["#ffffff", "#C8E6C9", "#A5D6A7", "#81C784", "#66BB6A", "#4CAF50", "#43A047", "#CE93D8", "#BA68C8", "#AB47BC", "#9C27B0", "#8E24AA", "#7B1FA2", "#D500F9", "#AA00FF", "#FF4081", "#F50057", "#C51162", "#880E4F", "#E53935", "#D32F2F", "#C62828", "#AA00FF", "#B71C1C", "#B71C1C", "#B71C1C"]
}

class colorUtils {
    


    
    //assign instance to global static
   // Holder.staticInstance = initInstance
 
 
    //random color
    static func randomColor() -> UIColor {
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let g = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let b = CGFloat(arc4random()) / CGFloat(UInt32.max)
        
        // If you wanted a random alpha, just create another
        // random number for that too.
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    
    //get rgb color from hexcoler
    static func hexTorgbColor(hexcolor:String) -> UIColor {

        let hex = hexcolor.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clearColor()
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    
    //get colors by speed
    static func polylineColors(speed:Int) -> UIColor{

       //color spped palette in hex
       var colorSpeed = ColorPalette.colors
        
        //color var
        //print("color operation")
        
        //get a speed int to look up the colorspeed array
        var speedInt:Int = speed
        

        
        //not faster than 250km/h
        if(speedInt>=25){
            speedInt = 25
        }
        
        //print(speedInt)
        
        //retrun converted color speed color in ui.color
        return colorUtils.hexTorgbColor(colorSpeed[speedInt])
    }
}

