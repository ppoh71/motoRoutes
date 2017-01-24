//
//  MotoMenuInit.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 24.01.17.
//  Copyright © 2017 Peter Pohlmann. All rights reserved.
//

import UIKit

class MotoMenuInit: UIView{
    var menuButtonOn = UIButton()
    var menuButtonOff = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.black
        setupMenuButton()
        setupMenuButtons()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMenuButton(){
        let buttonSize = CGPoint(x: 10, y: 10)
        menuButtonOn.frame = CGRect(x: self.frame.width-40, y: 10 , width: buttonSize.x, height: buttonSize.y)
        menuButtonOn.setImage(MenuButtonType.MenuOff.buttonImage, for: .normal)
        menuButtonOn.menuType = MenuButtonType.MenuOff
        menuButtonOn.addTarget(self, action: #selector(pressedMenuButton), for: .touchUpInside)
        menuButtonOn.clipsToBounds = true
        menuButtonOn.scale(4)
        self.addSubview(menuButtonOn)
        
        menuButtonOff.frame = CGRect(x: self.frame.width-40, y: 10 , width: buttonSize.x, height: buttonSize.y)
        menuButtonOff.setImage(MenuButtonType.MenuOn.buttonImage, for: .normal)
        menuButtonOff.menuType = MenuButtonType.MenuOn
        menuButtonOff.addTarget(self, action: #selector(pressedMenuButton), for: .touchUpInside)
        menuButtonOff.clipsToBounds = true
        menuButtonOff.scale(0)
        self.addSubview(menuButtonOff)
    }
    
    func setupMenuButtons(){
        
    }
    
    func menuOn(){
        print("menu on")
    }
    
    func menuOff(){
        print("menu off")
    }
    
    func pressedMenuButton(sender: UIButton){
        var menuButtonType = MenuActionType.MenuOn
        if(sender.menuType == MenuButtonType.MenuOff){
            print("menu is off, make on")
            menuButtonOn.scale(0)
            menuButtonOff.scale(4)
            menuOn()
            menuButtonType = .MenuOn

        }else{
            menuButtonOn.scale(4)
            menuButtonOff.scale(0)
            menuOff()
            menuButtonType = .MenuOff
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: motoMenuNotificationKey), object: [menuButtonType])

    }
    
}
