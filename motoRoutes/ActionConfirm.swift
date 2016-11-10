//
//  ActionMenu.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 25.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

class ActionConfirm: UIView{
    let label = UILabel()
    var okButton = ActionButton()
    var actionType = ActionButtonType()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // print("init markerview frame")
        setupConfirm(actionType)
    }
    
    convenience init(frame: CGRect, actionType: ActionButtonType) {
        self.init(frame: frame)
        self.backgroundColor = blue2
        self.actionType = actionType
        setupConfirm(actionType)
    }
    
    func setupConfirm(_ actionType: ActionButtonType){
        label.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2)
        label.numberOfLines = 0
        label.font = UIFont(name: "Roboto", size: 8)
        label.textAlignment = .center
        label.textColor = textColor
        label.text = actionType.confirmText
        self.addSubview(label)
        
        okButton = ActionButton(initFrame: CGRect(x: 10, y: self.frame.height - 40, width: 40, height: 30), buttonType: actionType.confirmAction)
        self.addSubview(okButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

