//
//  motoButtons.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 07.06.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import pop


@IBDesignable

class motoButtons: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 3.0{
        didSet{
            setupView()
        }
    }

    override func awakeFromNib(){
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = cornerRadius
        self.addTarget(self, action: #selector(motoButtons.scaleToSmall), for:  .touchDown)
        self.addTarget(self, action: #selector(motoButtons.scaleToSmall), for: .touchDragEnter)
        self.addTarget(self, action: #selector(motoButtons.scaleAnimation), for: .touchUpInside)
        self.addTarget(self, action: #selector(motoButtons.scaleDefault), for: .touchDragExit)
    }
    
    func scaleToSmall(){
        let scaleAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnim?.toValue = NSValue(cgSize: CGSize(width: 0.95, height: 0.95))
        self.layer.pop_add(scaleAnim, forKey: "layerScaleSmallAnimation")
        
    }
    
    func scaleAnimation(){
        let scaleAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnim?.velocity = NSValue(cgSize: CGSize(width: 3.0, height: 3.0))
        scaleAnim?.toValue = NSValue(cgSize: CGSize(width: 1.0, height: 1.0))
        scaleAnim?.springBounciness = 18
        self.layer.pop_add(scaleAnim, forKey: "layerSpringAnimation")
    }
    
    func scaleDefault(){
        let scaleAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnim?.toValue    = NSValue(cgSize: CGSize(width: 1.0, height: 1.0))
        self.layer.pop_add(scaleAnim, forKey: "layeeScaleDefaultAnimation")
    }
    
}
