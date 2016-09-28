//
//  exploreMotoRoutes.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 21.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import Mapbox
import Firebase
import CoreLocation
import Foundation
import RealmSwift


class exploreMotoRoutes: UIViewController {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    var RouteMasters = [RouteMaster]()
    var activeRoute = RouteMaster()
    var funcType = FuncTypes.Default
    var countReuse = 0
    
    override func viewDidAppear(animated: Bool) {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        print(userID)
        //Listen from FlyoverRoutes if Markers are set
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(exploreMotoRoutes.FIRRoutes), name: firbaseGetRoutesNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(exploreMotoRoutes.FIRLocations), name: firbaseGetLocationsNotificationKey, object: nil)
        
        DataService.dataService.getRoutesFromFIR()
        print("exokore data")
        
    }
    
    
    func FIRRoutes(notification: NSNotification){
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            
            RouteMasters = notifyObj
            
            for item in RouteMasters {
                let newMarker = MGLPointAnnotation()
                newMarker.coordinate = CLLocationCoordinate2DMake(item._MotoRoute.startLatitude, item._MotoRoute.startLongitude)
                newMarker.title = "\(item._MotoRoute.id)"
                mapView.addAnnotation(newMarker)
            }
        }
    }
    
    
    func FIRLocations(notification: NSNotification){
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            
            print("get notified FIR Locations ")
            
            for (key,item) in notifyObj.enumerate(){
                print(key)
                print(item)
                
                printAllMarker(FuncTypes.PrintCircles, _RouteMaster: item)
                activeRoute = item
            }
        }
    }
    
    
    func showActiveRoute(){
    }
    
    
    func printAllMarker(funcSwitch: FuncTypes, _RouteMaster: RouteMaster){
        
        self.funcType = funcSwitch
        //self.deleteAllMarker()
        
        let priority = Int(QOS_CLASS_UTILITY.rawValue)
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let tmpGap = 5
            print("image reuse size \(_RouteMaster._RouteList.count / tmpGap)")
            
            dispatch_async(dispatch_get_main_queue()) {
                mapUtils.printMarker(_RouteMaster._RouteList, mapView: self.mapView, key: 0, amount: _RouteMaster._MotoRoute.locationsList.count-1 , gap: tmpGap, funcType: self.funcType )

            }
        }
    }
    
    
    func routeFromRouteMasters(RouteMasters: [RouteMaster], key: String) -> RouteMaster{
        
        var _route = RouteMaster()
        if let i = RouteMasters.indexOf({$0._MotoRoute.id == key}) {
            _route = self.RouteMasters[i]
        }
        
        return _route
    }
    
    
    func deleteAllMarker(){
        
        if mapView.annotations?.count > 0{
            self.mapView.removeAnnotations(mapView.annotations!)
        }
        
        //Set marker bool to false, to print new marker
//        for marker in RouteList{
//            marker.marker = false
//        }
    }

    
    @IBAction func addRoutetoRealm(sender: AnyObject) {
        RealmUtils.saveRouteFromFIR(activeRoute)
    }
    
    
}


// MARK: - MKMapViewDelegate
extension exploreMotoRoutes: MGLMapViewDelegate {
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        var image: UIImage?
        var reuseIdentifier = ""
        
        //reuse identifier
        switch(self.funcType) {
            
        case .PrintMarker:
            reuseIdentifier =  "MarkerSpeed\(utils.getSpeed(globalSpeed.gSpeed))-1"
            
        case .PrintBaseHeight:
            reuseIdentifier =  "MarkerSpeedBase\(utils.getSpeed(globalSpeed.gSpeed))-2"
            
        case .PrintAltitude:
            reuseIdentifier =  "MarkerAlt\(Int(round(globalAltitude.gAltitude / 10 )))-3"
            
        case .Recording:
            reuseIdentifier =  "MarkerCircleSpeed\(utils.getSpeed(globalSpeed.gSpeed))-4"
            
            
        case .PrintCircles:
            reuseIdentifier =  "MarkerCircle\(utils.getSpeed(globalSpeed.gSpeed))-5"
            
        case .PrintStartEnd:
            reuseIdentifier = "StartEndMarker"
            
        default:
            print("marker image default break")
            break
        }
        
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(reuseIdentifier)
        
        if annotationImage == nil {
            
            countReuse+=1
            print("reuse count \(countReuse)")
            
            if(annotation.title! == "SpeedAltMarker"){
                image = imageUtils.drawLineOnImage(self.funcType)
                 annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: reuseIdentifier)
                
            } else{
                //image = UIImage(named: "ic_place.png")!
            }
            
        }
        
       annotationImage?.enabled = true
       
       return annotationImage
    }
    
    
    func mapView(mapView: MGLMapView, didSelectAnnotationView annotationView: MGLAnnotationView) {
        print("explore slect it")
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        
        print("did select")
        
        guard let titleID = annotation.title else {
            print("guard exploreMotoRoutes didSelect")
            return
        }
        
        if titleID != nil  {  
            print("Did Select Title not nil \(titleID)")
            let refRouteMaster = routeFromRouteMasters(RouteMasters, key: titleID!)
                DataService.dataService.geLocationsRouteFIR(refRouteMaster)
            }
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
     //   print("regionDidChangeAnimated")
        
    }
    
    func mapViewRegionIsChanging(mapView: MGLMapView) {
       // print("region is chanhing")
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped
        return true
    }
}