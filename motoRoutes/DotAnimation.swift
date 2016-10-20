//
//  DotAnimation.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 19.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit

class DotAnimation: UIView {
//http://stackoverflow.com/questions/35496962/override-init-method-of-uiview-in-swift

    var innerColor = blue1
    var outterColor = blue2
    var aniColor = blue3
    
    
    //init frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.yellow
    }
    
    //init coder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        //super.layoutSubviews()
    }
 
    
    func addDotAnimation() {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: CGFloat(5), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let circlePathOuter = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        
        let shapeLayerOuter = CAShapeLayer()
        shapeLayerOuter.path = circlePathOuter.cgPath
        shapeLayerOuter.strokeColor = aniColor.cgColor
        shapeLayerOuter.fillColor = UIColor.clear.cgColor
        shapeLayerOuter.lineWidth = 1
        shapeLayerOuter.opacity = 1
        
        let shapeLayerInner = CAShapeLayer()
        shapeLayerInner.path = circlePath.cgPath
        shapeLayerInner.fillColor = red2.cgColor
        shapeLayerInner.strokeColor = red2.cgColor
        shapeLayerInner.lineWidth = 1.0
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = red3.cgColor
        shapeLayer.strokeColor = green3.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.opacity = 0.7

        
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(shapeLayerOuter)
        self.layer.addSublayer(shapeLayerInner)
        
        let animationOuter = CABasicAnimation(keyPath: "opacity")
        animationOuter.fromValue = 0.2
        animationOuter.toValue = 0.8
        animationOuter.duration = 0.7
        animationOuter.autoreverses = true
        animationOuter.repeatCount = 200000
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.7
        animation.toValue = 0.3
        animation.duration = 0.7
        animation.autoreverses = true
        animation.repeatCount = 200000
        
        let animationLineWidth = CABasicAnimation(keyPath: "lineWidth")
        animationLineWidth.fromValue = 0
        animationLineWidth.toValue = 28
        animationLineWidth.duration = 0.9
        animationLineWidth.autoreverses = true
        animationLineWidth.repeatCount = 200000
        // Finally, add the animation to the layer
        
        shapeLayer.add(animation, forKey: "lineWidth")
        shapeLayer.add(animationLineWidth, forKey: "opacity")
        shapeLayerInner.add(animationOuter, forKey: "inneropacity")
        shapeLayerOuter.add(animationOuter, forKey: "outeropacits")
        
    }

    
    
}
