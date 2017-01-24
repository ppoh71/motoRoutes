//
//  MotoMenu.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 22.01.17.
//  Copyright © 2017 Peter Pohlmann. All rights reserved.
//

import UIKit

class MotoMenu: UIView {
    var onFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var menuButtonArr = [MenuButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.black
        onFrame = frame
        setupMenuButtons()
        menuOff()
        
        //Listen
        NotificationCenter.default.addObserver(self, selector: #selector(MotoMenu.menuAction),
                                               name: NSNotification.Name(rawValue: motoMenuNotificationKey), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMenuButtons(){
        let myRoutesButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuMyRoutes.buttonWidth, height: MenuButtonType.MenuMyRoutes.buttonHeight), menuType: MenuButtonType.MenuMyRoutes, buttonNumber: 0, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(myRoutesButton)
        self.addSubview(myRoutesButton)
        
        let cloudButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuCloud.buttonWidth, height: MenuButtonType.MenuCloud.buttonHeight), menuType: MenuButtonType.MenuCloud, buttonNumber: 1, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(cloudButton)
        self.addSubview(cloudButton)
        
        let settingsButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuSettings.buttonWidth, height: MenuButtonType.MenuSettings.buttonHeight), menuType: MenuButtonType.MenuSettings, buttonNumber: 2, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(settingsButton)
        self.addSubview(settingsButton)
        
        let recordButton = MenuButton(frame: CGRect(x: 0, y: 0 , width: MenuButtonType.MenuRecord.buttonWidth, height: MenuButtonType.MenuRecord.buttonHeight), menuType: MenuButtonType.MenuRecord, buttonNumber: 3, xOff: true, offset: Int(onFrame.width))
        menuButtonArr.append(recordButton)
        self.addSubview(recordButton)
    }
    
    func menuAction(_ notification: Notification){
        print("#######menu action \(notification)")
        let notifyObj =  notification.object as! [AnyObject]
        if let menuAction = notifyObj[0] as? MenuActionType {
            if(menuAction == .MenuOn){
                menuOn()
            }else{
                menuOff()
            }
        }
    }
    
    func menuOn(){
        self.frame = CGRect(x: Int(onFrame.origin.x - (onFrame.width)), y: Int(onFrame.origin.y), width: Int(onFrame.width), height: Int(onFrame.height))
        //self.aniToXabsolute(0, x: Double(Int(onFrame.origin.x - (onFrame.width/2))))
        
        for (index,item) in menuButtonArr.enumerated() {
            let width = item.menuType.buttonWidth
            item.aniToXabsolute(Double(index)*0.05, x: Double(xPos(width)))
            print("menuOn x: \(Double(xPos(width)))")
        }
    }
    
    func menuOff(){
        //self.frame = CGRect(x: Int(onFrame.origin.x+onFrame.width), y: Int(onFrame.origin.y), width: 5, height: Int(onFrame.height))
        self.aniToXabsolute(0.2, x: Double(onFrame.origin.x+onFrame.width))
        for (index,item) in menuButtonArr.enumerated() {
            let width = onFrame.width + (item.frame.width/2)
            item.aniToXabsolute(Double(index)*0.03, x: Double(width))
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
