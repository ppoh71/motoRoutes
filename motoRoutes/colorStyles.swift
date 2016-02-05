//
//  colorStyles.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 05.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


class colorStyles {
    
    
    //get colors by speed
    static func polylineColors(speed:Double) -> UIColor{
        
        //color var
        var polyRouteColor:UIColor = UIColor.redColor()
        var colorTest = "TEst"
        
        
        
            //switch for colors by speed
            switch true {
                
                case speed > 130:
                    colorTest = "130"
                    polyRouteColor = UIColor(red: 234/255, green: 54/255, blue: 0/255, alpha: 1.0) /* #ea3600 */
                    
                case speed > 120:
                     colorTest = "120"
                    polyRouteColor = UIColor(red: 239/255, green: 115/255, blue: 0/255, alpha: 1.0) /* #ef7300 */
                    
                case speed > 110:
                     colorTest = "110"
                    polyRouteColor = UIColor(red: 255/255, green: 161/255, blue: 0/255, alpha: 1.0) /* #ffa100 */
                    
                case speed > 100:
                     colorTest = "100"
                    polyRouteColor = UIColor(red: 255/255, green: 0/255, blue: 16/255, alpha: 1.0) /* #ff0010 */
                    
                case speed > 90:
                    colorTest = "90"
                    polyRouteColor = UIColor(red: 255/255, green: 0/255, blue: 114/255, alpha: 1.0) /* #ff0072 */
                    
                case speed > 80:
                     colorTest = "80"
                    polyRouteColor = UIColor(red: 229/255, green: 0/255, blue: 255/255, alpha: 1.0) /* #e500ff */
                    
                case speed > 70:
                     colorTest = "70"
                    polyRouteColor = UIColor(red: 255/255, green: 191/255, blue: 0/255, alpha: 1.0) /* #ffbf00 */
                    
                case speed > 60:
                     colorTest = "60"
                    polyRouteColor = UIColor(red: 221/255, green: 255/255, blue: 0/255, alpha: 1.0) /* #ddff00 */
                    
                case speed > 50:
                     colorTest = "50"
                    polyRouteColor = UIColor(red: 0/255, green: 255/255, blue: 80/255, alpha: 1.0) /* #00ff50 */
                    
                case speed > 40:
                     colorTest = "40"
                    polyRouteColor = UIColor(red: 0/255, green: 255/255, blue: 199/255, alpha: 1.0) /* #00ffc7 */
                    
                case speed > 30:
                     colorTest = "30"
                    polyRouteColor = UIColor(red: 0/255, green: 242/255, blue: 255/255, alpha: 1.0) /* #00f2ff */
                    
                case speed > 20:
                     colorTest = "20"
                    polyRouteColor = UIColor(red: 0/255, green: 182/255, blue: 255/255, alpha: 1.0) /* #00b6ff */
                    
                case speed > 10:
                     colorTest = "10"
                    polyRouteColor = UIColor(red: 0/255, green: 148/255, blue: 255/255, alpha: 1.0)

                
            case speed > 7:
                polyRouteColor = UIColor(red: 234/255, green: 54/255, blue: 0/255, alpha: 1.0) /* #ea3600 */

                
            case speed > 4:
                polyRouteColor = UIColor(red: 255/255, green: 161/255, blue: 0/255, alpha: 1.0) /* #ffa100 */
                

                default:
                    polyRouteColor = UIColor(red: 255/255, green: 216/255, blue: 249/255, alpha: 1.0) /* #ffd8f9 */
                    
                }

        
//        print(speed)
//        print(colorTest)
//        print(polyRouteColor)
        
        return polyRouteColor
    }
    
    
}
