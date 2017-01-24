//
//  ActionButton.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 22.01.2017.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

class MenuButton: UIView{
    //var initFrame = CGRect(x: 0, y: 0, width: menuButtonWidth, height: menuButtonHeight)
    var menuButton = UIButton()
    var menuType = MenuButtonType()
    let padding = menuLabelPadding
    var yPos: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, menuType: MenuButtonType, buttonNumber: Int, xOff: Bool, offset: Int) {
        self.init(frame: frame)
        print("buttonclass frame \(frame)")
        self.menuType = menuType
        self.frame.origin.y = frame.height * CGFloat(buttonNumber) + CGFloat(padding/2 * buttonNumber)
        self.backgroundColor = UIColor.cyan
        
        if xOff { //set off screen by x
           self.frame.origin.x =  CGFloat(offset)
        }
        setupButton(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton(_ frame: CGRect){
        print("button frame \(frame)")
        menuButton.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height) //assign view frame also to button
        menuButton.setTitle(menuType.buttonText, for: .normal)
        menuButton.setTitleColor(blue4, for: .normal)
        menuButton.titleLabel!.font = menuFont
        menuButton.backgroundColor = UIColor.white
        menuButton.menuType = menuType
        menuButton.isUserInteractionEnabled = true
        menuButton.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        self.addSubview(menuButton)
    }
    
    func pressedButton(_ sender: UIButton){
        let notifyObj = [sender.menuType]
        NotificationCenter.default.post(name: Notification.Name(rawValue: motoMenuActionNotificationKey), object: notifyObj)
    }
}
