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

class ActionButton: UIView, MarkerViewItems {
    weak var delegate: ActionButtonDelegate?
    var initFrame = CGRect(x: 0, y: 0, width: actionLabelWidth, height: actionLabelHeight)
    var actionButton = UIButton()
    var buttonType = ActionButtonType()
    let padding = actionLabelPadding
    var yPos: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: initFrame)
        //print("init action button")
        //setupButton()
    }
    
    convenience init(buttonType: ActionButtonType, buttonNumber: Int, xOff: Bool) {
        self.init(frame: CGRect.zero)
        self.buttonType = buttonType
        self.backgroundColor = UIColor.brown
        self.frame.origin.y = initFrame.height * CGFloat(buttonNumber) + CGFloat(padding * buttonNumber)
        
        if(xOff == true){ //set off screen by x
            self.frame.origin.x =  -initFrame.width
        }
        
        setupButton()
       }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupButton(){
        actionButton.frame = initFrame //assign view frame also to button
        actionButton.setTitle(buttonType.buttonText, for: .normal)
        actionButton.backgroundColor = green1
        actionButton.actionType = buttonType
        actionButton.isUserInteractionEnabled = true
        actionButton.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        self.addSubview(actionButton)
    }
    

    
    func pressedButton(_ sender: UIButton){
        let notifyObj = [sender.actionType]
        NotificationCenter.default.post(name: Notification.Name(rawValue: actionButtonNotificationKey), object: notifyObj)
    }
}
