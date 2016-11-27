//
//  ActionMenu.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 25.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

class ActionConfirm: UIView, MarkerViewItems{
    let label = UILabel()
    var okButton = ActionButton()
    var actionType = ActionButtonType()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // print("init markerview frame")
       // setupConfirm(actionType)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, actionType: ActionButtonType, xOff: Bool) {
        self.init(frame: frame)
        self.backgroundColor = blue2
        self.actionType = actionType
        setupConfirm(actionType)
        
        if(xOff == true){ //set off screen by x
            self.frame.origin.x =  -frame.width
        }
    }
    
    func setupConfirm(_ actionType: ActionButtonType){
        label.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2)
        label.numberOfLines = 0
        label.font = UIFont(name: "Roboto", size: 8)
        label.textAlignment = .center
        label.textColor = textColor
        label.text = actionType.confirmText
        self.addSubview(label)
        
        okButton = ActionButton(buttonType: actionType.confirmAction, buttonNumber: 2, xOff: false)
        self.addSubview(okButton)
    }
    
    func aniToX(_ delay: Double){
        let when = DispatchTime.now() + delay // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //print("animate point x\(self.frame.origin.y)")
            AnimationEngine.animationToPositionX(self, x: Double(self.frame.width/2))
        }
    }
    
    func aniToOff(_ delay: Double){
        let when = DispatchTime.now() + delay // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //print("animate point x\(self.frame.origin.y)")
            AnimationEngine.animationToPositionX(self, x: Double(self.frame.width*2))
        }
    }
    
    func aniOffToLeft(_ delay: Double){
        let when = DispatchTime.now() + delay // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //print("animate point x\(self.frame.origin.y)")
            AnimationEngine.animationToPositionX(self, x: -Double(self.frame.width*2))
        }
    }
}

