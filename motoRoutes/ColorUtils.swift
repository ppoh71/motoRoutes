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
    static var  colorsTest:[String] = [
        "#ffffff", // 0
        "#C8E6C9", // 10
        "#A5D6A7", // 20
        "#81C784", // 30
        "#66BB6A", // 40
        "#4CAF50", // 50
        "#43A047", // 60
        "#CE93D8", // 70 Lila
        "#BA68C8", // 80
        "#AB47BC", // 90
        "#9C27B0", // 100
        "#8E24AA", // 110
        "#7B1FA2", // 120
        "#D500F9", // 130
        "#AA00FF", // 140
        "#FF4081", // 150
        "#F50057", // 160
        "#C51162", // 170
        "#880E4F", // 180
        "#E53935", // 190
        "#D32F2F", // 200
        "#C62828", // 210
        "#AA00FF", // 220
        "#B71C1C", // 230
        "#B71C1C", // 240
        "#B71C1C"] // 250

    
    static var  colors:[String] = [
        "#ffffff", // 0
        "#A5D6A7", // 10 Green 300
        "#81C784", // 20
        "#66BB6A", // 30
        "#4CAF50", // 40
        "#43A047", // 50
        "#FFF176", // 60 Yellow 300
        "#FFEE58", // 70
        "#FFEB3B", // 80
        "#FDD835", // 90
        "#FFCA28", // 100 Orange 300
        "#FFC107", // 110
        "#FFB300", // 120
        "#FFA000", // 130
        "#FF8F00", // 140
        "#EF5350", // 150 Red 300
        "#F44336", // 160
        "#E53935", // 170
        "#D32F2F", // 180
        "#C62828", // 190
        "#F06292", // 200 Pink 300
        "#EC407A", // 210
        "#E91E63", // 220
        "#D81B60", // 230
        "#B71C1C", // 240
        "#B71C1C"] // 250


    
}

final class ColorUtils {
    
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
    static func hexTorgbColor(_ hexcolor:String) -> UIColor {

        let hex = hexcolor.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    
    //get colors by speed
    static func polylineColors(_ speed:Int) -> UIColor{

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
        return ColorUtils.hexTorgbColor(colorSpeed[speedInt])
    }
    
    
    static func getGradient() -> CGGradient {
    
//        let colorTop = UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
//        let colorBottom = UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0).CGColor
        
        let startColor: UIColor = UIColor.white
        let endColor: UIColor = UIColor.lightGray
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
    
        return gradient!
    }
    
}

