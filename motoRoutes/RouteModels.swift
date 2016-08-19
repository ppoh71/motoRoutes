//
//  realmLocation.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 28.01.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import RealmSwift
import Foundation
import CoreLocation
import Mapbox


//MARK: REALM Objects

// Route Realm Model
class Route: Object {
    
    dynamic var id = ""
    dynamic var name = ""
    dynamic var duration = 0
    dynamic var distance = 0.0
    dynamic var timestamp = NSDate()
    dynamic var image = ""
    dynamic var locationStart = ""
    dynamic var locationEnd = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    let locationsList = List<Location>()
    let mediaList = List<Media>()
    let gyroscopeList = List<Gyroscope>()
}


// Location Realm Data Model
class Location: Object {
    
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var course = 0.0
    dynamic var accuracy = 0.0
    dynamic var distance = 0.0
    dynamic var timestamp = NSDate()

    let route = LinkingObjects(fromType: Route.self, property: "locationsList")
}

//Media Object for location
class Media: Object {
    
    dynamic var image = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var course = 0.0
    dynamic var timestamp = NSDate()
    dynamic var accuracy = 0.0

    let route = LinkingObjects(fromType: Route.self, property: "mediaList")
}


//Gyroscope Object for location
class Gyroscope: Object {
    
    dynamic var timestamp = NSDate()
    let route = LinkingObjects(fromType: Route.self, property: "gyroscopeList")
}


//MARK: MASTER & LOCATION Objects


// Remodel data for as a kind of entity model, when it comes from realm  as singleton
class RouteMaster {
    
    static let sharedInstance = RouteMaster()
    var _MotoRoute = Route()
    var _RouteList = [LocationMaster]()
    
    var routeDate: String { get { return _MotoRoute.timestamp.customFormatted } }
    var routeTime: Int { get { return _MotoRoute.duration } }
    var routeDistance: Double{ get{ return _MotoRoute.distance } }
    var routeAverageSpeed: String { get { return getRouteSpeedAlt().0 }}
    var routeHighSpeed: String { get { return getRouteSpeedAlt().1 }}
    var routeDeltaAlt: String { get { return getRouteSpeedAlt().2 }}
    var routeHighestAlt: String { get { return getRouteSpeedAlt().3 }}
    var startLocation: String { get{ return _MotoRoute.locationStart} }
    var endLocation: String { get{ return _MotoRoute.locationEnd} }
    
    private init(){
        print(_MotoRoute)
    }
    
    //map realm route to this Class
    func associateRoute(motoRoute: Route){
        _MotoRoute = motoRoute
        createMasterLocationRealm(_MotoRoute.locationsList)
    }
    
    
    //create a LocationMaster Object with from Realm List
    private func createMasterLocationRealm(LocationsList:List<Location>!) {
        
        var newRouteList = RouteMaster()._RouteList
        
        //loop all CLLocation and create and append to LocationMaster
        for location in LocationsList {
            let locationTmp = LocationMaster(latitude: location.latitude, longitude: location.longitude, altitude: location.altitude, speed: location.speed, course: location.course, timestamp: location.timestamp, accuracy: location.accuracy, marker: false, distance: location.distance )
            newRouteList.append(locationTmp)
        }
        
        _RouteList = newRouteList
    }
    
    
    //create a LocationMaster Object with Location List
    class func createMasterFromCLLocation(LocationsList: [CLLocation]) -> [LocationMaster]{
        var newRouteList = RouteMaster()._RouteList
        
        //loop all CLLocation and create and append to LocationMaster
        for location in LocationsList {
            
            let locationTmp = LocationMaster(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude, speed: location.speed, course: location.course, timestamp: location.timestamp, accuracy: location.horizontalAccuracy, marker: false, distance: 0.0)
            newRouteList.append(locationTmp)
        }
        return newRouteList
    }
    
    
    
    //update the marker object, so we know that the speedmarker has been set
    class func updateMarkerBool(RouteList: [LocationMaster], n: Int){
        //the marker for this location has been set
        RouteList[n].marker = true
        
    }
    
    //get speede, alt, average and stuff
    private func getRouteSpeedAlt() -> (String, String, String, String) {
        
        var averageSpeed = 0.0
        var highestSpeed = 0.0
        var lowestAlt = 10000.0
        var highestAlt = 0.0
        
        guard _RouteList.count > 0 else{
            print("average speed guard, not enough loctaions")
            return ("no data", "no data", "no data", "no data" )
        }
        
        for item in _RouteList {
            averageSpeed += item.speed
            highestSpeed = item.speed > highestSpeed ? item.speed : highestSpeed
            lowestAlt = item.altitude < lowestAlt ? item.altitude : lowestAlt
            highestAlt = item.altitude > highestAlt ? item.altitude : highestAlt
        }
        
        return (averageSpeed: utils.getSpeedString(averageSpeed/Double(_RouteList.count)) ,highSpeed: utils.getSpeedString(highestSpeed), deltaAlt: utils.getDoubleString(highestAlt - lowestAlt), highestAlt: utils.getDoubleString(highestAlt))
    }
}

// Master Location Model for all Route Operations inside App
class LocationMaster {
    
    var latitude = 0.0
    var longitude = 0.0
    var altitude = 0.0
    var speed = 0.0
    var course = 0.0
    var timestamp = NSDate()
    var accuracy = 0.0
    var marker = false
    var distance = 0.0
    
    var annotation = MGLPointAnnotation()
    
    init(latitude:Double, longitude:Double, altitude:Double,speed:Double, course:Double,timestamp:NSDate, accuracy:Double, marker:Bool, distance:Double ){
        
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speed = speed
        self.course = course
        self.timestamp = timestamp
        self.accuracy = accuracy
        self.marker = marker
        self.distance = distance
    }
    
    init(){
    }
    
}


// Master Media Model for all Route functions
class MediaMaster {
    
    dynamic var image = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0
    dynamic var course = 0.0
    dynamic var timestamp = NSDate()
    dynamic var accuracy = 0.0
    
    init(){
    }
    
}


// Annotation Class for Marker Sztorage, Deletaion
class MarkerAnnotation {
    
    var annotaion: MGLPointAnnotation
    var key: Int
    
    init(annotaion: MGLPointAnnotation, key: Int){
        
        self.annotaion = annotaion
        self.key = key
    }
    
}


//MARK: REALM UTILS, Save

/**
 Save new route to realm
 
 - parameter locatiobRoute: [CLLocation] List with locations
 - parameter screenshotFilename: filename of screenshot
 - parameter startTimestamp: [starttime unix int
 - parameter distance: distance in m
 - parameter totalTime: total tine in seconds
 
 *
 */
class RealmUtils{
    
    class func saveRouteRealm(LocationsRoute:[CLLocation], MediaObjects: [MediaMaster], screenshotFilename:String, startTimestamp:Int, distance:Double, totalTime:Int ) -> String {
        
        // save to realm
        let newRoute = Route()
        let id = NSUUID().UUIDString
        
        newRoute.id = id
        newRoute.timestamp = NSDate()
        newRoute.distance = distance
        newRoute.duration = totalTime
        newRoute.image = screenshotFilename
        
        // distance calc
        var locationDistance = 0.0
        var lastLocation = LocationsRoute[0]
        
        //add Locations to Realm Objctes
        for location in LocationsRoute {
            
            
            //calc distance
            locationDistance += location.distanceFromLocation(lastLocation)
            lastLocation = location
            
            //print("locationdistance: \(locationDistance)" )
            
            let newLocation = Location()
            
            newLocation.timestamp = location.timestamp
            newLocation.latitude = location.coordinate.latitude
            newLocation.longitude = location.coordinate.longitude
            newLocation.altitude = location.altitude
            newLocation.speed = location.speed
            newLocation.course = location.course
            newLocation.accuracy = location.horizontalAccuracy
            newLocation.distance = locationDistance
            
            newRoute.locationsList.append(newLocation)
            
        }
        
        //add Media to Realm Objctes
        for media in MediaObjects {
            
            let newMedia = Media()
            
            newMedia.latitude = media.latitude
            newMedia.longitude  = media.longitude
            newMedia.timestamp  = media.timestamp
            newMedia.image = media.image
            
            newRoute.mediaList.append(newMedia)
        }
        
        
        // Get the default Realm
        let realm = try! Realm()
        // You only need to do this once (per thread)
        
        // Add to the Realm inside a transaction
        try! realm.write {
            realm.add(newRoute)
        }
        
        return id
    }
    
    
    class func getRealmByID(routeID: String) -> Results<Route>{
        
        let realm = try! Realm()
        let  currRoute = realm.objects(Route.self).filter("id = '\(routeID)' ")
        return currRoute
    }
    
    
    class func updateLocation2Realm(route: Route, location: String, field: String) {
    
        let realm = try! Realm()
        try! realm.write {
            
            switch(field){
            
                case "from":
                    route.locationStart = location
                
                case "to":
                    route.locationEnd = location
                
            default:
                break
                
            }
        }
    }
    
    
    
}//end Class




