//
//  MarkerView.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 05.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import Mapbox


class MarkerView: MGLAnnotationView {
    
    let shapeLayer = CAShapeLayer()
    var dotCol = UIColor.blue
    var color = UIColor.clear
    var initFrame = CGRect(x: -10, y: -10, width: 140, height: 230)
    let offset = CGFloat(0)
    
    init(reuseIdentifier: String, color: UIColor, routeMaster: RouteMaster) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        scalesWithViewingDistance = true
        centerOffset = CGVector(dx: -initFrame.width/2 + offset, dy: -initFrame.height/2)
        //self.backgroundColor = blue1
        //self.layer.opacity = 0.5

//        let infoView = UIView(frame: CGRect(x: 52, y: 0, width: initFrame .width, height: initFrame.height-50))
//        infoView.backgroundColor = blue4
//        infoView.layer.cornerRadius = cornerInfoViews
//        self.addSubview(infoView)
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: initFrame.width, height: initFrame.height - 30))
        backView.backgroundColor = blue4
        backView.layer.opacity = 0.5
        self.addSubview(backView)
        
        let padding = 10
        let durationLabel = InfoTemplate(labelNumber: 0, labelType: LabelType.duration)
        durationLabel.frame.origin = CGPoint(x: padding, y: padding * 2)
        self.addSubview(durationLabel)
        
        let altitudeLabel = InfoTemplate(labelNumber: 1, labelType: LabelType.altitude)
        altitudeLabel.frame.origin = CGPoint(x: padding, y: Int(durationLabel.frame.origin.y + durationLabel.frame.height + CGFloat(padding)))
        self.addSubview(altitudeLabel)
        
        let speedLabel = InfoTemplate(labelNumber: 2, labelType: LabelType.speed)
         speedLabel.frame.origin = CGPoint(x: padding, y: Int(altitudeLabel.frame.origin.y + durationLabel.frame.height + CGFloat(padding)))
        self.addSubview(speedLabel)
        
        
        
        //AnimationEngine.hideViewAnim(infoView)
        //AnimationEngine.animationToPosition(infoView, position: CGPoint(x: -50, y:0) )
        
        
//        let label = UILabel()
//        label.frame = CGRect(x: 0, y: 0, width: initFrame .width, height: initFrame.height)
//        
//        label.numberOfLines = 0
//        //label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 10)
//       // label.font = label.font.withSize(10)
//        //label.textAlignment = .left
//        //label.lineBreakMode = .byWordWrapping
//        //label.textColor = UIColor.white
//        
//        let htmlString = "<p style=\"font-family:Roboto;color: white;font-size:10;\">Duration <br /><strong>\(Utils.clockFormat(routeMaster.routeTime)) </strong><br /><br />Highest Altitude<br /><strong> \(routeMaster.routeHighestAlt)</strong></p> "
//        label.attributedText = htmlString.attributedStringFromHtml

        

        
        let when = DispatchTime.now() + 0 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
           
            // infoView.addSubview(label)
          //  AnimationEngine.animationToPosition(infoView, position: CGPoint(x: 0, y: 0))
            
        }
        
        
        let dot = DotAnimation(frame: CGRect(x: initFrame.width, y: initFrame.height, width: 10, height: 10))
        self.addSubview(dot)
        dot.addDotAnimation()
    }
    
    // These two initializers are forced upon us by Swift.
    override init(frame: CGRect) {
        super.init(frame: initFrame)
        print("init markerview frame")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
           }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
    }
    
}

