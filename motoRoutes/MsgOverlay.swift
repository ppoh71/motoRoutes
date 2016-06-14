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
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var textLabel: UILabel!
    
    
    let saveBtnText = "Save"
    let resumeBtnText = "Resume"
    let saveLabelText = "Save Route ?"
    let resumeLabelText = "Resume Recording. Not enough GPS Data"
    
    
    @IBInspectable var CornerRadius: CGFloat = 3.0 {
        didSet{
            setupView(nil)
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
        setupView(nil)
        
    }
    
    override func awakeFromNib() {
        setupView(nil)
    }
    
    /**
     Setup Overlay Layout
     
     - parameter type: optional String of lyout type "saveLayout", "resumeLayout"
     
     */
    func setupView(type: String?){
        self.layer.cornerRadius = CornerRadius
       
        if(type=="saveLayout"){
            saveButton.enabled = true
            resumeButton.enabled = true
            textLabel.text = saveLabelText
        }
        
        if(type=="resumeLayout"){
            saveButton.enabled = false
            resumeButton.enabled = true
            textLabel.text = resumeLabelText
        }
        
        
    }

}
