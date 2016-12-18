//
//  ActionButton.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 25.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

protocol ActionButtonDelegate: class{
    func pressedActionButton(sender: UIButton)
}

class ActionButton: UIView{
    var initFrame = CGRect(x: 0, y: 0, width: actionLabelWidth, height: actionLabelHeight)
    var actionButton = UIButton()
    var actionType = ActionButtonType()
    let padding = actionLabelPadding
    var yPos: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: initFrame)
        self.backgroundColor = UIColor.black
    }
    
    convenience init(actionType: ActionButtonType, buttonNumber: Int, xOff: Bool) {
        self.init(frame: CGRect.zero)
        self.actionType = actionType
        self.frame.origin.y = initFrame.height * CGFloat(buttonNumber) + CGFloat(padding/2 * buttonNumber)
        
        if xOff { //set off screen by x
            self.frame.origin.x =  -initFrame.width
        }
        setupButton()
       }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupButton(){
        actionButton.frame = initFrame //assign view frame also to button
        actionButton.setTitle(actionType.buttonText, for: .normal)
        actionButton.titleLabel!.font = buttonFont
        actionButton.backgroundColor = blue3
        actionButton.actionType = actionType
        actionButton.isUserInteractionEnabled = true
        actionButton.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        self.addSubview(actionButton)
    }
    
    func pressedButton(_ sender: UIButton){
        let notifyObj = [sender.actionType]
        NotificationCenter.default.post(name: Notification.Name(rawValue: actionButtonNotificationKey), object: notifyObj)
    }
}
