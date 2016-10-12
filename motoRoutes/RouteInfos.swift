//
//  RouteLabes.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 16.08.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit

class RouteInfos: UIView {

    
    // MARK: Outlets
    //Date
    //@IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateRoute: UILabel!
    //Distance
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var legendeKM: UILabel!
    @IBOutlet weak var distanceRoute: UILabel!
    //Duration
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var legendeTime: UILabel!
    @IBOutlet weak var durationRoute: UILabel!
    //Average Speed
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var legendeKMH: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    //Highspeed
    @IBOutlet weak var highspeedLabel: UILabel!
    @IBOutlet weak var legendeKMH2: UILabel!
    @IBOutlet weak var highSpeed: UILabel!
    //Altitude Delta
    @IBOutlet weak var altitudeDeltaLabel: UILabel!
    @IBOutlet weak var legendeMeter: UILabel!
    @IBOutlet weak var altitudeDelta: UILabel!
    //Altitude Highest
    @IBOutlet weak var highestAltitudeLabel: UILabel!
    @IBOutlet weak var legendeMeter2: UILabel!
    @IBOutlet weak var highestAltitude: UILabel!
    
    
    // MARK: Location Strings
   // let dateLabelText = NSLocalizedString("View.RouteInfo.DateLabel", comment: "dateLabelText")
    let distanceLabelText = NSLocalizedString("View.RouteInfo.DistanceLabel", comment: "distanceLabelText")
    let durationLabelText = NSLocalizedString("View.RouteInfo.DuranceLabel", comment: "durationLabelText")
    let averageSpeedLabelText = NSLocalizedString("View.RouteInfo.AverageSpeedLabel", comment: "averageSpeedLabelText")
    let highspeedLabelText = NSLocalizedString("View.RouteInfo.HighSpeedLabel", comment: "highspeedLabelText")
    let altitudeDeltaLabelText = NSLocalizedString("View.RouteInfo.AltitudeDeltaLabel", comment: "altitudeDeltaLabelText")
    let highestAltitudeLabelText = NSLocalizedString("View.RouteInfo.HighestAltLabel", comment: "highestAltitudeLabelText")
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    
    // MARK: Setup Functions
    func setInfos(_ routeMaster: RouteMaster){
        
        dateRoute.text = routeMaster.routeDate
        distanceRoute.text = "\(utils.distanceFormat(routeMaster.routeDistance))"
        durationRoute.text = "\(utils.clockFormat(routeMaster.routeTime))"
        averageSpeed.text = routeMaster.routeAverageSpeed
        highSpeed.text = routeMaster.routeHighSpeed
        altitudeDelta.text = routeMaster.routeDeltaAlt
        highestAltitude.text = routeMaster.routeHighestAlt
    }
    
    
    func setupView(){
        
        self.layer.backgroundColor = UIColor.clear.cgColor
        
       // dateLabel.text = dateLabelText
        distanceLabel.text = distanceLabelText
        durationLabel.text = durationLabelText
        averageSpeedLabel.text = averageSpeedLabelText
        highspeedLabel.text = highspeedLabelText
        altitudeDeltaLabel.text = altitudeDeltaLabelText
        highestAltitudeLabel.text = highestAltitudeLabelText
    }

}
