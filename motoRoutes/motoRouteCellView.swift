//
//  motoRouteCellControllerTableViewCell.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 26.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import CoreLocation

class motoRouteCellView: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var routeImage: UIImageView!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
