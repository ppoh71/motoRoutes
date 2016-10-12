//
//  RouteCell.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 04.10.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

class RouteCell: UICollectionViewCell {

    @IBOutlet weak var routeImage: UIImageView!
    @IBOutlet weak var routeLbl: UILabel!
    @IBOutlet weak var viewLabel: UIView!
    var route: RouteMaster!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0.5
    }
    
    func configureCell(_ label: String, image: UIImage) {
        routeLbl.text = label
        routeImage.image = image
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
    
}
