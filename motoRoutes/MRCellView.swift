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
    func configureCell(_ name:String, distance:String, image: UIImage, fromLocation: String, toLocation: String){
    
        nameLabel.text = name
        distanceLabel.text = distance
        routeImage.image   = image
        fromLabel.text = fromLocation
        toLabel.text = toLocation
            
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
