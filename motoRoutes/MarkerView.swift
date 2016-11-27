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
    var initFrame = markerViewRect
    let offset = CGFloat(0)
    var backView = UIView()
    var clipView = UIView()
    let confirmView = ActionConfirm(frame: confirmViewRect, actionType: ActionButtonType.DefState, xOff: true)
    let dot = DotAnimation()
    var durationValue = ""
    var highspeedValue = ""
    var altitudeValue = ""
    var actionButtonsArr = [ActionButton]()
    var infoLabelArr = [InfoLabel]()
    var state = MarkerViewState()
    
    //MARK: INIT
    init(reuseIdentifier: String, routeMaster: RouteMaster, type: MarkerViewType) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MarkerView.actionButtonNotify),
                                               name: NSNotification.Name(rawValue: actionButtonNotificationKey), object: nil)
        
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
        setupInfoLabels()
        setupActionMenuButton()
        setupActionMenuButtonReset()
        setupActionMenu(actionMenuType: ActionMenuType.MyRoutes)
        setupConfirmView()
    }
    
    //MARK:
    func actionButtonNotify(_ notification: Notification){
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
    
    func setupActionMenuButton(){
        let menuImage = UIImage(named: "menuBtn") as UIImage?
        let button   = UIButton()
        let buttonSize = CGPoint(x: 24, y: 24)
        button.frame = CGRect(x: (backView.frame.width/2) - (buttonSize.x/2), y: backView.frame.height - (buttonSize.y + (buttonSize.y/2)) , width: buttonSize.x, height: buttonSize.y)
        button.setImage(menuImage, for: .normal)
        button.actionType = .ActionMenuMyRoutes
        button.addTarget(self, action: #selector(pressedActionMenuButton), for: .touchUpInside)
        self.addSubview(button)
    }
    
    func setupActionMenuButtonReset(){
        let menuImage = UIImage(named: "backBtn") as UIImage?
        let button   = UIButton()
        let buttonSize = CGPoint(x: 24, y: 24)
        button.frame = CGRect(x: 20, y: backView.frame.height - (buttonSize.y + (buttonSize.y/2)) , width: buttonSize.x, height: buttonSize.y)
        button.setImage(menuImage, for: .normal)
        button.actionType = .ActionMenuMyRoutes
        button.addTarget(self, action: #selector(pressedActionMenuResetButton), for: .touchUpInside)
        self.addSubview(button)
    }
    
    func pressedActionMenuButton(_ sender: UIButton){
        state = .ActionButtonsState
        switch(sender.actionType!) {
        case .ActionMenuMyRoutes:
            
            animateItems(actionButtonsArr, aniType: .onFromLeft, delay: 0)
            animateItems(infoLabelArr, aniType: .offToRight, delay: 0)
            
        default:
            print("xx")
        }
    }
    
    func pressedActionMenuResetButton(_ sender: UIButton){
        print("Pressed Memni")
        
        switch(state){
        case .ActionButtonsState:
            state = .InfoLabelState
            animateItems(actionButtonsArr, aniType: .offToLeft, delay: 0)
            animateItems(infoLabelArr, aniType: .onFromLeft, delay: 0)
       
        case .ConfirmViewState:
            state = .ActionButtonsState
            animateItems(actionButtonsArr, aniType: .onFromLeftSimultan, delay: 0)
            animateItems([confirmView], aniType: .offToLeft, delay: 0)
            
        case .InfoLabelState:
            print("pressed menu reset cofirm view")
        }
        
        //animateItems(infoLabelArr, aniType: .onFromLeft, delay: 0)
        
    }
    
    func setupInfoLabels(){
        clipView = UIView(frame: CGRect(x: 10, y: 30, width: initFrame.width, height: initFrame.height - 30))
        clipView.clipsToBounds = true
        self.addSubview(clipView)
        
        let durationLabel = InfoLabel(labelNumber: 0, labelType: LabelType.duration, value: durationValue, xOff: true)
        clipView.addSubview(durationLabel)
        
        let altitudeLabel = InfoLabel(labelNumber: 1, labelType: LabelType.altitude, value: altitudeValue, xOff: true)
        clipView.addSubview(altitudeLabel)
        
        let speedLabel = InfoLabel(labelNumber: 2, labelType: LabelType.speed, value: highspeedValue, xOff: true)
        clipView.addSubview(speedLabel)
        
        infoLabelArr += [durationLabel, altitudeLabel, speedLabel]
        //animateInfoLabels(infoLabelArr)
        animateItems(infoLabelArr, aniType: .onFromLeft, delay: 0.4)
        
    }
    
    func setupActionMenu(actionMenuType: ActionMenuType){
        let actionView = UIView(frame: CGRect(x: 0, y: 0, width: 125, height: 150 ))
        actionView.layer.opacity = 1
        clipView.addSubview(actionView)
        
        let detailButton = ActionButton(buttonType: ActionButtonType.Details, buttonNumber: 0, xOff: true)
        actionView.addSubview(detailButton)
        actionButtonsArr.append(detailButton)
        
        switch (actionMenuType){
            
        case .MyRoutes:
            let shareButton = ActionButton( buttonType: ActionButtonType.ShareRoute, buttonNumber: 1, xOff: true)
            actionButtonsArr.append(shareButton)
            actionView.addSubview(shareButton)
            
            let deleteButton = ActionButton(buttonType: ActionButtonType.DeleteRoute, buttonNumber: 2, xOff: true)
            actionButtonsArr.append(deleteButton)
            actionView.addSubview(deleteButton)
            
        case .AllRoutes:
            let downloadButton = ActionButton(buttonType: ActionButtonType.ConfirmDownload, buttonNumber: 1, xOff: true)
            actionButtonsArr.append(downloadButton)
            actionView.addSubview(downloadButton)
        }
    }
    
    func setupConfirmView(){
        clipView.addSubview(confirmView)
    }
    
    func setupActionConfirm(actionType: ActionButtonType){
        state = .ConfirmViewState
        confirmView.setupConfirm(actionType)
        animateItems(actionButtonsArr, aniType: .offToRightSimultan, delay: 0)
        confirmView.aniToX(0)
    }
    
    func animateItems(_ itemArr: [MarkerViewItems], aniType: AnimationType, delay: Double){
        var _delay = delay
        
        for item in itemArr {
            switch(aniType){
                
            case .onFromLeft:
                item.aniToX(_delay)
                _delay = _delay+0.2
                
            case .onFromLeftSimultan:
                item.aniToX(_delay)
                
            case .offToLeft:
                item.aniOffToLeft(_delay)
                _delay = _delay+0.2
                
            case .offToRight:
                item.aniToOff(_delay)
                _delay = _delay+0.2
            
            case .offToRightSimultan:
                item.aniToOff(_delay)
            }
        }
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
    
    func dotAnimation(){
        dot.frame = CGRect(x: initFrame.width/2, y: initFrame.height, width: 10, height: 10)
        self.addSubview(dot)
        dot.addDotAnimation()
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
