//
//  RouteSlider
//  motoRoutes
//
//  Created by Peter Pohlmann on 12.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit


open class RouteSlider: UISlider {
    
    var labelDistance:UILabel!
    var labelTime:UILabel!
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var timeIcon: UIImage!
    var timeIconView: UIImageView!
    var distanceIcon: UIImage!
    var distanceIconView: UIImageView!
    var labelText: ()->String = { "" }

    
    //init
    required public init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        //define labels and stuff
        labelDistance = UILabel()
        labelDistance.textColor = UIColor.white
        labelDistance.font = UIFont(name: "Roboto", size: 13)
        
        labelTime = UILabel()
        labelTime.textColor = UIColor.white
        labelTime.font = UIFont(name: "Roboto", size: 13)
        
        timeIcon = LabelType.duration.image
        timeIconView = UIImageView(image: timeIcon!)

        distanceIcon = LabelType.duration.image
        distanceIconView = UIImageView(image: distanceIcon!)
        
        
        //change Thumb Image
        let sliderTumb = ImageUtils.drawSliderThumb(10, height: 25, lineWidth: 5, color: UIColor.white, alpha: 1)
        
        //change thumb image states
        self.setThumbImage( sliderTumb, for: UIControlState() )
        self.setThumbImage( sliderTumb, for: UIControlState.highlighted )

        
    }
    
    //set the labels
    func setLabel(_ distanceText:String, timeText:String){
        
        labelXMin = frame.origin.x + 0
        labelXMax = frame.origin.x + self.frame.width - 0
        
   
        /*
            let labelXOffset: CGFloat = labelXMax! - labelXMin!
            let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
            let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
            let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
            let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
            http://www.codeauthority.com/Blog/Entry/swift-ios-slider-control
        */
        
        let sizeX = self.frame.width
        var posX = (CGFloat(sizeX) * CGFloat(self.value)) / CGFloat(self.maximumValue)
        let offset = CGFloat(10)
        

        //move labels to the right, when in the middle of the slider, prevent to move it out of the screems
        if(posX > (self.frame.width/2)){
            posX = posX-80
        }
        
        labelDistance.frame = CGRect(x: self.frame.origin.x+posX+offset+25 ,y: self.frame.origin.y - 22, width: 100, height: 25)
        distanceIconView.frame = CGRect(x: self.frame.origin.x+posX+offset ,y: self.frame.origin.y - 10, width: 25, height: 25)
        labelDistance.text = distanceText
        
        labelTime.frame = CGRect(x: self.frame.origin.x+posX+offset+25, y: self.frame.origin.y - 42, width: 100, height: 25)
        timeIconView.frame = CGRect(x: self.frame.origin.x+posX+offset ,y: self.frame.origin.y - 30, width: 25, height: 25)
        labelTime.text = timeText
     
        //add stuff to subview
        self.superview!.addSubview(labelTime)
        self.superview!.addSubview(labelDistance)
        self.superview!.addSubview(timeIconView)
        self.superview!.addSubview(distanceIconView)
        
    }
    
    
    //not sure why we need this
    open override func layoutSubviews() {

       // print("subviews")
        super.layoutSubviews()
        //super.layoutSubviews()
    }
    


}
