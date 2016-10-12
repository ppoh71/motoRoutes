//
//  Speedometer.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


class Speedometer: UIView {

    let speedoBackground = CAReplicatorLayer()
    let speedBar = CALayer()
    let speedLabel = UILabel()
    var frameHeight = 0.0

    //init frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       // init view in setup
        
    }
    
    //init coder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //the actual setup for the speedometer
    func setup(_ width: Int, height: Int){
    
        //the init frameheight, will be used be the animation
        frameHeight = Double(height)
        
        //set layers for background and speedo bar
        speedoBackground.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        //define posiion in bounds, default will center it (x,y) in bounds rect
        speedoBackground.position = CGPoint(x: Double(width/2), y: Double(height/2))
        
        speedoBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.layer.addSublayer(speedoBackground)
        
        speedBar.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        speedBar.position = CGPoint(x: Double(width/2), y: Double(height/2))
        speedBar.cornerRadius = 0
        speedBar.backgroundColor = UIColor.red.cgColor
        
        //add speedbat to layer
        speedoBackground.addSublayer(speedBar)
        
        //mask speedbar with background
        speedoBackground.masksToBounds = true
        
        //add TextLabel
        speedLabel.text = " - "
        
        speedLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.addSubview(speedLabel)
        
    }
    
    //animate the speedbar by given speed
    func moveSpeedo(_ speed:Double){
    
        //get speed percent to frameheight
        let maxSpeed = frameHeight //speed is relevant to height of initialized UIView: maxspeed = frameheight
        let percentSpeed = speed*100/maxSpeed
        
        //get bar range and calc y position to move
        let speedoRange = (frameHeight/2*3) - (frameHeight/2)
        let yToMove = speedoRange - (percentSpeed*speedoRange/100)
        
        //set sppedcolr to speedbar
        speedBar.backgroundColor = colorUtils.polylineColors(globalSpeedSet.speedSet).cgColor
        
        //create bar animation
        let move = CABasicAnimation(keyPath: "position.y")
        //move.byValue = speedBar.position.y -  CGFloat(globalSpeed.gSpeed)
      
        //calc move value
        move.toValue =  (frameHeight/2) + yToMove
        move.duration = 0.1
        move.autoreverses = false
        move.fillMode = kCAFillModeForwards;
        move.isRemovedOnCompletion = false
        //move.repeatCount = Float.infinity
        //print("random move \(speed) - \(percentSpeed) - \(yToMove)")
        //add animation
        speedBar.add(move, forKey: nil)
        
        //set speed text, colr and animate it
        speedLabel.text = " \(Int(speed))"
        speedLabel.textColor = colorUtils.polylineColors(globalSpeedSet.speedSet)
        speedLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 30.0)
        
        //aninate uilabel
        UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            
            self.speedLabel.center = CGPoint(x: -20, y: yToMove )  // Ending position of the Label
            
            }, completion: nil)
    }

}
