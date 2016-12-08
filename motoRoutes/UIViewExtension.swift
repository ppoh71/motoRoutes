//
//  UIViewExtension.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 02.12.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import pop

extension UIView {
    
    
    /**
     Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.
     
     - parameter duration: animation duration
     */
    func zoomIn(_ duration: TimeInterval = 0.5, delay:TimeInterval = 0.5) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseOut], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
        }
    }
    
    /**
     Zoom in any view with specified offset magnification.
     
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomInWithEasing(_ delay: TimeInterval = 1.0) {
        self.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.isHidden = false;
            let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            scale?.toValue =  NSValue(cgSize: CGSize(width: 4, height: 4))
            scale?.springBounciness = 15
            scale?.springSpeed = 15
            self.pop_add(scale, forKey: "scalePosition")
        })
    }
    
    func aniToX(_ delay: Double){
        let when = DispatchTime.now() + delay // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //print("animate point x\(self.frame.origin.y)")
            AnimationEngine.animationToPositionX(self, x: Double(self.frame.width/2))
        }
    }
    
    func aniToOff(_ delay: Double){
        let when = DispatchTime.now() + delay // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //print("animate point x\(self.frame.origin.y)")
            AnimationEngine.animationToPositionX(self, x: Double(self.frame.width*2))
        }
    }
    
    func aniOffToLeft(_ delay: Double){
        let when = DispatchTime.now() + delay // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //print("animate point x\(self.frame.origin.y)")
            AnimationEngine.animationToPositionX(self, x: -Double(self.frame.width*2))
        }
    }

    
    
}
