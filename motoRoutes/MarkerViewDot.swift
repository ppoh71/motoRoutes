//
//  MarkerViewDot.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 21.12.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class MarkerViewDot: MGLAnnotationView {
    var initFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
    var dot = DotAnimation()
    
    //MARK: INIT
    init(reuseIdentifier: String, color: UIColor) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        dot = DotAnimation(frame: CGRect(x: initFrame.width/2, y: initFrame.height/2, width: initFrame.width, height: initFrame.height), color: blue1)
        dot.tag=100
        self.addSubview(dot)
        dot.addDotAnimation()
    }
    
    //MARK: Initialiser
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
    }

    
}
