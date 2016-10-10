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
    var dotCol = UIColor.blueColor()
    
    
    init(reuseIdentifier: String, color: UIColor) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = true
        
        // Use CALayer’s corner radius to turn this view into a circle.
//        layer.cornerRadius = frame.width / 2
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.whiteColor().CGColor
        
        //add dot         l
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 5,y: 5), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        shapeLayer.path = circlePath.CGPath
        shapeLayer.fillColor = UIColor.blueColor().CGColor
        shapeLayer.strokeColor = color.CGColor
        shapeLayer.lineWidth = 1.0
        self.layer.addSublayer(shapeLayer)
        
        //dotAnimation()

    }
    
    // These two initializers are forced upon us by Swift.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

        
           }
    
    
    func dotAnimation(){
        
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.fromValue = 0
        animation.toValue = 10
        animation.duration = 0.7
        animation.autoreverses = true
        animation.repeatCount = 200000
        shapeLayer.addAnimation(animation, forKey: "cornerRadius")
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.addAnimation(animation, forKey: "borderWidth")
    }
    
}

