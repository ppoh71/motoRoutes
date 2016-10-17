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
    var initFrame = CGRect(x: 0, y: 0, width: 200, height: 100)
    
    
    init(reuseIdentifier: String, color: UIColor) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        scalesWithViewingDistance = true
        self.color = color

        print("frame \(self.frame.width)")
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 100 , height: 21))
       // label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "I'am a test label"
        self.addSubview(label)
        
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: initFrame.width/2,y: initFrame.height/2), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.cyan.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1.0
        self.layer.addSublayer(shapeLayer)
        
        dotAnimation()
        
        
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
    
    
    func dotAnimation(){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.fromValue = 0
        animation.toValue = 10
        animation.duration = 0.7
        animation.autoreverses = true
        animation.repeatCount = 200000
        shapeLayer.add(animation, forKey: "cornerRadius")
    }
    
    
    func stopAnimation(){
        shapeLayer.removeAllAnimations()
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

