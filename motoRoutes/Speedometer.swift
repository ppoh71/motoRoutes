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

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       // init view in setup
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    func setup(width: Int, height: Int){
    
        
        frameHeight = Double(height)
        
        speedoBackground.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        //define posiion in bounds, default will center it (x,y) in bounds rect
        speedoBackground.position = CGPoint(x: Double(width/2), y: Double(height/2))
        
        speedoBackground.backgroundColor = UIColor.lightGrayColor().CGColor
        self.layer.addSublayer(speedoBackground)
        
        speedBar.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        speedBar.position = CGPoint(x: Double(width/2), y: Double(height/2))
        speedBar.cornerRadius = 0
        speedBar.backgroundColor = UIColor.redColor().CGColor
        
        speedoBackground.addSublayer(speedBar)
        
        speedoBackground.masksToBounds = true
        
        
        speedLabel.text = "SXXLAB"
        speedLabel.frame = CGRectMake(0, 0, 100, 50)
        self.addSubview(speedLabel)
        

    }
    

    func moveSpeedo(speed:Double){
    
        //get speed percent to frameheight
        let maxSpeed = frameHeight
        let speedr = Double(random() % 200)
        let percentSpeed = speed*100/maxSpeed
        
        //get bar range and calc y position to move
        let speedoRange = (frameHeight/2*3) - (frameHeight/2)
        let yToMove = speedoRange - (percentSpeed*speedoRange/100)
        
        
        speedBar.backgroundColor = colorUtils.polylineColors(globalSpeedSet.speedSet).CGColor
        
        let move = CABasicAnimation(keyPath: "position.y")
        //move.byValue = speedBar.position.y -  CGFloat(globalSpeed.gSpeed)
      
        move.toValue =  (frameHeight/2) + yToMove
        
        
        print("random move \(speed) - \(percentSpeed) - \(yToMove)")

        move.duration = 0.1
        move.autoreverses = false
        move.fillMode = kCAFillModeForwards;
        move.removedOnCompletion = false
        //move.repeatCount = Float.infinity
        
        speedBar.addAnimation(move, forKey: nil)
        
        speedLabel.text = " \(Int(speed))"
        speedLabel.textColor = colorUtils.polylineColors(globalSpeedSet.speedSet)
        speedLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 30.0)
        
        
        UIView.animateWithDuration(0.1, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
            
            self.speedLabel.center = CGPoint(x: 55, y: yToMove )  // Ending position of the Label
            
            }, completion: nil)


        
        
        
    }


}
