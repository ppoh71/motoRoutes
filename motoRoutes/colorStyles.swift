//
//  colorStyles.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 05.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit



class colorStyles {
    

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
    static func polylineColors(speed:Double) -> UIColor{

       //color spped palette in hex
       var colorSpeed: [String] = ["#ffffff", "#b2dfdb", "#80cbc4", "#4db6ac", "#26a69a", "#81c784", "#66bb6a", "#4caf50", "#43a047", "#ffb74d", "#ffa726", "#ff9800", "#fb8c00", "#ff7043", "#ff5722", "#ff5722", "#f4511e", "#ec407a", "#e91e63", "#d81b60", "#c2185b", "#ba68c8", "#ab47bc", "#9c27b0", "#8e24aa", "#7b1fa2"]
        
        //color var
        print("color operation")
        
        //get a speed int to look up the colorspeed array
        var speedInt:Int = Int(round(speed/10))

        
        //not faster than 250km/h
        if(speedInt>=25){
            speedInt = 25
        }
        
        print(speedInt)
        
        //retrun converted color speed color in ui.color
        return colorStyles.hexTorgbColor(colorSpeed[speedInt])
    }
}

