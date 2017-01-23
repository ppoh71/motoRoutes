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
let googleGeoCodeNotificationKey = "motoRoutes.getGoogleGeoCode"
let actionButtonNotificationKey = "motoRoutes.actionButtons"
let actionConfirmNotificationKey = "motoRoutes.actionButtonsConfirm"
let progressDoneNotificationKey = "motoRoutes.actionProgressDone"
let completionFinishedNotificationKey = "motoRoutes.completionFinished"

//API Keys
let KEY_UID = "uid"
let GOOGLE_API_KEY = "AIzaSyDBThDDItdOSfIFyB_yahNsXxhslMi34i0"
let GOOGLE_URL = "https://maps.googleapis.com/maps/api/streetview?size=600x300&location=46.414382,10.013988&heading=151.78&pitch=-0.76&key=AIzaSyDBThDDItdOSfIFyB_yahNsXxhslMi34i0"

//Color Definitions
let blue0 = ColorUtils.hexTorgbColor("#07A6FB")
let blue1 = ColorUtils.hexTorgbColor("#006499")
let blue2 = ColorUtils.hexTorgbColor("#00527A")
let blue3 = ColorUtils.hexTorgbColor("#00405F")
let blue4 = ColorUtils.hexTorgbColor("#002736")

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

//Menu Stuff
let menuButtonWidth = 130;
let menuButtonHeight = 48;
let menuLabelPadding = 24;

//Info Labes and Buttons Sizes
let markerViewRect = CGRect(x: 0, y: 0, width: 150, height: 280)
let confirmViewRect = CGRect(x: 0, y: 0, width: 130, height: 280)
let viewPadding = 10
let actionLabelWidth = 130;
let actionLabelHeight = 48;
let actionLabelPadding = 12;
let buttonFont = UIFont(name: "Roboto-Bold", size: 14);
let menuFont = UIFont(name: "Roboto-Bold", size: 16);

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
let actionButtonDeleteRouteFIRText = NSLocalizedString("ActionButton.deleteRouteFIR", comment: "Delete Route FIR")
let actionButtonShareRouteText = NSLocalizedString("ActionButton.shareRoute", comment: "Share Route")
let actionButtonDownloadRouteText = NSLocalizedString("ActionButton.downloadRoute", comment: "Download Route")
let actionButtonConfirmDeleteText =  NSLocalizedString("ActionButton.confirmDelete", comment: "Confirm Delete")
let actionButtonConfirmDeleteFIRText =  NSLocalizedString("ActionButton.confirmDeleteFIR", comment: "Confirm Delete FIR")
let actionButtonConfirmShareText =  NSLocalizedString("ActionButton.confirmShare", comment: "Confirm Share")
let actionButtonConfirmDownloadText =  NSLocalizedString("ActionButton.confirmDownload", comment: "Confirm Download")
let actionButtonProgressShare = NSLocalizedString("ActionButton.progressShare", comment: "Progress Share")
let actionButtonProgressDelete = NSLocalizedString("ActionButton.progressDelete", comment: "Progress Delete")
let actionButtonProgressDeleteFIR = NSLocalizedString("ActionButton.progressDeleteFIR", comment: "Progress Delete FIR")
let actionButtonProgressDownload = NSLocalizedString("ActionButton.progressDownload", comment: "Progress Download")
let actionButtonProgressDone = NSLocalizedString("ActionButton.progressDone", comment: "Progress Done")
