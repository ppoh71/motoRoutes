//
//  MsgOverlay.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 07.06.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

protocol msgOverlayDelegate: class {
    
    func pressedResume()
    func pressedSave()
}


enum MsgType {
    case save
    case resume
    case cancel
    case print
    
    init(){
        self = .save
    }
}


class MsgOverlay: UIView {
    
    weak var delegate: msgOverlayDelegate?
    var msgType = MsgType()
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var textLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    let saveLabelText = NSLocalizedString("View.Overlay.SaveRouteText", comment: "Save Route Text")
    let resumeLabelText = NSLocalizedString("View.Overlay.ResumeRouteText", comment: "Resume Route Text")
    let printAllMarkerlText = NSLocalizedString("View.Overlay.PrintAllMarkerText", comment: "Print All Marker Text")
    
    let saveButtonText = NSLocalizedString("View.Overlay.SaveButtonText", comment: "Save Button Text")
    let resumeButtonText = NSLocalizedString("View.Overlay.ResumeButtonText", comment: "Resume Button Text")
    let okButtonText = NSLocalizedString("View.Overlay.OKButtonText", comment: "OK Button Text")
    let cancelButtonText = NSLocalizedString("View.Overlay.CancelButtonText", comment: "Cancel Button Text")
    
    
    @IBInspectable var CornerRadius: CGFloat = 3.0 {
        didSet{
            setupView()
        }
    }
    
    
    @IBAction func saveAction(_ sender: UIButton){
        print("save Action Button")
        if(delegate != nil){
           
            delegate?.pressedSave()
        }
        
    }
    
    @IBAction func resumeAction(_ sender: UIButton){
         print("resume Action Button")
        if(delegate != nil){
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
    
    /**
     Setup Overlay Layout
     
     
     */
    func setupView(){
        self.layer.cornerRadius = CornerRadius
       
        
        switch msgType {
        
        case .save:
            print("Save enum case")
            saveButton.setTitle(saveButtonText, for: UIControlState())
            resumeButton.setTitle(resumeButtonText, for: UIControlState())
            saveButton.isEnabled = true
            resumeButton.isEnabled = true
            textLabel.text = saveLabelText
            
        case .resume:
            print("Resume enum case")
            saveButton.setTitle(saveButtonText, for: UIControlState())
            resumeButton.setTitle(resumeButtonText, for: UIControlState())
            saveButton.isEnabled = false
            resumeButton.isEnabled = true
            textLabel.text = resumeLabelText
        
        case .print:
            print("Resume enum case")
            saveButton.setTitle(okButtonText, for: UIControlState())
            resumeButton.setTitle(cancelButtonText, for: UIControlState())
            saveButton.isEnabled = true
            resumeButton.isEnabled = true
            textLabel.text = printAllMarkerlText
            
        default:
            print("default")
            
        }
        
        
                
        
    }

}
