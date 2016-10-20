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

//Firebase Stuff
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

//CornerRadius
let cornerInfoViews = CGFloat(5)
