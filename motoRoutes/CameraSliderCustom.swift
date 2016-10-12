//
//  Speedometer.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 20.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


class CameraSliderCustom: UIControl {
    
    let CameraSliderBackground = CAReplicatorLayer()
    let SliderBarBackground = CALayer()
    let SliderBar = CALayer()
    let SlideThumb = CALayer()
    let thumbSize = 40
    var frameHeight = 0.0
    var touchDownLocation = CGPoint()
    var currentValue = 0.0
    
    //init frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("Frame")
        print(frame)
        // init view in setup
        
    }
    
    //init coder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //the actual setup, width&height for slider bar, frameWidth incl. image, for touch tracking
    func setup(_ width: Int, height: Int, frameWidth: Int){
        
        //the init frameheight, will be used be the slide
        frameHeight = Double(height)
        
        //set layers for background and slide bar
        CameraSliderBackground.bounds = CGRect(x: 0, y: 0, width: frameWidth, height: height)
        
        //define posiion in bounds, default will center it (x,y) in bounds rect
        CameraSliderBackground.position = CGPoint(x: Double(frameWidth/2), y: Double(height/2))
        
        //CameraSliderBackground.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7).CGColor
        self.layer.addSublayer(CameraSliderBackground)
        
        
        //Define Sliderbackground
        SliderBarBackground.bounds = CGRect(x: Int(frameWidth/2), y: 0, width: width, height: height)
        SliderBarBackground.position = CGPoint(x: Double(frameWidth-(width/2)), y: Double(height/2))
        SliderBarBackground.cornerRadius = 0
        SliderBarBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        //add to layer
        CameraSliderBackground.addSublayer(SliderBarBackground)
        
        //Define sliderbat
        SliderBar.bounds = CGRect(x: Int(frameWidth/2), y: 0, width: width, height: height)
        SliderBar.position = CGPoint(x: Double(frameWidth-(width/2)), y: Double(height/2))
        SliderBar.cornerRadius = 0
        SliderBar.backgroundColor = UIColor.green.withAlphaComponent(0.3).cgColor
        
        //add speedbat to layer
        CameraSliderBackground.addSublayer(SliderBar)
        
        //mask speedbar with background
        CameraSliderBackground.masksToBounds = true
        
        //create slide thumb
        SlideThumb.bounds = CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize)
        SlideThumb.position = CGPoint(x: thumbSize/2, y: thumbSize/2)
        //SlideThumb.backgroundColor = UIColor.cyanColor().CGColor
        SlideThumb.contents = UIImage(named: "zoom")?.cgImage
        CameraSliderBackground.addSublayer(SlideThumb)
        
        //set init value
        slideAnimation(CGFloat(123))
        
    }
    
   

    //slide thumb and bar
    func slideAnimation(_ y: CGFloat){
    
        print(frameHeight)
        
        if (Int(y) > thumbSize/2 && Int(y) < Int(frameHeight) - Int(thumbSize/2)){
            SlideThumb.position = CGPoint(x: SlideThumb.position.x , y:y)
            SliderBar.position = CGPoint(x: SliderBar.position.x , y: (CGFloat(frameHeight/2)) + SlideThumb.position.y - CGFloat(thumbSize/2))
        }
        
        
        //calc position in % to set value of slider
        let maxValue = frameHeight //maxValue is relevant to height of initialized UIView: maxValue = frameheight
        currentValue = 100 - (Double(y)*100/maxValue)
        
        print("percent \( currentValue)")
        
    }
    
    //trtack touch beginn
    override func  beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        //trigger actual touch down position
        touchDownLocation = touch.location(in: self)
       
        //if touch down position is on slider image return true
        if(SlideThumb.frame.contains(touchDownLocation)){
            print(touchDownLocation)
             return true
        } else{
            print("nope")
             return false
        }
        
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        print(location.y)
        
        //transact direkt without animation delay
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
         slideAnimation(location.y)
        
        CATransaction.commit()
    
        //add target action sender
        sendActions(for: .valueChanged)

        return true
    }

    
}
