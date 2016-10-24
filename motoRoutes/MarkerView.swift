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
    var initFrame = CGRect(x: -10, y: -10, width: 145, height: 240)
    let offset = CGFloat(0)
    var durationValue = ""
    var highspeedValue = ""
    var altitudeValue = ""
    
    
    init(reuseIdentifier: String, color: UIColor, routeMaster: RouteMaster) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.durationValue = routeMaster.textDuration
        self.altitudeValue = routeMaster.textHighAlt
        self.highspeedValue = routeMaster.textHighSpeed
        
        scalesWithViewingDistance = true
        centerOffset = CGVector(dx: -initFrame.width/2 + offset, dy: -initFrame.height/2)

        //Mark: Info Label View Wrapper
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: initFrame.width, height: initFrame.height - 30))
        backView.backgroundColor = blue4
        backView.layer.opacity = 0.5
        self.addSubview(backView)
        
        let clipView = UIView(frame: CGRect(x: 10, y: 30, width: initFrame.width, height: initFrame.height - 30))
        clipView.clipsToBounds = true
        self.addSubview(clipView)
        
        //Mark: Info Labels
        let durationLabel = InfoTemplate(labelNumber: 0, labelType: LabelType.duration, value: durationValue, xOff: true)
        durationLabel.aniToX(0.8)
        clipView.addSubview(durationLabel)
        
        let altitudeLabel = InfoTemplate(labelNumber: 1, labelType: LabelType.altitude, value: altitudeValue, xOff: true)
        altitudeLabel.aniToX(1.0)
        clipView.addSubview(altitudeLabel)
        
        let speedLabel = InfoTemplate(labelNumber: 2, labelType: LabelType.speed, value: highspeedValue, xOff: true)
        speedLabel.aniToX(1.2)
        clipView.addSubview(speedLabel)
        
        //Mark: dot animation
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

