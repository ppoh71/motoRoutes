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
    var myRoutes = [RouteMaster]()
    var myRouteMasters = [RouteMaster]()
    var markerViewResueIdentifier = ""
    var lastIndex = NSIndexPath(forItem: 0, inSection: 0)
    
    
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
        
        myRoutes = RouteMaster.realmResultToMasterArray(myMotoRoutes)
        print(myMotoRoutes.count)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        print(userID)
        
        //Listen from FlyoverRoutes if Markers are set
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(exploreMotoRoutes.FIRRoutes), name: firbaseGetRoutesNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(exploreMotoRoutes.FIRLocations), name: firbaseGetLocationsNotificationKey, object: nil)
        
        myRoutes = RouteMaster.realmResultToMasterArray(myMotoRoutes)
        setRouteMarkers(myRoutes, markerTitle: "myMarker")
       // FirebaseData.dataService.getRoutesFromFIR()
           }
    
    
    //MARK: Collection View Stuff
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myMotoRoutes.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
      
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? RouteCell {
              print("select")
              cell.contentView.backgroundColor = UIColor.redColor()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
         print("deselect")
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? RouteCell {
            cell.contentView.backgroundColor = UIColor.clearColor()
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RouteCell", forIndexPath: indexPath) as? RouteCell {
            
            let route = myMotoRoutes[indexPath.row]
            var image = UIImage()
            let imgName = route.image
            
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
    

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(180,180)
    }

    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
         print("You highlighted cell #\(indexPath.item)!")
         print("highlightes route \(myRoutes[indexPath.item].startLat)")
        
        mapUtils.flyToLoactionSimple(myRoutes[indexPath.item].startLat, longitude: myRoutes[indexPath.item].startLong, mapView: mapView, distance: 2000000, pitch: 0)
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAt indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        
        
    }
    
    
    func setRouteMarkers(myRoutes: [RouteMaster], markerTitle: String){
        for item in myRoutes {
            setMarker(item.startLat, longitude: item.startLong, id: item._MotoRoute.id, markerTitle: markerTitle)
        }
    }
    
    
    func setMarker(latitude: Double, longitude: Double, id: String, markerTitle: String){
        let newMarker = MGLPointAnnotation()
        newMarker.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        newMarker.title = markerTitle
        newMarker.subtitle = "\(id)"
        markerViewResueIdentifier = "\(id)"
        mapView.addAnnotation(newMarker)
    }
    
    
    //display Routes routes on map as Marker
    func FIRRoutes(notification: NSNotification){
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            RouteMasters = notifyObj
            
            setRouteMarkers(RouteMasters, markerTitle: "allMarker")
           // setRouteMarkerViews(RouteMasters, markerTitle: "allMarker")
            
//            for item in RouteMasters {
//                let newMarker = MGLPointAnnotation()
//                newMarker.coordinate = CLLocationCoordinate2DMake(item._MotoRoute.startLatitude, item._MotoRoute.startLongitude)
//                newMarker.title = "\(item._MotoRoute.id)"
//                mapView.addAnnotation(newMarker)
//            }
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
    
    
    func findRouteInRouteMasters(routes: [RouteMaster], key: String) -> (RouteMaster, Int){
        
        var _route = RouteMaster()
        var index = 0
        if let i = routes.indexOf({$0._MotoRoute.id == key}) {
            _route = routes[i]
            index = i
        }
        return (_route, index)
    }
    
    
    func deleteAllMarker(){
        if mapView.annotations?.count > 0{
            self.mapView.removeAnnotations(mapView.annotations!)
        }
    }

    
    @IBAction func addRoutetoRealm(sender: AnyObject) {
        print("active id \(activeRoute._MotoRoute.id)")
        RealmUtils.saveRouteFromFIR(activeRoute)
        collection.reloadData()
    }
    
    
}


// MARK: - MKMapViewDelegate
extension exploreMotoRoutes: MGLMapViewDelegate {
    
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var image: UIImage?
        let reuseIdentifier = "Marker-\(annotation.title!))"
        var dotColor: UIColor {
            return  annotation.title! == "allMarker" ? UIColor.yellowColor() : UIColor.redColor()
        }
    
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(reuseIdentifier)
        
        if annotationImage == nil {
            image = imageUtils.dotColorMarker(15, height: 15, color: dotColor)
            annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: reuseIdentifier)
        }
        
        annotationImage?.enabled = true
        
        return annotationImage
    }
    
    
    func mapView(mapView: MGLMapView, didSelectAnnotationView annotationView: MGLAnnotationView) {
        print("explore slect it")
    }
    
     /*
    // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        
       
        var dotColor: UIColor {
             if(annotation.title! == "myMarker") {
                return UIColor.redColor()
             } else {
                 return UIColor.blueColor()
            }
        }
        
        
        print("marker view")
//        guard annotation.title! == "SpeedAltMarkerView" else {
//            return nil
//        }
        
        let reuseIdentifier = markerViewResueIdentifier
        
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
        
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MarkerView(reuseIdentifier: reuseIdentifier, color: dotColor)
            
            annotationView!.frame = CGRectMake(0, 0, 10, 10)
            
        }

        return annotationView
    }
    */
    
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        
        print("did select \(annotation.title) \(annotation.subtitle) ")
        
       
        
        guard let titleID = annotation.subtitle else {
            print("guard exploreMotoRoutes didSelect")
            return
        }
        
        let index = findRouteInRouteMasters(myRoutes, key: titleID!).1
        
        print(findRouteInRouteMasters(myRoutes, key: titleID!).0)
        print(index)
        print(myRoutes.count)
        
        if(index <= myRoutes.count) {
          
           // let indexPath = collection.indexPathForItemAtPoint(CGPoint(x: index, y: 0))
           // if let cell2 = collection.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? RouteCell {
                collection.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0) , animated: true, scrollPosition: .CenteredHorizontally)
                
                if let lastcell = collection.cellForItemAtIndexPath(lastIndex) as? RouteCell {
                    lastcell.contentView.backgroundColor = UIColor.whiteColor()
                }
           
                if let cell = collection.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? RouteCell {
                  cell.contentView.backgroundColor = UIColor.redColor()
                }
            
                lastIndex = NSIndexPath(forItem: index, inSection: 0)
                print("yes")
            }
       // }
        /*
        if titleID != nil  {  
            print("Did Select Title not nil \(titleID)")
            let refRouteMaster = routeFromRouteMasters(RouteMasters, key: titleID!)
                FirebaseData.dataService.geLocationsRouteFIR(refRouteMaster)
            }
        */
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