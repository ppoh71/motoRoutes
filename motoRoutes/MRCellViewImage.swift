//
//  MRCellViewImage.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 02.06.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


@IBDesignable
class MRCellViewImage: UIImageView{

    @IBInspectable var cornerRadius: CGFloat = 3.0 {
        didSet{
            setupView()
        }
    }

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()  
        setupView()
    }
    
}
