//
//  AnimationEngine.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 07.06.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import pop


class AnimationEngine {

    class var offScreenRightPosition: CGPoint{
        return CGPointMake(UIScreen.mainScreen().bounds.width, CGRectGetMidY(UIScreen.mainScreen().bounds))
    }

    class var offScreenLeftPosition: CGPoint{
        return CGPointMake(-UIScreen.mainScreen().bounds.width, CGRectGetMidY(UIScreen.mainScreen().bounds))
    }

    class var screenCenterPosition: CGPoint{
        return CGPointMake(CGRectGetMidX(UIScreen.mainScreen().bounds), CGRectGetMidY(UIScreen.mainScreen().bounds))
    }

    let ANIM_DELA:Int64 = 1
    var originalConstans = [CGFloat]()
    var constraints: [NSLayoutConstraint]!
    
    init(constraints: [NSLayoutConstraint]) {
    
        for con in constraints{
            originalConstans.append(con.constant)
            con.constant = AnimationEngine.offScreenRightPosition.x
        }
        
     self.constraints = constraints
    
    }
    
    
    
    func animateOnScreen(delay: Int ){
    
        //let d:Int64 = delay != nil ? Int64(Double(ANIM_DELA) * Double(NSEC_PER_SEC)) : delay!
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay) * Double(NSEC_PER_SEC)))
        
        dispatch_after(time, dispatch_get_main_queue()){
        
            var index = 0
            repeat{
                
                let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                moveAnim.toValue = self.originalConstans[index]
                moveAnim.springBounciness = 12
                moveAnim.springSpeed = 12
                
                let con = self.constraints[index]
                con.pop_addAnimation(moveAnim, forKey: "moveOnScreen")
                
                if(index==0){
                    moveAnim.dynamicsFriction += 10 + CGFloat(index)
                }
                
                index = index+1
                
            } while (index < self.constraints.count)
        }
    }
    
    class func animationToPosition(view: UIView, position: CGPoint) {
        
        let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
        moveAnim.toValue = NSValue(CGPoint: position)
        moveAnim.springBounciness = 8
        moveAnim.springSpeed = 8
        view.pop_addAnimation(moveAnim, forKey: "movePosition")
        
    }
    
        
 }
