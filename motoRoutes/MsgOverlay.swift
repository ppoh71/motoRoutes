//
//  MsgOverlay.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 07.06.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

protocol msgOverlayDelegate {
    
    func pressedResume()
    func pressedSave()
    
    
}

class MsgOverlay: UIView {
    
    var delegate: msgOverlayDelegate? 
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var resumeButtin: UIButton!
    
    @IBInspectable var CornerRadius: CGFloat = 3.0 {
        didSet{
            setupView()
        }
    }
    
    
    @IBAction func saveAction(sender: UIButton){
        print("save Action Button")
        if(delegate != nil){
            print(delegate)
            delegate?.pressedSave()
        }
        
    }
    
    @IBAction func resumeAction(sender: UIButton){
         print("resume Action Button")
        if(delegate != nil){
            print(delegate)
            delegate?.pressedResume()
        }
        
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
        
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = CornerRadius
    }

}
