//
//  motoRouteCellControllerTableViewCell.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 26.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import CoreLocation

class MRCellView: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var routeImage: MRCellViewImage!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /*
        routeImage.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        routeImage.layer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        
        routeImage.layer.masksToBounds = false
        routeImage.layer.borderWidth = 1.0
        routeImage.layer.borderColor = UIColor.whiteColor().CGColor
        routeImage.layer.cornerRadius = (routeImage.layer.frame.height/2)
        routeImage.clipsToBounds = true
        
        routeImage.layer.masksToBounds = true
        print("rounded \(routeImage.frame.size.height/2)")
        */
  
    }
    
    //config func of cell
    func configureCell(name:String, distance:String, image: UIImage, fromCoordinate: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D){
    
        nameLabel.text = name
        distanceLabel.text = distance
        routeImage.image   = image
        
        
        //assign async text to label
        geocodeUtils.setAdress2Label(fromCoordinate, format: nil, label: fromLabel)
        geocodeUtils.setAdress2Label(toCoordinate, format: nil, label: toLabel)
        
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
