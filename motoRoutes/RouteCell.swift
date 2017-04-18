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
    @IBOutlet weak var backView: UIView!
    
    var route: RouteMaster!
    var routeId = ""
    var index = 0
    let offsetUp = CGFloat(10)
    let offsetDown = CGFloat(40)
    var isSlideUp = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(label: String, datetime: String, id: String, route: RouteMaster, image: UIImage, index: Int) {
        self.routeId = id
        self.index = index
        self.route = route
        self.distanceLbl.text = "\(label)"
        self.durationLbl.text = "\(datetime)"
        self.distanceLbl.textColor = UIColor.white
        self.routeImage.image = image
        self.layer.cornerRadius = cornerInfoViews
        //self.backView.backgroundColor = blue3
        //self.detailBtn.backgroundColor = blue4
        self.layer.borderWidth = 2
        self.layer.borderColor = blue2.cgColor
        self.layer.cornerRadius = 10;
        self.clipsToBounds = true
    }
    
    func toggleSelected ()
    {
        detailBtn.frame.origin.y = 0
        if (isSelected){
           // viewLabel.backgroundColor = blue2
            slideUpInfo()
            //detailBtn.alpha = 0.8
            detailBtn.aniToYabsolute(0, y: 51)
        } else {
            //viewLabel.backgroundColor = blue2
            slideDownInfo()
            detailBtn.alpha = 0
            
        }
    }
    
    func slideUpInfo(){
//        //print("slide up info")
//        AnimationEngine.animationToPosition(viewLabel, position: CGPoint(x: self.frame.width/2, y: self.frame.height - offsetUp))
//        AnimationEngine.animationToPositionImageView(routeImage, position:  CGPoint(x: routeImage.frame.width/2, y: routeImage.frame.height/2 - offsetUp))
//        isSlideUp = true
    }
    
    func slideDownInfo(){
//        //print("slide down info")
//        AnimationEngine.animationToPosition(viewLabel, position: CGPoint(x: self.frame.width/2, y: self.frame.height + offsetDown))
//        
//        if(isSlideUp == true){
//            AnimationEngine.animationToPositionImageView(routeImage, position:  CGPoint(x: routeImage.frame.width/2, y: routeImage.frame.height/2))
//            isSlideUp = false
//        }
    }
    
    @IBAction func pressedDetail(_ sender: UIButton){
      //  print("pressed in cell")
        if(delegate != nil){
           // print("pressed in cell not nil")
            delegate?.pressedDetails(id: routeId, index: index)
        }
    }
}
