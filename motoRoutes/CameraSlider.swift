//
//  CameraSlider.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 12.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


open class CameraSlider: UISlider{

    //init
    required public init(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)!
    
        //set trans image for track for alpha
        let transImg = ImageUtils.drawSliderThumb(1, height: 1, lineWidth: 1, color: UIColor.black, alpha: 0)
        
        //set new images for controlls
        self.setMinimumTrackImage(transImg, for: UIControlState())
        self.setMinimumTrackImage(transImg, for: UIControlState.highlighted)
        self.setMaximumTrackImage(transImg, for: UIControlState())
        self.setMaximumTrackImage(transImg, for: UIControlState.highlighted)
        
      //  self.setThumbImage( UIImage(named: "updown"), forState: UIControlState.Normal )
      //  self.setThumbImage( UIImage(named: "updown"), forState: UIControlState.Highlighted )

        //rotate slider to vertical position
        self.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
    }
}
