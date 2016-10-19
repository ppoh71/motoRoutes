//
//  RouteCell.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 04.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

protocol RouteCellDelegate: class {
    func pressedDetails(id: String, index: Int)
}


class RouteCell: UICollectionViewCell {
    
    weak var delegate: RouteCellDelegate?

    @IBOutlet weak var routeImage: UIImageView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var viewLabel: UIView!
    @IBOutlet weak var detailBtn: UIButton!

    var route: RouteMaster!
    var routeId = ""
    var index = 0
    let offsetUp = CGFloat(10)
    let offsetDown = CGFloat(40)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
    }
    
    func configureCell(_ label: String, id: String, route: RouteMaster, image: UIImage, index: Int) {
        self.routeId = id
        self.index = index
        self.route = route
        self.distanceLbl.text = "\(Utils.distanceFormat(route.routeDistance)) km"
        self.durationLbl.text = "\(Utils.clockFormat(route.routeTime)) h"
        self.routeImage.image = image
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 2
        self.layer.borderColor = blue1.cgColor
    }
    
    
    func toggleSelected ()
    {
        if (isSelected){
            viewLabel.backgroundColor = blue2
            slideUpInfo()
        } else {
            viewLabel.backgroundColor = blue2
            slideDownInfo()
        }
    }
    
    
    func slideUpInfo(){
        print("slide up info")
        AnimationEngine.animationToPosition(viewLabel, position: CGPoint(x: self.frame.width/2, y: self.frame.height - offsetUp))
        AnimationEngine.animationToPositionImageView(routeImage, position:  CGPoint(x: routeImage.frame.width/2, y: routeImage.frame.height/2 - offsetUp))
    }
    
    
    func slideDownInfo(){
        print("slide down info")
        AnimationEngine.animationToPosition(viewLabel, position: CGPoint(x: self.frame.width/2, y: self.frame.height + offsetDown))
        AnimationEngine.animationToPositionImageView(routeImage, position:  CGPoint(x: routeImage.frame.width/2, y: routeImage.frame.height/2))
    }
    
    
    @IBAction func pressedDetail(_ sender: UIButton){
        print("pressed in cell")
        if(delegate != nil){
            print("pressed in cell not nil")
            delegate?.pressedDetails(id: routeId, index: index)
        }
    }
    
}
