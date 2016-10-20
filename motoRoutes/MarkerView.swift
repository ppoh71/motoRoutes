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
    var initFrame = CGRect(x: 0, y: 0, width: 90, height: 145.62)
    let offset = CGFloat(0)
    
    init(reuseIdentifier: String, color: UIColor, routeMaster: RouteMaster) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        scalesWithViewingDistance = true
        centerOffset = CGVector(dx: -initFrame.width/2 + offset, dy: -initFrame.height/2)
        self.color = UIColor.clear

        let infoView = UIView(frame: CGRect(x: 0, y: 0, width: initFrame .width, height: initFrame.height-50))
        infoView.backgroundColor = blue0
        infoView.layer.cornerRadius = cornerInfoViews
        AnimationEngine.hideViewAnim(infoView)
        AnimationEngine.animationToPosition(infoView, position: CGPoint(x: -50, y:0) )
        
        
        let label = UILabel()
        label.textAlignment = .center
        label.frame = CGRect(x: 10, y: 0, width: initFrame .width, height: initFrame.height/2)
        label.text = "\(Utils.clockFormat(routeMaster.routeTime)) h:m:s \n\n \nDura:01:12:34\nSpd:235km/h"
        label.numberOfLines = 0
        label.font = label.font.withSize(10)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = blue1
       
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.addSubview(infoView)
             infoView.addSubview(label)
            AnimationEngine.animationToPosition(infoView, position: CGPoint(x: 0, y: 0))
            
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
    
    /*
    func dotAnimation(){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.fromValue = 0
        animation.toValue = 10
        animation.duration = 0.7
        animation.autoreverses = true
        animation.repeatCount = 200000
        shapeLayer.add(animation, forKey: "cornerRadius")
    }
     */
    

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
    }
    
}

