//
//  AnimationEngine.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 07.06.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import pop


final class AnimationEngine {

    //MARK; Static Screen Position Vars
    class var offScreenRightPosition: CGPoint{
        return CGPoint(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.midY)
    }

    class var offScreenLeftPosition: CGPoint{
        return CGPoint(x: -UIScreen.main.bounds.width, y: UIScreen.main.bounds.midY)
    }

    class var screenCenterPosition: CGPoint{
        return CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    }
    
    class var screenBottomCenterPosition: CGPoint{
        return CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.height)
    }
    
    class var screenBottomPosition: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.height)
    }
    
    
    init(){
    
    }
    
    
    //MARK: Animation to Point
    class func animationToPosition(_ view: UIView, position: CGPoint) {
        
        let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
        moveAnim?.toValue = NSValue(cgPoint: position)
        moveAnim?.springBounciness = 8
        moveAnim?.springSpeed = 8
        view.pop_add(moveAnim, forKey: "movePosition")
    }

    
    
    //MARK: Animation functions
    
    class func showViewAnimCenterPosition(_ viewObejct: UIView){
        AnimationEngine.animationToPosition(viewObejct, position: AnimationEngine.screenCenterPosition)
    }
    
    class func hideViewAnim(_ viewObject: UIView){
        AnimationEngine.animationToPosition(viewObject, position: AnimationEngine.offScreenLeftPosition)
    }
    
    class func hideViewBottomLeft(_ viewObject: UIView){
        let offScreenLeftBottom = CGPoint(x: -UIScreen.main.bounds.width, y: UIScreen.main.bounds.height - (viewObject.frame.height/2))
        AnimationEngine.animationToPosition(viewObject, position: offScreenLeftBottom)
    }
    
    class func showViewAnimCenterBottomPosition(_ viewObject: UIView){
        let position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.height - (viewObject.frame.height/2))
        AnimationEngine.animationToPosition(viewObject, position: position)
    }
    
    class func showViewAnimCenterTopPosition(_ viewObject: UIView){
        let position = CGPoint(x: UIScreen.main.bounds.midX, y: 0)
        AnimationEngine.animationToPosition(viewObject, position: position)
    }
    
    
    
    
    
    /*
     
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
     }    */
 }
