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
    
    //this lets us check to see if the item is supposed to be displayed or not
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

}
