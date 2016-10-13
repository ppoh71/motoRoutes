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
    @IBOutlet weak var routeLbl: UILabel!
    @IBOutlet weak var viewLabel: UIView!
    @IBOutlet weak var detailBtn: UIButton!
    var route: RouteMaster!
    var routeId = ""
    var index = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0.5
    }
    
    func configureCell(_ label: String, id: String, image: UIImage, index: Int) {
        self.routeId = id
        self.index = index
        self.routeLbl.text = label
        self.routeImage.image = image
    }
    
    func toggleSelected ()
    {
        if (isSelected){
            print("toggle red")
            viewLabel.backgroundColor = UIColor.red
        } else {
            print("toggle black")
            viewLabel.backgroundColor = UIColor.black
        }
    }
    
    @IBAction func pressedDetail(_ sender: UIButton){
        print("pressed in cell")
        if(delegate != nil){
            print("pressed in cell not nil")
            delegate?.pressedDetails(id: routeId, index: index)
        }
    }
    
}
