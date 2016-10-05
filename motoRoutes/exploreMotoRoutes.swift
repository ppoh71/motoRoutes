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


class exploreMotoRoutes: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var collection: UICollectionView!
    
    //MARK: my routes vars
    var RouteMasters = [RouteMaster]()
    var myMotoRoutes =  Results<Route>!(nil)
    
    
    //MARK: explore routes vars
    var activeRoute = RouteMaster()
    
    //MARK: vars
    var funcType = FuncTypes.Default
    var countReuse = 0
    
    
    //MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        
        let realm = try! Realm()
        myMotoRoutes = realm.objects(Route).sorted("timestamp", ascending: false)
        
        print(myMotoRoutes.count)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        print(userID)
        
        //Listen from FlyoverRoutes if Markers are set
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(exploreMotoRoutes.FIRRoutes), name: firbaseGetRoutesNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(exploreMotoRoutes.FIRLocations), name: firbaseGetLocationsNotificationKey, object: nil)
    }
    
    
    //MARK: Collection View Stuff
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myMotoRoutes.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RouteCell", forIndexPath: indexPath) as? RouteCell {
            
            let route = myMotoRoutes[indexPath.row]
            var image = UIImage()

            let imgName = route.image
            
            print("img name \(imgName)")
            
            if(imgName.characters.count > 0){
                let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgName)
                image = imageUtils.loadImageFromPath(imgPath)!
                print("img  \(image.size.width)x\(image.size.height)")
            }
            
            cell.configureCell("test", image: image)
            
            return cell
            
        } else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(180,180)
    }

    //display Routes routes on map as Marker
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
    
    
    //print route loaction marker for each route
    func FIRLocations(notification: NSNotification){
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            print("get notified FIR Locations ")
            for (key,item) in notifyObj.enumerate(){
                print(key)
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
                FirebaseData.dataService.geLocationsRouteFIR(refRouteMaster)
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