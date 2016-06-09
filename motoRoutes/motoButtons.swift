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
        self.addTarget(self, action: #selector(motoButtons.scaleToSmall), forControlEvents:  .TouchDown)
        self.addTarget(self, action: #selector(motoButtons.scaleToSmall), forControlEvents: .TouchDragEnter)
        self.addTarget(self, action: #selector(motoButtons.scaleAnimation), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(motoButtons.scaleDefault), forControlEvents: .TouchDragExit)
    }
    
    func scaleToSmall(){
        let scaleAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnim.toValue = NSValue(CGSize: CGSizeMake(0.95, 0.95))
        self.layer.pop_addAnimation(scaleAnim, forKey: "layerScaleSmallAnimation")
        
    }
    
    func scaleAnimation(){
        let scaleAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnim.velocity = NSValue(CGSize: CGSizeMake(3.0, 3.0))
        scaleAnim.toValue = NSValue(CGSize: CGSizeMake(1.0, 1.0))
        scaleAnim.springBounciness = 18
        self.layer.pop_addAnimation(scaleAnim, forKey: "layerSpringAnimation")
    }
    
    func scaleDefault(){
        let scaleAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnim.toValue    = NSValue(CGSize: CGSizeMake(1.0, 1.0))
        self.layer.pop_addAnimation(scaleAnim, forKey: "layeeScaleDefaultAnimation")
    }
    
}
