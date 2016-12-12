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
        label.frame = CGRect(x: 10, y: 20, width: self.frame.width-20, height: self.frame.height/2)
        label.numberOfLines = 0
        label.font = UIFont(name: "Roboto", size: 14)
        label.textAlignment = .center
        label.textColor = textColor
        label.text = actionType.confirmText
        self.addSubview(label)
        
        okButton = ActionButton(buttonType: actionType.confirmAction, buttonNumber: 2, xOff: false)
        self.addSubview(okButton)
    }
   }

