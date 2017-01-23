//
//  ButtonExtension.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 26.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

extension UIButton {

    private struct ButtonTypeStruct {
        static var actionType = ActionButtonType()
    }
    
    private struct MenunTypeStruct {
        static var menuType = MenuButtonType()
    }
    
    //add actionType property 
    var actionType : ActionButtonType? {
        get {
            return objc_getAssociatedObject(self, &ButtonTypeStruct.actionType) as? ActionButtonType
        }
        
        set(newValue) {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &ButtonTypeStruct.actionType, newValue as ActionButtonType?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    var menuType : MenuButtonType? {
        get {
            return objc_getAssociatedObject(self, &MenunTypeStruct.menuType) as? MenuButtonType
        }
        
        set(newValue) {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &MenunTypeStruct.menuType, newValue as MenuButtonType?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if(self.actionType == .ActionMenuMyRoutes || self.actionType == .MenuActionButton || self.actionType == .MenuConfirm || self.actionType == .MenuInfoLabels) {
                    self.scale(3)
                }else{
                    backgroundColor = blue2
                }
            } else {
                if(self.actionType == .ActionMenuMyRoutes || self.actionType == .MenuActionButton || self.actionType == .MenuConfirm || self.actionType == .MenuInfoLabels) {
                    self.scale(4)
                }else{
                  //  backgroundColor = blue3
                }
            }
        }
    }
}
