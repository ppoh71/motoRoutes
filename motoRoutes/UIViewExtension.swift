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

    func scaleSize(_ delay: TimeInterval = 1.0, size: Int ) {
        self.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.isHidden = false;
            let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            scale?.toValue =  NSValue(cgSize: CGSize(width: size, height: size))
            scale?.springBounciness = 15
            scale?.springSpeed = 15
            self.pop_add(scale, forKey: "scalePosition")
        })
    }
    
    func scale(_ size: Int ) {
            let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            scale?.toValue =  NSValue(cgSize: CGSize(width: size, height: size))
            scale?.springBounciness = 8
            scale?.springSpeed = 15
            self.pop_add(scale, forKey: "scalePosition")
    }
    
    func aniToX(_ delay: Double){
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            AnimationEngine.animationToPositionX(self, x: Double(self.frame.width/2))
        }
    }
    
    func aniToOff(_ delay: Double){
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            AnimationEngine.animationToPositionX(self, x: Double(self.frame.width/2*3))
        }
    }
    
    func aniOffToLeft(_ delay: Double){
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            AnimationEngine.animationToPositionX(self, x: -Double(self.frame.width/2))
        }
    }
    
    func aniToY(_ delay: Double, y: Double){
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            AnimationEngine.animationToPositionY(self, y: Double(self.frame.origin.y) + y)
            print(Double(self.frame.origin.y) + y)
        }
    }
}
