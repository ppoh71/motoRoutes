//
//  InfoTemplate.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 21.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


class InfoTemplate: UIView {
    
    var initFrame = CGRect(x: 0, y: 0, width: 125, height: 48)
    let labelWidth = 100
    let labelHeight = 20
    let padding = 12
    let labelLeftPos = 50
    var labelNumber = 0
    var offset = 6
    var iconImage = LabelType.duration.image
    var labelText = LabelType.duration.label
    var labelValue = ""
    
    override init(frame: CGRect) {
        super.init(frame: initFrame)
        //print("init markerview frame")
    }
    
    convenience init(labelNumber: Int, labelType: LabelType, value: String, xOff: Bool) {
        self.init(frame: CGRect.zero)
        self.labelNumber = offset
        self.iconImage = labelType.image
        self.labelText = labelType.label
        self.labelValue = value
        
        //set y-position by amout of views
        self.frame.origin.y =  initFrame.height * CGFloat(labelNumber) + CGFloat(padding * labelNumber)
        
        if(xOff == true){ //set off screen by x
            self.frame.origin.x =  -initFrame.width
        }
        
        setupLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupLabels() {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: initFrame.width, height: initFrame.height))
        backView.backgroundColor = blue3
        backView.layer.opacity = 0.5
        self.addSubview(backView)

        let iconView = UIImageView(frame: CGRect(x: padding, y: padding, width: 24, height: 24))
        iconView.image = iconImage
        self.addSubview(iconView)
        
        let label = UILabel()
        label.frame = CGRect(x: labelLeftPos, y: padding/2, width: labelWidth, height: labelHeight)
        label.numberOfLines = 1
        label.font = UIFont(name: "Roboto", size: 8)
        label.textAlignment = .left
        label.textColor = textColor
        label.text = labelText
        self.addSubview(label)
        
        let info = UILabel()
        info.frame = CGRect(x: labelLeftPos, y: padding/2*3, width: labelWidth, height: labelHeight)
        info.numberOfLines = 1
        info.font = UIFont(name: "Roboto-Bold", size: 14)
        info.textAlignment = .left
        info.textColor = textColor
        info.text = labelValue
        self.addSubview(info)
    }
    
    func aniToX(_ delay: Double){
        
        let when = DispatchTime.now() + delay // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //print("animate point x\(self.frame.origin.y)")
            AnimationEngine.animationToPositionX(self, x: Double(self.frame.width/2))
        }
    }
    
}
