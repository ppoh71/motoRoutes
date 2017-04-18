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
    var initFrame = markerViewRect
    var backView = UIView()
    var clipView = UIView()
    let confirmView = ActionConfirm(frame: confirmViewRect, actionType: ActionButtonType.DefState, xOff: true)
    var dot = DotAnimation()
    var durationValue = ""
    var highspeedValue = ""
    var altitudeValue = ""
    var actionButtonsArr = [ActionButton]()
    var infoLabelArr = [InfoLabel]()
    var menuButton = UIButton()
    
    //MARK: INIT
    init(reuseIdentifier: String, routeMaster: RouteMaster, type: MarkerViewType) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        isDraggable = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(MarkerView.actionButtonNotify), name: NSNotification.Name(rawValue: actionButtonNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MarkerView.progressDoneNotify), name: NSNotification.Name(rawValue: progressDoneNotificationKey), object: nil)
        
        scalesWithViewingDistance = true
        centerOffset = CGVector(dx: -initFrame.width/2,  dy: -initFrame.height/2)
        self.clipsToBounds = false
        setupBackView()
        dotAnimation()
        
        switch type{
        case .MyRoute:
            setupAll(routeMaster, menuType: MarkerViewType.MyRoute)
            print("x")
        case .FirRoute:
            actionSpinner()
        default:
            break
        }
    }
    
    func setupAll(_ routeMaster: RouteMaster, menuType: MarkerViewType){
        self.durationValue = routeMaster.textDuration
        self.altitudeValue = routeMaster.textHighAlt
        self.highspeedValue = routeMaster.textHighSpeed
        
        removeSubview(99)
        setupCloseButton()
        setupClipView()
        setupInfoLabels()
        setupActionMenuButton()
        setupActionMenu(menuType: menuType)
        setupConfirmView()
    }
    
    //MARK: Setup UI elements
    func setupBackView(){
        backView.frame = CGRect(x: 0, y: 0, width: initFrame.width, height: initFrame.height - 30)
        backView.backgroundColor = blue4
        backView.layer.opacity = 0.0
        backView.clipsToBounds = false
        backView.layer.cornerRadius = 3
        self.addSubview(backView)
    }
    
    func setupActionMenuButton(){
        let buttonSize = CGPoint(x: 10, y: 10)
        menuButton.frame = CGRect(x: (backView.frame.width/2) - (buttonSize.x/2), y: backView.frame.height - 38 , width: buttonSize.x, height: buttonSize.y)
        print(buttonSize)
        menuButton.setImage(ActionButtonType.ActionMenuMyRoutes.buttonImage, for: .normal)
        menuButton.actionType = .ActionMenuMyRoutes
        menuButton.addTarget(self, action: #selector(pressedActionMenuButton), for: .touchUpInside)
        menuButton.scaleSize(size: 4)
        self.addSubview(menuButton)
    }
    
    func setupClipView(){
        clipView = UIView(frame: CGRect(x: 10, y: 30, width: actionLabelWidth, height: (actionLabelHeight*3)+(actionLabelPadding)))
        clipView.clipsToBounds = true
        self.addSubview(clipView)
    }
    
    func setupInfoLabels(){
        let durationLabel = InfoLabel(labelNumber: 0, labelType: LabelType.duration, value: durationValue, xOff: true)
        clipView.addSubview(durationLabel)
        
        let altitudeLabel = InfoLabel(labelNumber: 1, labelType: LabelType.altitude, value: altitudeValue, xOff: true)
        clipView.addSubview(altitudeLabel)
        
        let speedLabel = InfoLabel(labelNumber: 2, labelType: LabelType.speed, value: highspeedValue, xOff: true)
        clipView.addSubview(speedLabel)
        
        infoLabelArr += [durationLabel, altitudeLabel, speedLabel]
        AnimationEngine.animateItems(infoLabelArr, aniType: .onFromLeft, delay: 0.4)
    }
    
    func setupActionMenu(menuType: MarkerViewType){
        let detailButton = ActionButton(actionType: ActionButtonType.Details, buttonNumber: 0, xOff: true)
        clipView.addSubview(detailButton)
        actionButtonsArr.append(detailButton)
        
        switch (menuType){
        case .MyRoute:
            let shareButton = ActionButton( actionType: ActionButtonType.ShareRoute, buttonNumber: 1, xOff: true)
            actionButtonsArr.append(shareButton)
            clipView.addSubview(shareButton)
            
            let deleteButton = ActionButton(actionType: ActionButtonType.DeleteRoute, buttonNumber: 2, xOff: true)
            actionButtonsArr.append(deleteButton)
            clipView.addSubview(deleteButton)
            
        case .FirRoute:
            let downloadButton = ActionButton(actionType: ActionButtonType.DownloadRoute, buttonNumber: 1, xOff: true)
            actionButtonsArr.append(downloadButton)
            clipView.addSubview(downloadButton)
            
            let deleteButtonFIR = ActionButton(actionType: ActionButtonType.DeleteRouteFIR, buttonNumber: 2, xOff: true)
            actionButtonsArr.append(deleteButtonFIR)
            clipView.addSubview(deleteButtonFIR)
        default:
            print("default action menu")
        }
    }
    
    func setupConfirmView(){
        clipView.addSubview(confirmView)
    }
    
    func setupActionConfirm(actionType: ActionButtonType){
        confirmView.setConfirmType(actionType)
        AnimationEngine.animateItems(actionButtonsArr, aniType: .offToRightSimultan, delay: 0)
        confirmView.aniToX(0)
    }
    
    func actionSpinner(){
        let spinner = SpinnerView(frame: CGRect(x: (backView.frame.width/2) - (15), y: backView.frame.height - 45, width: 20, height: 20), color: UIColor.white)
        spinner.tag = 99
        self.addSubview(spinner)
    }
    
    func setupSpinner(){
        let spinner = SpinnerView(frame: CGRect(x: initFrame.width/4, y: initFrame.height/4, width: initFrame.height/6, height: initFrame.height/6))
        spinner.tag = 99
        self.addSubview(spinner)
    }
    
    func setupCloseButton(){
        let closeButton = UIButton(frame: CGRect(x: markerViewRect.width-35, y: 5, width: 20, height: 20))
        closeButton.isUserInteractionEnabled = true
        closeButton.actionType = ActionButtonType.CloseMarkerView
        closeButton.setImage(ActionButtonType.CloseMarkerView.buttonImage, for: .normal)
        closeButton.addTarget(self, action: #selector(closeMarkerView), for: .touchUpInside)
        backView.addSubview(closeButton)
    }

    func closeMarkerView(_ sender: UIButton){
        let notifyObj = [sender.actionType]
        print(notifyObj)
        NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
    }
    
    //MARK: Actions
    func actionButtonNotify(_ notification: Notification){
        let notifyObj =  notification.object as! [AnyObject]
        if let actionType = notifyObj[0] as? ActionButtonType {
            print("###actionButtonNotify \(actionType)")
            switch(actionType) {
                
            case .Details:
                print("NOTFY: Clicked Details")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                
            case .DeleteRoute:
                print("NOTFY: Delete Route")
                setupActionConfirm(actionType: actionType)
                switchActionMenuButton(.MenuActionButton)
                
            case .DeleteRouteFIR:
                print("NOTFY: Delete Route FIR")
                setupActionConfirm(actionType: actionType)
                switchActionMenuButton(.MenuActionButton)
                
            case .ShareRoute:
                print("NOTFY: Share Route")
                setupActionConfirm(actionType: actionType)
                switchActionMenuButton(.MenuActionButton)
                
            case .DownloadRoute:
                print("NOTFY: Download Route \(actionType)")
                setupActionConfirm(actionType: actionType)
                
            case .ConfirmDelete:
                print("NOTFY: Confirm Delete")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                confirmView.progressOn(ActionButtonType.ProgressDelete)
                actionSpinner()
                menuButton.scaleSize(0, size: 0)
                
            case .ConfirmDeleteFIR:
                print("NOTFY: Confirm Delete FIR")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                confirmView.progressOn(ActionButtonType.ProgressDeleteFIR)
                actionSpinner()
                menuButton.scaleSize(0, size: 0)
                
            case .ConfirmShare:
                print("NOTFY: Confirm Share")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                confirmView.progressOn(ActionButtonType.ProgressShare)
                actionSpinner()
                menuButton.scaleSize(0, size: 0)
                
            case .ConfirmDownload:
                print("NOTFY: Confirm Download")
                NotificationCenter.default.post(name: Notification.Name(rawValue: actionConfirmNotificationKey), object: notifyObj)
                confirmView.progressOn(ActionButtonType.ProgressDownload)
                actionSpinner()
                menuButton.scaleSize(0, size: 0)
                
            default:
                print("default click")
            }
        }
    }
    
    func progressDoneNotify(_ notification: Notification){
        print("progress Done")
        let notifyObj =  notification.object as! [AnyObject]
        if let progressDoneType = notifyObj[0] as? ProgressDoneType {
            
            switch(progressDoneType){
                
            case .ProgressDoneShare:
                print("progress done share")
                progressFinish(.ProgressShare)
                
            case .ProgressDoneDownload:
                print("progress Download Done")
                progressFinish(.ProgressDownload)
                
            case .ProgressDoneDelete:
                progressFinish(.ProgressDelete)
                
            default:
                print("default progress done")
            }
        }
    }
    
    func pressedActionMenuButton(_ sender: UIButton){
        switch(sender.actionType!) {
            
        case .ActionMenuMyRoutes: //switch on menu button
            AnimationEngine.animateItems(actionButtonsArr, aniType: .onFromLeft, delay: 0)
            AnimationEngine.animateItems(infoLabelArr, aniType: .offToRight, delay: 0)
            switchActionMenuButton(.MenuInfoLabels)
            
        case .MenuInfoLabels: //switch confirmation
            AnimationEngine.animateItems(actionButtonsArr, aniType: .offToLeft, delay: 0)
            AnimationEngine.animateItems(infoLabelArr, aniType: .onFromLeft, delay: 0)
            switchActionMenuButton(.ActionMenuMyRoutes)
            
        case .MenuActionButton: //cancel confirmation
            AnimationEngine.animateItems(actionButtonsArr, aniType: .onFromLeftSimultan, delay: 0)
            AnimationEngine.animateItems([confirmView], aniType: .offToLeft, delay: 0)
            switchActionMenuButton(.MenuInfoLabels)
            
        default:
            print("xx")
        }
    }
    
    func progressFinish(_ actionType: ActionButtonType){
        self.confirmView.progressDone()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.removeSubview(99)
            self.switchActionMenuButton(ActionButtonType.ActionMenuMyRoutes)
            
            switch(actionType){
                
            case .ProgressDelete:
                self.markerViewOff()
                
            case .ProgressShare:
                self.resetToMenu()
                self.menuButton.scaleSize(0, size: 4)
                
            case .ProgressDownload:
                self.resetToMenu()
                self.menuButton.scaleSize(0, size: 4)
                
            default:
                print("default")
            }
        })
    }
    
    func switchActionMenuButton(_ type: ActionButtonType){
        menuButton.actionType = type
        menuButton.setImage(type.buttonImage, for: .normal)
    }
    
    func resetToMenu(){
        AnimationEngine.animateItems([self.confirmView], aniType: .offToLeft, delay: 0)
        AnimationEngine.animateItems(self.infoLabelArr, aniType: .onFromLeft, delay: 0)
    }
    
    func removeSubview(_ tag: Int){
        if let viewWithTag = self.viewWithTag(tag) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func dotAnimation(){
        dot = DotAnimation(frame: CGRect(x: initFrame.width, y: initFrame.height, width: 10, height: 10), color: red1)
        dot.tag=100
        self.addSubview(dot)
        dot.addDotAnimation()
    }
    
    func markerViewOff(){
        AnimationEngine.animateItems([confirmView], aniType: .offToLeft, delay: 0)
        removeSubview(99)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.removeSubview(100)
            self.self.scaleSize(0, size: 0)
            self.backView.backgroundColor = UIColor.clear
        })
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
    }
    
    override func setDragState(_ dragState: MGLAnnotationViewDragState, animated: Bool) {
        super.setDragState(dragState, animated: animated)
        
        switch dragState {
        case .starting:
            print("Starting", terminator: "")
            startDragging()
        case .dragging:
            print(".", terminator: "")
        case .ending, .canceling:
            print("Ending")
            endDragging()
        case .none:
            return
        }
    }
    
    // When the user interacts with an annotation, animate opacity and scale changes.
    func startDragging() {
//        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
//            self.layer.opacity = 0.8
//            self.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
//        }, completion: nil)
    }
    
    func endDragging() {
//        transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
//        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
//            self.layer.opacity = 1
//            self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
//        }, completion: nil)
    }
}

