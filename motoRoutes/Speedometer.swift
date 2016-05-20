//
//  Speedometer.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


class Speedometer: UIView {

    let speedBar = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let r = CAReplicatorLayer()
        r.bounds = CGRect(x: 0, y: 0, width: 40.0, height: 200.0)
        r.position = CGPoint(x: 0.0, y: 0)
        
        r.backgroundColor = UIColor.lightGrayColor().CGColor
        self.layer.addSublayer(r)
        
       
        speedBar.bounds = CGRect(x: 0, y: 0, width: 40.0, height: 200.0)
        speedBar.position = CGPoint(x: 20.0, y: 200.0)
        speedBar.cornerRadius = 0
        speedBar.backgroundColor = UIColor.redColor().CGColor
        
        r.addSublayer(speedBar)
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func moveSpeedo(speed:Double){
    
        speedBar.backgroundColor = colorUtils.polylineColors(utils.getSpeedIndex(speed)).CGColor
        
        let move = CABasicAnimation(keyPath: "position.y")
        //move.byValue = speedBar.position.y -  CGFloat(globalSpeed.gSpeed)
        move.toValue = CGFloat(speed) * -2 
        
      
        
        print("move.toValue \(move.toValue)")
        move.duration = 0.1
        move.autoreverses = false
        move.fillMode = kCAFillModeForwards;
        move.removedOnCompletion = false
        //move.repeatCount = Float.infinity
        
        speedBar.addAnimation(move, forKey: nil)
        
    
    }


}
