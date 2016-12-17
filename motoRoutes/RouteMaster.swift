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
    var _marker = MGLPointAnnotation()
    
    var routeDate: String { get { return _MotoRoute.timestamp.customFormatted } }
    var routeTime: Int { get { return _MotoRoute.duration } }
    var routeDistance: Double{ get{ return _MotoRoute.distance } }
    var startLocation: String { get{ return _MotoRoute.locationStart} }
    var endLocation: String { get{ return _MotoRoute.locationEnd} }
    
    var routeAverageSpeed: String = ""
    var routeHighSpeed: String = ""
    var routeDeltaAlt: String = ""
    var routeHighestAlt: String = ""
    var routeListTimestamps: [Date] = [Date]()
    var routeListSpeeds: [Double] = [Double]()
    var routeListAltitudes: [Double] = [Double]()
    
    var textDuration: String { get { return "\(Utils.clockFormat(_MotoRoute.duration)) h:m" } }
    var textHighAlt: String { get { return "\(routeHighestAlt) m" } }
    var textHighSpeed: String { get { return "\(routeHighSpeed) km/h" } }
    
    var startLat: Double {
        if(_MotoRoute.startLatitude != 0){
            return _MotoRoute.startLatitude
        } else if (_RouteList.count > 0) {
            return _RouteList[0].latitude
        } else if (_MotoRoute.locationsList.count > 0) {
            return _MotoRoute.locationsList[0].latitude
        } else {
            return 0
        }
    }
    
    var startLong: Double {
        if(_MotoRoute.startLongitude != 0){
            return _MotoRoute.startLongitude
        } else if (_RouteList.count > 0) {
            return _RouteList[0].longitude
        } else if (_MotoRoute.locationsList.count > 0) {
            return _MotoRoute.locationsList[0].longitude
        } else {
            return 0
        }
    }

    var cnt = 0
    
    init(){
        print("init motoroute ()")
    }
    
    //map realm route
    func associateRoute(_ motoRoute: Route){
        _MotoRoute = motoRoute
        createMasterLocationRealm(_MotoRoute.locationsList)
        setRouteListInfos()
    }
    
    //map fir route 
    func associateRouteFIR(){
        createMasterLocationRealm(_MotoRoute.locationsList)
        setRouteListInfos()
    }
    
    func associateRouteOnly(_ motoRoute: Route){
        _MotoRoute = motoRoute
    }
    
    func associateRouteListOnly(){
        if(!_MotoRoute.id.isEmpty && self._RouteList.count==0){
            print("RouteMaster: associated RouteList only")
            createMasterLocationRealm(_MotoRoute.locationsList)
            setRouteListInfos()
        } else{
            print("RouteMaster: already associated")
        }
    }
    
    //create a LocationMaster Object with from Realm List
    func createMasterLocationRealm(_ LocationsList:List<Location>!) {
        
        var newRouteList = RouteMaster()._RouteList
        
        //loop all CLLocation and create and append to LocationMaster
        for location in LocationsList {
            let locationTmp = LocationMaster(latitude: location.latitude, longitude: location.longitude, altitude: location.altitude, speed: location.speed, course: location.course, timestamp: location.timestamp, accuracy: location.accuracy, marker: false, distance: location.distance )
            newRouteList.append(locationTmp)
        }
        
        _RouteList = newRouteList
    }
    
    
    //create a LocationMaster Object with Location List
    class func createMasterFromCLLocation(_ LocationsList: [CLLocation]) -> [LocationMaster]{
        var newRouteList = RouteMaster()._RouteList
        
        //loop all CLLocation and create and append to LocationMaster
        for location in LocationsList {
            
            let locationTmp = LocationMaster(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude, speed: location.speed, course: location.course, timestamp: location.timestamp, accuracy: location.horizontalAccuracy, marker: false, distance: 0.0)
            newRouteList.append(locationTmp)
        }
        return newRouteList
    }
    
    class func updateMarkerBool(_ RouteList: [LocationMaster], n: Int){
        //the marker for this location has been set
        RouteList[n].marker = true
    }
    
    //get speede, alt, average and stuff
    fileprivate func setRouteListInfos() {
        
        cnt += 1
        
        var averageSpeed = 0.0
        var highestSpeed = 0.0
        var lowestAlt = 10000.0
        var highestAlt = 0.0
        var _routeListTimestamps = [Date]()
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
            _routeListSpeeds.append(Double(Utils.getSpeedDouble(item.speed)))
           _routeListAltitudes.append(item.altitude)
        }
        
        routeAverageSpeed = Utils.getSpeedString(averageSpeed/Double(_RouteList.count))
        routeHighSpeed = Utils.getSpeedString(highestSpeed)
        routeDeltaAlt = Utils.getDoubleString(highestAlt - lowestAlt)
        routeHighestAlt = Utils.getDoubleString(highestAlt)
        routeListTimestamps = _routeListTimestamps
        routeListSpeeds = _routeListSpeeds
        routeListAltitudes = _routeListAltitudes
        
        //set global
        globalHighestAlt.gHighestAlt = highestAlt
        globalLowestAlt.gLowesttAlt = lowestAlt
        }
    
    
    class func realmResultToMasterArray(_ realm: Results<Route>)  -> [RouteMaster]{
        var master = [RouteMaster]()
        for item in realm{
            let newMaster = RouteMaster()
            newMaster.associateRouteOnly(item)
            master.append(newMaster)
        }
        return master
    }
    
    class func findRouteInRouteMasters(_ routes: [RouteMaster], key: String) -> (RouteMaster, Int){
        var _route = RouteMaster()
        var index = 0
        
        if let i = routes.index(where: {$0._MotoRoute.id == key}) {
            _route = routes[i]
            index = i
        }
        return (_route, index)
    }
}

// Master Location Model for all Route Operations inside App
class LocationMaster {
    
    var latitude = 0.0
    var longitude = 0.0
    var altitude = 0.0
    var speed = 0.0
    var course = 0.0
    var timestamp = Date()
    var accuracy = 0.0
    var marker = false
    var distance = 0.0
    
    var annotation = MGLPointAnnotation()
    
    init(latitude:Double, longitude:Double, altitude:Double,speed:Double, course:Double,timestamp:Date, accuracy:Double, marker:Bool, distance:Double ){
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
    dynamic var timestamp = Date()
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






