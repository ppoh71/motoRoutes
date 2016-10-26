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
    let dot = DotAnimation()
    let confirmView = ActionConfirm(frame: CGRect(x: 140, y: 130, width: 125, height: 100 ), actionType: ActionButtonType.DefState)
    var durationValue = ""
    var highspeedValue = ""
    var altitudeValue = ""
    
    
    //MARK: INIT
    init(reuseIdentifier: String, color: UIColor, routeMaster: RouteMaster) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.durationValue = routeMaster.textDuration
        self.altitudeValue = routeMaster.textHighAlt
        self.highspeedValue = routeMaster.textHighSpeed
        self.backgroundColor = red1
        
        scalesWithViewingDistance = true
        centerOffset = CGVector(dx: 0,  dy: -initFrame.height/2)

        //add transparent background view
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: initFrame.width, height: initFrame.height - 10))
        backView.backgroundColor = blue4
        backView.layer.opacity = 0.5
        self.addSubview(backView)
        
        setupInfoLabels()
        setupActionMenu()
        dotAnimation()
        
        let menuImage = UIImage(named: "menuIcon") as UIImage?
        let button   = UIButton()
        let buttonSize = CGPoint(x: 24, y: 24)
        button.frame = CGRect(x: (backView.frame.width/2) - (buttonSize.x/2), y: backView.frame.height - (buttonSize.y + (buttonSize.y/2)) , width: buttonSize.x, height: buttonSize.y)
        button.setImage(menuImage, for: .normal)
        backView.addSubview(button)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MarkerView.actionButtonNotify), name: NSNotification.Name(rawValue: actionButtonNotificationKey), object: nil)
        
        //confirmView = ActionConfirm(frame: CGRect(x: 140, y: 130, width: 125, height: 100 ), actionType: ActionButtonType.DefState)
        self.addSubview(confirmView)
    }
    

    
    //notifycenter func: when no marker while flying over routesm switch to stop all and start marker printing
    func actionButtonNotify(_ notification: Notification){
        
        //get object from notification
        let arrayObject =  notification.object as! [AnyObject]
        
        print("Notify by action Button \(arrayObject)")
        if let actionType = arrayObject[0] as? ActionButtonType {
            
            setupActionConfirm(actionType: actionType)
            
        }
    }
    
    //Mark: Info Labels
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
    
    //Mark: ActionMenu
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
        
        let deleteButton = ActionButton(initFrame: CGRect(x: 0, y: btnSize.y * 2 + CGFloat(offset*2), width: btnSize.x, height: btnSize.y), buttonType: ActionButtonType.DeleteRoute)
        actionView.addSubview(deleteButton)
    }
    
    
    func setupActionConfirm(actionType: ActionButtonType){
        
        confirmView.setupConfirm(actionType)
//        let confirm = ActionConfirm(frame: CGRect(x: 140, y: 130, width: 125, height: 100 ), actionType: actionType)
//        self.addSubview(confirm)

    }
    
    
    func pressedButton(_ sender: UIButton){
        print("pressed ActionButton")
     }
    
    func dotAnimation(){
        dot.frame = CGRect(x: initFrame.width/2, y: initFrame.height, width: 10, height: 10)
        self.addSubview(dot)
        dot.addDotAnimation()
    }
    
    // These two initializers are forced upon us by Swift.
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



