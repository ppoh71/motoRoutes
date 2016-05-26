//
//  motoRouteCellControllerTableViewCell.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 26.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

class motoRouteCellView: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var routeImage: UIImageView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //config func of cell
    func configureCell(name:String, distance:String, image: UIImage){
    
        nameLabel.text = name
        distanceLabel.text = distance
        routeImage.image   = image
        
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
