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
        moveAnim?.springBounciness = 6
        moveAnim?.springSpeed = 8
        view.pop_add(moveAnim, forKey: "movePosition")
    }
    
    class func animationToPositionX(_ view: UIView, x: Double) {
        
        let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        moveAnim?.toValue = x
        moveAnim?.springBounciness = 6
        moveAnim?.springSpeed = 15
        view.pop_add(moveAnim, forKey: "movePosition")
    }
    
    class func animationToPositionY(_ view: UIView, y: Double) {
        
        let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        moveAnim?.toValue = y
        moveAnim?.springBounciness = 6
        moveAnim?.springSpeed = 15
        view.pop_add(moveAnim, forKey: "movePosition")
    }
    class func animationToPositionImageView(_ view: UIImageView, position: CGPoint) {
        
        let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
        moveAnim?.toValue = NSValue(cgPoint: position)
        moveAnim?.springBounciness = 6
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
    
 }
