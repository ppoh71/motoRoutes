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

    var innerColor = UIColor.white
    var outterColor = UIColor.white
    var aniColor = blue3
    
    //init frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.yellow
    }
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        aniColor = color
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
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: CGFloat(2), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let circlePathOuter = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: CGFloat(4), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let shapeLayerOuter = CAShapeLayer()
        shapeLayerOuter.path = circlePathOuter.cgPath
        shapeLayerOuter.strokeColor = UIColor.white.cgColor
        shapeLayerOuter.fillColor = UIColor.clear.cgColor
        shapeLayerOuter.lineWidth = 1
        shapeLayerOuter.opacity = 1
        
        let shapeLayerInner = CAShapeLayer()
        shapeLayerInner.path = circlePath.cgPath
        shapeLayerInner.fillColor = innerColor.cgColor
        shapeLayerInner.strokeColor = UIColor.white.cgColor
        shapeLayerInner.lineWidth = 1.0
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = aniColor.cgColor
        shapeLayer.strokeColor = aniColor.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.opacity = 0.8

        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(shapeLayerOuter)
        self.layer.addSublayer(shapeLayerInner)

        
        let animationOuter = CABasicAnimation(keyPath: "opacity")
        animationOuter.fromValue = 0.9
        animationOuter.toValue = 0.0
        animationOuter.duration = 0.5
        animationOuter.autoreverses = true
        animationOuter.repeatCount = 200000
        
        let animationLineWidth = CABasicAnimation(keyPath: "transform.scale")
        animationLineWidth.fromValue = 1
        animationLineWidth.toValue = 5
        animationLineWidth.duration = 1
        animationLineWidth.autoreverses = true
        animationLineWidth.repeatCount = 200000
        // Finally, add the animation to the layer
        
        //shapeLayer.add(animation, forKey: "lineWidth")
        shapeLayer.add(animationLineWidth, forKey: "line width")
        shapeLayerInner.add(animationOuter, forKey: "opacity outter")

    }
}
