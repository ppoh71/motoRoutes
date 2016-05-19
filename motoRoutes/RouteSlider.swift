import UIKit

public class RouteSlider: UISlider {
    
    
    var labelDistance:UILabel!
    var labelTime:UILabel!
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var timeIcon: UIImage!
    var timeIconView: UIImageView!
    var distanceIcon: UIImage!
    var distanceIconView: UIImageView!
    var labelText: ()->String = { "" }

    required public init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        //define labels and
        labelDistance = UILabel()
        labelDistance.textColor = UIColor.whiteColor()
        labelDistance.font = UIFont(name: "Roboto", size: 13)
        
        labelTime = UILabel()
        labelTime.textColor = UIColor.whiteColor()
        labelTime.font = UIFont(name: "Roboto", size: 13)
        
        timeIcon = UIImage(named: "time-text")
        timeIconView = UIImageView(image: timeIcon!)

        distanceIcon = UIImage(named: "km-text")
        distanceIconView = UIImageView(image: distanceIcon!)
        
        
        //change Thumb Image
        let sliderTumb = imageUtils.drawSliderThumb(10, height: 25, lineWidth: 5, color: UIColor.whiteColor(), alpha: 1)
        
        self.setThumbImage( sliderTumb, forState: UIControlState.Normal )
        self.setThumbImage( sliderTumb, forState: UIControlState.Highlighted )

        
    }
    
    
    func setLabel(distanceText:String, timeText:String){
        
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
        
        
        //print("\(self.frame.width)")
        
        labelDistance.frame = CGRectMake(self.frame.origin.x+posX+offset+25 ,self.frame.origin.y - 22, 100, 25)
        distanceIconView.frame = CGRectMake(self.frame.origin.x+posX+offset ,self.frame.origin.y - 10, 25, 25)
        labelDistance.text = distanceText
        
        labelTime.frame = CGRectMake(self.frame.origin.x+posX+offset+25, self.frame.origin.y - 42, 100, 25)
        timeIconView.frame = CGRectMake(self.frame.origin.x+posX+offset ,self.frame.origin.y - 30, 25, 25)
        labelTime.text = timeText
     
        self.superview!.addSubview(labelTime)
        self.superview!.addSubview(labelDistance)
        self.superview!.addSubview(timeIconView)
        self.superview!.addSubview(distanceIconView)
        
    }
    
    
    
    public override func layoutSubviews() {

       // print("subviews")
        super.layoutSubviews()
        //super.layoutSubviews()
    }
    


}