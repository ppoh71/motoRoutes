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
    var myMotoRoutes: Results<Route>!
    var RouteMasters = [RouteMaster]()
    var myRoutes = [RouteMaster]()
    var myRouteMasters = [RouteMaster]()
    var markerViewResueIdentifier = ""
    var lastIndex = IndexPath(item: 0, section: 0)
    var activeIndex = IndexPath(item: 0, section: 0)
    var zoomOnSelect = true
    
    
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
        collection.allowsSelection = true
        
        let realm = try! Realm()
        myMotoRoutes = realm.objects(Route.self).sorted(byProperty: "timestamp", ascending: false)
        myRoutes = RouteMaster.realmResultToMasterArray(myMotoRoutes)
        
        self.view.backgroundColor = UIColor.black
        print(myMotoRoutes.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        print(userID ?? "no userid")
        
        var myRoutes = RouteMaster.realmResultToMasterArray(myMotoRoutes) // assign relam routes to masters
        
        //Listen from FlyoverRoutes if Markers are set
        NotificationCenter.default.addObserver(self, selector: #selector(exploreMotoRoutes.FIRRoutes), name: NSNotification.Name(rawValue: firbaseGetRoutesNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exploreMotoRoutes.FIRLocations), name: NSNotification.Name(rawValue: firbaseGetLocationsNotificationKey), object: nil)
        
        myRoutes = RouteMaster.realmResultToMasterArray(myMotoRoutes)
        setRouteMarkers(myRoutes, markerTitle: "myMarker")
        //FirebaseData.dataService.getRoutesFromFIR()
    }
    
    
    //MARK: Collection View Stuff
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myMotoRoutes.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(zoomOnSelect==true){
            mapUtils.flyToLoactionSimple(myRoutes[(indexPath as NSIndexPath).item].startLat, longitude: myRoutes[(indexPath as NSIndexPath).item].startLong, mapView: mapView, distance: 2000000, pitch: 0)
        }
        
        collection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
            print("++++++++++++++select \(indexPath)")
            
            
            cell.isSelected = true
            cell.toggleSelected()
            activeIndex = IndexPath(item: indexPath.item, section: 0)
            
        }
        
        zoomOnSelect = true // set back, false from mapview delegate select
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("################deselect \(indexPath)")
        
        let test = collectionView.cellForItem(at: indexPath)
        print(test ?? "no cell")
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
            print("### did really deselect \(indexPath)")
            cell.isSelected = false
            cell.toggleSelected()
        }
        collection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteCell", for: indexPath) as? RouteCell {
            
            print("---------------cell \(indexPath) cellactive \(activeIndex)")
            
            let route = myMotoRoutes[indexPath.row]
            var image = UIImage()
            let imgName = route.image
            
            if(imgName.characters.count > 0){
                let imgPath = utils.getDocumentsDirectory().appendingPathComponent(imgName)
                image = imageUtils.loadImageFromPath(imgPath as NSString)!
            }
            cell.configureCell("test", image: image)
            cell.toggleSelected()
            return cell
            
        } else{
            return UICollectionViewCell()
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180,height: 180)
    }
    
    
    
    func setRouteMarkers(_ myRoutes: [RouteMaster], markerTitle: String){
        for item in myRoutes {
            setMarker(item.startLat, longitude: item.startLong, id: item._MotoRoute.id, markerTitle: markerTitle)
        }
    }
    
    func setMarker(_ latitude: Double, longitude: Double, id: String, markerTitle: String){
        let newMarker = MGLPointAnnotation()
        newMarker.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        newMarker.title = markerTitle
        newMarker.subtitle = "\(id)"
        markerViewResueIdentifier = "\(id)"
        mapView.addAnnotation(newMarker)
    }
    
    
    //display Routes routes on map as Marker
    func FIRRoutes(_ notification: Notification){
        
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
    func FIRLocations(_ notification: Notification){
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            print("get notified FIR Locations ")
            for (key,item) in notifyObj.enumerated(){
                print(key)
                printAllMarker(FuncTypes.PrintCircles, _RouteMaster: item)
                activeRoute = item
            }
        }
    }
    
    
    func showActiveRoute(){
    }
    
    
    func printAllMarker(_ funcSwitch: FuncTypes, _RouteMaster: RouteMaster){
        
        self.funcType = funcSwitch
        //self.deleteAllMarker()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let tmpGap = 5
            print("image reuse size \(_RouteMaster._RouteList.count / tmpGap)")
            
            DispatchQueue.global().async {
                mapUtils.printMarker(_RouteMaster._RouteList, mapView: self.mapView, key: 0, amount: _RouteMaster._MotoRoute.locationsList.count-1 , gap: tmpGap, funcType: self.funcType )
                
            }
        }
    }
    
    
    func findRouteInRouteMasters(_ routes: [RouteMaster], key: String) -> (RouteMaster, Int){
        
        var _route = RouteMaster()
        var index = 0
        if let i = routes.index(where: {$0._MotoRoute.id == key}) {
            _route = routes[i]
            index = i
        }
        return (_route, index)
    }
    
    
    func deleteAllMarker(){
        //check this fileoprovate func removed
        if mapView.annotations!.count > 0{
            self.mapView.removeAnnotations(mapView.annotations!)
        }
    }
    
    
    @IBAction func addRoutetoRealm(_ sender: AnyObject) {
        print("active id \(activeRoute._MotoRoute.id)")
        RealmUtils.saveRouteFromFIR(activeRoute)
        collection.reloadData()
    }
    
    
}


// MARK: - MKMapViewDelegate
extension exploreMotoRoutes: MGLMapViewDelegate {
    
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var image: UIImage?
        let reuseIdentifier = "Marker-\(annotation.title!))"
        var dotColor: UIColor {
            return  annotation.title! == "allMarker" ? UIColor.yellow : UIColor.red
        }
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        
        if annotationImage == nil {
            image = imageUtils.dotColorMarker(15, height: 15, color: dotColor)
            annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: reuseIdentifier)
        }
        
        annotationImage?.isEnabled = true
        
        return annotationImage
    }
    
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
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
    
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
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
            
            collection.delegate?.collectionView!(collection, didDeselectItemAt: activeIndex)
            collection.selectItem(at: IndexPath(item: index, section: 0) , animated: true, scrollPosition: .centeredHorizontally)
            zoomOnSelect = false
            collection.delegate?.collectionView!(collection, didSelectItemAt: IndexPath(item: index, section: 0))
            activeIndex = IndexPath(item: index, section: 0)
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        //   print("regionDidChangeAnimated")
        
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        // print("region is chanhing")
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped
        return true
    }
}
