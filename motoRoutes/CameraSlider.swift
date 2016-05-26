//
//  CameraSlider.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 12.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


public class CameraSlider: UISlider{

    //init
    required public init(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)!
    
        //set trans image for track for alpha
        let transImg = imageUtils.drawSliderThumb(1, height: 1, lineWidth: 1, color: UIColor.blackColor(), alpha: 0)
        
        //set new images for controlls
        self.setMinimumTrackImage(transImg, forState: UIControlState.Normal)
        self.setMinimumTrackImage(transImg, forState: UIControlState.Highlighted)
        self.setMaximumTrackImage(transImg, forState: UIControlState.Normal)
        self.setMaximumTrackImage(transImg, forState: UIControlState.Highlighted)
        
      //  self.setThumbImage( UIImage(named: "updown"), forState: UIControlState.Normal )
      //  self.setThumbImage( UIImage(named: "updown"), forState: UIControlState.Highlighted )

        //rotate slider to vertical position
        self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
    }
}