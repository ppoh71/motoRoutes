//
//  utils.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 25.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation


public class numberFormats  {

    
    static func clockFormat(totalSeconds:Int) -> String {
    
    
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    
    }
    

}
