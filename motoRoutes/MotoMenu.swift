//
//  MotoMenu.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 22.01.17.
//  Copyright © 2017 Peter Pohlmann. All rights reserved.
//

import UIKit

class MotoMenu: UIView {
    var menuButtonOn = UIButton()
    var menuButtonOff = UIButton()
    var menuButtonArr = [MenuButton]()
    var initFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var onFrame = CGRect(x: 0, y: 0, width: 130, height: 300)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.black
        setupMenuButton()
        setupMenuButtons()
        initFrame = frame
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
    
    func pressedMenuButton(sender: UIButton){
        if(sender.menuType == MenuButtonType.MenuOff){
            print("menu is off, make on")
            menuButtonOn.scale(0)
            menuButtonOff.scale(4)
            menuOn()
        }else{
            menuButtonOn.scale(4)
            menuButtonOff.scale(0)
            menuOff()
        }
    }

    func setupMenuButtons(){
        let myRoutesButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuMyRoutes.buttonWidth, height: MenuButtonType.MenuMyRoutes.buttonHeight), menuType: MenuButtonType.MenuMyRoutes, buttonNumber: 1, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(myRoutesButton)
        self.addSubview(myRoutesButton)
        
        let cloudButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuCloud.buttonWidth, height: MenuButtonType.MenuCloud.buttonHeight), menuType: MenuButtonType.MenuCloud, buttonNumber: 2, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(cloudButton)
        self.addSubview(cloudButton)
        
        let settingsButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuSettings.buttonWidth, height: MenuButtonType.MenuSettings.buttonHeight), menuType: MenuButtonType.MenuSettings, buttonNumber: 3, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(settingsButton)
        self.addSubview(settingsButton)
        
        let recordButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuRecord.buttonWidth, height: MenuButtonType.MenuRecord.buttonHeight), menuType: MenuButtonType.MenuRecord, buttonNumber: 4, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(recordButton)
        self.addSubview(recordButton)
    }
    
    func menuOn(){
        self.frame = CGRect(x: Int(initFrame.origin.x), y: Int(initFrame.origin.y), width: Int(onFrame.width), height: Int(onFrame.height))
        for (index,item) in menuButtonArr.enumerated() {
            let width = item.menuType.buttonWidth
            item.aniToXabsolute(Double(index)*0.05, x: Double(xPos(width)))
            print("menuOn x: \(Double(xPos(width)))")
        }
    }
    
    func menuOff(){
        self.frame = CGRect(x: Int(initFrame.origin.x), y: Int(initFrame.origin.y), width: Int(initFrame.width), height: Int(initFrame.height))
        for (index,item) in menuButtonArr.enumerated() {
            let width = onFrame.width + (item.frame.width/2)
            item.aniToXabsolute(Double(index)*0.05, x: Double(width))
            print("menuOff x: \(xPos(Int(width)))")
        }
    }
    
    func xPos(_ buttonWidth: Int) -> Int{
        let paddingLeft = 0
        let frameWidth = Int(onFrame.width)-paddingLeft-(buttonWidth/2)
        print("xPos width: \(frameWidth)")
        return frameWidth
    }
}
