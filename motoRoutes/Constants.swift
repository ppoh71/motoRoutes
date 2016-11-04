//
//  Constants.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 16.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit


//Notification Center keys
let markerNotSetNotificationKey = "motoRoutes.MarkerNotSet"
let getLocationSetNotificationKey = "motoRoutes.getLocationString"
let chartSetNotificationKey = "motoRoutes.getKeyFromChart"
let firbaseGetRoutesNotificationKey = "motoRoutes.getRoutesFromFirebase"
let firbaseGetLocationsNotificationKey = "motoRoutes.getLocationsFromFirebase"
let googleGetImagesNotificationKey = "motoRoutes.getGoogleImages"
let actionButtonNotificationKey = "motoRoutes.actionButtons"
let actionConfirmNotificationKey = "motoRoutes.actionButtonsConfirm"




//API Keys
let KEY_UID = "uid"
let GOOGLE_API_KEY = "AIzaSyDBThDDItdOSfIFyB_yahNsXxhslMi34i0"
let GOOGLE_URL = "https://maps.googleapis.com/maps/api/streetview?size=600x300&location=46.414382,10.013988&heading=151.78&pitch=-0.76&key=AIzaSyDBThDDItdOSfIFyB_yahNsXxhslMi34i0"


//Color Definitions
let blue0 = ColorUtils.hexTorgbColor("#006499")
let blue1 = ColorUtils.hexTorgbColor("#006499")
let blue2 = ColorUtils.hexTorgbColor("#00527A")
let blue3 = ColorUtils.hexTorgbColor("#00405F")
let blue4 = ColorUtils.hexTorgbColor("#002C42")

let red1 = ColorUtils.hexTorgbColor("#F00C00")
let red2 = ColorUtils.hexTorgbColor("#C10A00")
let red3 = ColorUtils.hexTorgbColor("#960700")
let red4 = ColorUtils.hexTorgbColor("#680500")

let green1 = ColorUtils.hexTorgbColor("#00C000")
let green2 = ColorUtils.hexTorgbColor("#009B00")
let green3 = ColorUtils.hexTorgbColor("#007800")
let green4 = ColorUtils.hexTorgbColor("#005300")

let textColor = UIColor.white


//CornerRadius
let cornerInfoViews = CGFloat(5)


// Labels
let distanceLabelText = NSLocalizedString("View.RouteInfo.DistanceLabel", comment: "distanceLabelText")
let durationLabelText = NSLocalizedString("View.RouteInfo.DuranceLabel", comment: "durationLabelText")
let averageSpeedLabelText = NSLocalizedString("View.RouteInfo.AverageSpeedLabel", comment: "averageSpeedLabelText")
let highspeedLabelText = NSLocalizedString("View.RouteInfo.HighSpeedLabel", comment: "highspeedLabelText")
let altitudeDeltaLabelText = NSLocalizedString("View.RouteInfo.AltitudeDeltaLabel", comment: "altitudeDeltaLabelText")
let highestAltitudeLabelText = NSLocalizedString("View.RouteInfo.HighestAltLabel", comment: "highestAltitudeLabelText")

//ActionButtons
let actionButtonDetailsText = NSLocalizedString("ActionButton.details", comment: "Details")
let actionButtonDeleteRouteText = NSLocalizedString("ActionButton.deleteRoute", comment: "Delete Route")
let actionButtonShareRouteText = NSLocalizedString("ActionButton.shareRoute", comment: "Share Route")
let actionButtonDownloadRouteText = NSLocalizedString("ActionButton.downloadRoute", comment: "Download Route")
let actionButtonConfirmDeleteText =  NSLocalizedString("ActionButton.confirmDelete", comment: "Confirm Delete")
let actionButtonConfirmShareText =  NSLocalizedString("ActionButton.confirmShare", comment: "Confirm Share")
let actionButtonConfirmDownloadText =  NSLocalizedString("ActionButton.confirmDownload", comment: "Confirm Download")




//LabelTYpes
enum LabelType {
    case duration
    case altitude
    case speed
    
    var image: UIImage {
        switch self {
        case .duration: return UIImage(named: "durationIcon.png")!
        case .altitude: return UIImage(named: "altitudeIcon.png")!
        case .speed: return UIImage(named: "speedIcon.png")!
        }
    }
    
    var label: String{
        switch self {
        case .duration: return durationLabelText
        case .altitude: return highestAltitudeLabelText
        case .speed: return highspeedLabelText
        }
    }
}


//Action Button Types
enum ActionButtonType {
    case DefState
    case Details
    case DeleteRoute
    case ShareRoute
    case DownloadRoute
    case ConfirmDelete
    case ConfirmShare
    case ConfirmDownload
    case Cancel
    
    var buttonText: String {
        switch self {
        case .DefState: return "defState"
        case .Details: return actionButtonDetailsText
        case .DeleteRoute: return actionButtonDeleteRouteText
        case .ShareRoute: return actionButtonShareRouteText
        case .DownloadRoute: return actionButtonDownloadRouteText
        case .ConfirmDelete: return "OK"
        case .ConfirmShare: return "OK"
        case .ConfirmDownload : return "OK"
        case .Cancel: return "Cancel"
        }
    }
    
    var confirmText: String {
        switch self {
        case .DefState: return "defState Confirm"
        case .Details: return "show details"
        case .DeleteRoute: return actionButtonConfirmDeleteText
        case .ShareRoute: return actionButtonConfirmShareText
        case .DownloadRoute: return actionButtonConfirmDownloadText
        case .ConfirmDelete: return "---"
        case .ConfirmShare: return "--"
        case .ConfirmDownload: return "--"
        case .Cancel: return "---"
        }
    }
    
    var confirmAction: ActionButtonType{
        switch self {
        case .DefState: return ActionButtonType.DefState
        case .Details: return ActionButtonType.Details
        case .DeleteRoute: return ActionButtonType.ConfirmDelete
        case .ShareRoute: return ActionButtonType.ConfirmShare
        case .DownloadRoute: return ActionButtonType.DownloadRoute
        case .ConfirmDelete: return ActionButtonType.ConfirmDelete
        case .ConfirmShare: return ActionButtonType.ConfirmShare
        case .ConfirmDownload: return ActionButtonType.ConfirmDownload
        case .Cancel: return ActionButtonType.DefState
        }
    }
    
    
    init(){
        self = .DefState
    }
}


//Display different MarkerViewStates
enum MarkerViewType {

    case MyRoute
    case FirRoute
    
    init(){
        self = .MyRoute
    }
}


