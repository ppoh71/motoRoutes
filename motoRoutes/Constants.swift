//
//  Constants.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 16.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation


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