//
//  buttonSytles.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 23/01/16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

class buttonSytles: UIButton {

    //init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 15.0;
        //self.layer.shadowColor = UIColor.blackColor().CGColor
        //self.layer.shadowOffset = CGSizeMake(5, 5)
        //self.layer.shadowRadius = 5
        //self.layer.shadowOpacity = 0.6
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
        self.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        //let image = UIImage(named: "button_back_white.png")
        //setBackgroundImage(image, forState: .Normal)
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    
    }
    */

}
