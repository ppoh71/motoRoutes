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



// Remodel data for as a entity master model
class RouteMaster {
    
    //static let sharedInstance = RouteMaster()
    var _MotoRoute = Route()
    var _RouteList = [LocationMaster]()
    
    var routeDate: String { get { return _MotoRoute.timestamp.customFormatted } }
    var routeTime: Int { get { return _MotoRoute.duration } }
    var routeDistance: Double{ get{ return _MotoRoute.distance } }
    var startLocation: String { get{ return _MotoRoute.locationStart} }
    var endLocation: String { get{ return _MotoRoute.locationEnd} }
    
    
    
    var routeAverageSpeed: String = ""
    var routeHighSpeed: String = ""
    var routeDeltaAlt: String = ""
    var routeHighestAlt: String = ""
    var routeListTimestamps: [NSDate] = [NSDate]()
    var routeListSpeeds: [Double] = [Double]()
    var routeListAltitudes: [Double] = [Double]()

    var cnt = 0
    
    init(){
        print(_MotoRoute)
    }
    
    //map realm route to this Class
    func associateRoute(motoRoute: Route){
        _MotoRoute = motoRoute
        createMasterLocationRealm(_MotoRoute.locationsList)
        setRouteListInfos()
    }
    
    func associateRouteFIR(){
        createMasterLocationRealm(_MotoRoute.locationsList)
        setRouteListInfos()
    }
    
    
    
    //create a LocationMaster Object with from Realm List
    func createMasterLocationRealm(LocationsList:List<Location>!) {
        
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
    
    //get speede, alt, average and stuff //  -> (String, String, String, String, [NSDate], [Double], [Double])
    private func setRouteListInfos() {
        
        cnt += 1
        
        var averageSpeed = 0.0
        var highestSpeed = 0.0
        var lowestAlt = 10000.0
        var highestAlt = 0.0
        var _routeListTimestamps = [NSDate]()
        var _routeListSpeeds = [Double]()
        var _routeListAltitudes = [Double]()
        
        guard _RouteList.count > 0 else{
            print("average speed guard, not enough loctaions")
           // return ("no data", "no data", "no data", "no data", routeListTimestamps, _routeListSpeeds, _routeListAltitudes)
            return
        }
        
        for item in _RouteList {
            averageSpeed += item.speed
            highestSpeed = item.speed > highestSpeed ? item.speed : highestSpeed
            lowestAlt = item.altitude < lowestAlt ? item.altitude : lowestAlt
            highestAlt = item.altitude > highestAlt ? item.altitude : highestAlt
            _routeListTimestamps.append(item.timestamp)
            _routeListSpeeds.append(Double(utils.getSpeedDouble(item.speed)))
           _routeListAltitudes.append(item.altitude)
        }
        
        routeAverageSpeed = utils.getSpeedString(averageSpeed/Double(_RouteList.count))
        routeHighSpeed = utils.getSpeedString(highestSpeed)
        routeDeltaAlt = utils.getDoubleString(highestAlt - lowestAlt)
        routeHighestAlt = utils.getDoubleString(highestAlt)
        routeListTimestamps = _routeListTimestamps
        routeListSpeeds = _routeListSpeeds
        routeListAltitudes = _routeListAltitudes
        
        //set global
        globalHighestAlt.gHighestAlt = highestAlt
        globalLowestAlt.gLowesttAlt = lowestAlt
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






