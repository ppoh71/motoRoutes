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
    var progressButton = ActionButton()
    var doneButton = ActionButton()
    var actionType = ActionButtonType()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, actionType: ActionButtonType, xOff: Bool) {
        self.init(frame: frame)
        self.actionType = actionType
        setupConfirm(actionType)
        
        if xOff { //set off screen by x
            self.frame.origin.x =  -frame.width
        }
    }
    
    func setupConfirm(_ actionType: ActionButtonType){
        label.frame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: actionLabelHeight*2+(actionLabelPadding/2))
        label.numberOfLines = 0
        label.backgroundColor = blue3
        label.font = UIFont(name: "Roboto", size: 14)
        label.textAlignment = .center
        label.textColor = textColor
        label.text = actionType.confirmText
        
        let backFill = UIView(frame: CGRect(x: -20, y: 0, width: 20, height: label.frame.height))
        backFill.backgroundColor = blue3
        
        okButton = ActionButton(actionType: actionType.confirmAction, buttonNumber: 2, xOff: false)
        progressButton = ActionButton(actionType: ActionButtonType.DefState, buttonNumber: 2, xOff: true)
        doneButton = ActionButton(actionType: ActionButtonType.Done, buttonNumber: 2, xOff: true)
        
        self.addSubview(backFill)
        self.addSubview(okButton)
        self.addSubview(progressButton)
        self.addSubview(doneButton)
        self.addSubview(label)
    }
    
    func setConfirmType(_ actionType: ActionButtonType){
        label.text = actionType.confirmText
        okButton.actionButton.actionType = actionType.confirmAction
        okButton.actionButton.setTitle("OK", for: .normal)
        doneButton.aniOffToLeft(0)
        okButton.frame.origin.x = 0
    }
    
    func progressOn(_ actionType: ActionButtonType){
        okButton.frame.origin.x = -okButton.frame.width
        progressButton.actionButton.setTitle(actionType.buttonText, for: .normal)
        progressButton.aniToX(0.1)
    }
    
    func progressDone(){
        progressButton.aniOffToLeft(0)
        doneButton.aniToX(0.1)
    }
}
