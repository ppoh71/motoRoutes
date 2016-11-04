//
//  MarkerView.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 05.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import Mapbox


class MarkerView: MGLAnnotationView {
    
    let shapeLayer = CAShapeLayer()
    var dotCol = UIColor.blue
    var color = UIColor.clear
    var initFrame = CGRect(x: 0, y: 0, width: 280, height: 260)
    let offset = CGFloat(0)
    var backView = UIView()
    let dot = DotAnimation()
    let confirmView = ActionConfirm(frame: CGRect(x: 140, y: 130, width: 125, height: 100 ), actionType: ActionButtonType.DefState)
    var durationValue = ""
    var highspeedValue = ""
    var altitudeValue = ""
    
    
    //MARK: INIT
    init(reuseIdentifier: String, routeMaster: RouteMaster, type: MarkerViewType) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MarkerView.actionButtonNotify), name: NSNotification.Name(rawValue: actionButtonNotificationKey), object: nil)
        
        //self.backgroundColor = red1
        
        scalesWithViewingDistance = true
        centerOffset = CGVector(dx: 0,  dy: -initFrame.height/2)
        
        setupBackView()
        dotAnimation()
        
        
        switch type{
            case .MyRoute:
                setupAll(routeMaster)
            
            case .FirRoute:
                setupSpinner()
        }
    }
    
    
    func setupAll(_ routeMaster: RouteMaster){
        
        self.durationValue = routeMaster.textDuration
        self.altitudeValue = routeMaster.textHighAlt
        self.highspeedValue = routeMaster.textHighSpeed
        
        removeSpinner()
        setupMenuButton()
        setupInfoLabels()
        setupActionMenu()
    }
    
    
    //MARK:
    func actionButtonNotify(_ notification: Notification){
        
        //get object from notification
        let notifyObj =  notification.object as! [AnyObject]
        
        if let actionType = notifyObj[0] as? ActionButtonType {
            
            switch(actionType) {
                
            case .Details:
                print("NOTFY: Clicked Details")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                
            case .DeleteRoute:
                print("NOTFY: Delete Route")
                setupActionConfirm(actionType: actionType)
                
            case .ShareRoute:
                print("NOTFY: Share Route")
                setupActionConfirm(actionType: actionType)
                
            case .DownloadRoute:
                print("NOTFY: Download Route")
                setupActionConfirm(actionType: actionType)
                
            case .ConfirmDelete:
                print("NOTFY: Confirm Delete")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                
            case .ConfirmShare:
                print("NOTFY: Confirm Share")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                
            case .ConfirmDownload:
                print("NOTFY: Confirm Download")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                
            default:
                print("default click")
                
            }
        }
    }
    
    //MARK: Setup UI elements
    func setupBackView(){
        backView.frame = CGRect(x: 0, y: 0, width: initFrame.width, height: initFrame.height - 10)
        backView.backgroundColor = blue4
        backView.layer.opacity = 0.5
        self.addSubview(backView)
    }
    
    
    func setupMenuButton(){
        let menuImage = UIImage(named: "menuIcon") as UIImage?
        let button   = UIButton()
        let buttonSize = CGPoint(x: 24, y: 24)
        button.frame = CGRect(x: (backView.frame.width/2) - (buttonSize.x/2), y: backView.frame.height - (buttonSize.y + (buttonSize.y/2)) , width: buttonSize.x, height: buttonSize.y)
        button.setImage(menuImage, for: .normal)
        self.addSubview(button)
        

    }
    
    
    func setupSpinner(){
        let spinner = SpinnerView(frame: CGRect(x: initFrame.width/4, y: initFrame.height/4, width: initFrame.height/6, height: initFrame.height/6))
        spinner.tag = 99
        self.addSubview(spinner)
    }
    
    
    func removeSpinner(){
        if let viewWithTag = self.viewWithTag(99) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    
    func setupInfoLabels(){
        let clipView = UIView(frame: CGRect(x: 10, y: 30, width: initFrame.width, height: initFrame.height - 30))
        clipView.clipsToBounds = true
        self.addSubview(clipView)
        
        let durationLabel = InfoTemplate(labelNumber: 0, labelType: LabelType.duration, value: durationValue, xOff: true)
        durationLabel.aniToX(0.8)
        clipView.addSubview(durationLabel)
        
        let altitudeLabel = InfoTemplate(labelNumber: 1, labelType: LabelType.altitude, value: altitudeValue, xOff: true)
        altitudeLabel.aniToX(1.0)
        clipView.addSubview(altitudeLabel)
        
        let speedLabel = InfoTemplate(labelNumber: 2, labelType: LabelType.speed, value: highspeedValue, xOff: true)
        speedLabel.aniToX(1.2)
        clipView.addSubview(speedLabel)
        
    }
    
    
    func setupActionMenu(){
        
        let actionView = UIView(frame: CGRect(x: 140, y: 0, width: 125, height: 100 ))
        actionView.backgroundColor = green3
        actionView.layer.opacity = 1
        self.addSubview(actionView)
        
        let btnSize = CGPoint(x: 125, y: 20)
        let offset = 5
        
        let detailButton = ActionButton(initFrame: CGRect(x: 0, y: 0, width: btnSize.x, height: btnSize.y), buttonType: ActionButtonType.Details)
        actionView.addSubview(detailButton)
        
        let shareButton = ActionButton(initFrame: CGRect(x: 0, y: btnSize.y * 1 + CGFloat(offset), width: btnSize.x, height: btnSize.y), buttonType: ActionButtonType.ShareRoute)
        actionView.addSubview(shareButton)
        
        let downloadButton = ActionButton(initFrame: CGRect(x: 0, y: btnSize.y * 2 + CGFloat(offset*2), width: btnSize.x, height: btnSize.y), buttonType: ActionButtonType.ConfirmDownload)
        actionView.addSubview(downloadButton)
        
        let deleteButton = ActionButton(initFrame: CGRect(x: 0, y: btnSize.y * 3 + CGFloat(offset*3), width: btnSize.x, height: btnSize.y), buttonType: ActionButtonType.DeleteRoute)
        actionView.addSubview(deleteButton)
        
        self.addSubview(confirmView)
    }
    
    
    func dotAnimation(){
        dot.frame = CGRect(x: initFrame.width/2, y: initFrame.height, width: 10, height: 10)
        self.addSubview(dot)
        dot.addDotAnimation()
    }
    
    
    func setupActionConfirm(actionType: ActionButtonType){
        confirmView.setupConfirm(actionType)
    }
    
    
    //MARK: Initialiser
    override init(frame: CGRect) {
        super.init(frame: initFrame)
        print("init markerview frame")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
    }
    
}



