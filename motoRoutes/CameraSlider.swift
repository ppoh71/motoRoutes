//
//  CameraSlider.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 12.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


public class CameraSlider: UISlider{

    
    required public init(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)!
    

        //set trans image for track
        let transImg = imageUtils.drawSliderThumb(1, height: 1, lineWidth: 1, color: UIColor.blackColor(), alpha: 0)
        
        
        self.setMinimumTrackImage(transImg, forState: UIControlState.Normal)
        self.setMinimumTrackImage(transImg, forState: UIControlState.Highlighted)
        self.setMaximumTrackImage(transImg, forState: UIControlState.Normal)
        self.setMaximumTrackImage(transImg, forState: UIControlState.Highlighted)
        
        self.setThumbImage( UIImage(named: "updown"), forState: UIControlState.Normal )
        self.setThumbImage( UIImage(named: "updown"), forState: UIControlState.Highlighted )

        
        self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        
    }


    
    
    

}