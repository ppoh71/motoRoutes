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


class ActionButton: UIView {

    weak var delegate: ActionButtonDelegate?
    var actionButton = UIButton()
    var buttonType = ActionButtonType()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init action button")
        setupButton()
    }
    
    
    convenience init(initFrame: CGRect, buttonType: ActionButtonType) {
        self.init(frame: initFrame)
        
        self.buttonType = buttonType
        actionButton.frame = CGRect(x: 0, y: 0, width: initFrame.width, height: initFrame.height)
        setupButton()
       }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setupButton(){
        
        actionButton.setTitle(buttonType.buttonText, for: .normal)
        actionButton.backgroundColor = green1
        actionButton.actionType = buttonType
        actionButton.isUserInteractionEnabled = true
        actionButton.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        self.addSubview(actionButton)
    }
    
    func pressedButton(_ sender: UIButton){
        print("pressed ActionButton \(sender.actionType)")
        
        let notifyObj = [sender.actionType]
        NotificationCenter.default.post(name: Notification.Name(rawValue: actionButtonNotificationKey), object: notifyObj)
        
//        if(delegate != nil){
//            print("pressed action button")
//            delegate?.pressedActionButton(sender: sender)
//        }
    }
    
}
