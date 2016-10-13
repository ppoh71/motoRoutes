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
    var myMotoRoutesRealm: Results<Route>!
    var myRoutesMaster = [RouteMaster]()
    var expRouteMasters = [RouteMaster]()
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
        myMotoRoutesRealm = realm.objects(Route.self).sorted(byProperty: "timestamp", ascending: false)
        myRoutesMaster = RouteMaster.realmResultToMasterArray(myMotoRoutesRealm)
        
        self.view.backgroundColor = UIColor.black
        print(myMotoRoutesRealm.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        print(userID ?? "no userid")
        
        //Listen from FlyoverRoutes if Markers are set
        NotificationCenter.default.addObserver(self, selector: #selector(exploreMotoRoutes.FIRRoutes), name: NSNotification.Name(rawValue: firbaseGetRoutesNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exploreMotoRoutes.FIRLocations), name: NSNotification.Name(rawValue: firbaseGetLocationsNotificationKey), object: nil)
        
        setRouteMarkers(myRoutesMaster, markerTitle: "myMarker")
        //FirebaseData.dataService.getRoutesFromFIR()
    }
    
    
    //MARK: Collection View Stuff
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myRoutesMaster.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(zoomOnSelect==true){
            mapUtils.flyToLoactionSimple(myRoutesMaster[(indexPath as NSIndexPath).item].startLat, longitude: myRoutesMaster[(indexPath as NSIndexPath).item].startLong, mapView: mapView, distance: 2000000, pitch: 0)
        }
        
        collection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
            // print("++++++++++++++select \(indexPath)")
            cell.isSelected = true
            cell.toggleSelected()
            activeIndex = IndexPath(item: indexPath.item, section: 0)
        }
        zoomOnSelect = true // set back, false from mapview delegate select
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
            print("### did really deselect \(indexPath)")
            cell.isSelected = false
            cell.toggleSelected()
        }
        collection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteCell", for: indexPath) as? RouteCell {
            cell.delegate = self
            let route = myRoutesMaster[indexPath.row]
            var image = UIImage()
            let routeId:String = route._MotoRoute.id
            let imgName = route._MotoRoute.image
            
            if(imgName.characters.count > 0){
                let imgPath = utils.getDocumentsDirectory().appendingPathComponent(imgName)
                image = imageUtils.loadImageFromPath(imgPath as NSString)!
            }
            
            cell.configureCell("test", id: routeId, image: image, index: indexPath.item)
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
            expRouteMasters = notifyObj
            
            setRouteMarkers(expRouteMasters, markerTitle: "allMarker")
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
    
    @IBAction func closeToExplore(_ segue:UIStoryboardSegue) {
        print("close mc \(segue.source)")
        segue.source.removeFromParentViewController()
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
            image = imageUtils.dotColorMarker(10, height: 10, color: dotColor)
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
     

     let reuseIdentifier = markerViewResueIdentifier
     
     var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)

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
        
        let index = findRouteInRouteMasters(myRoutesMaster, key: titleID!).1
        
        print(findRouteInRouteMasters(myRoutesMaster, key: titleID!).0)
        print(index)
        print(myRoutesMaster.count)
        
        if(index <= myRoutesMaster.count) {
            
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

extension exploreMotoRoutes: RouteCellDelegate{

    func pressedDetails(id: String, index: Int) {
        print("pressed Details id: \(id)")
               
        if let showRouteController = self.storyboard?.instantiateViewController(withIdentifier: "showRouteVC") as? showRouteController {
            print("got it")
            showRouteController.motoRoute = myRoutesMaster[index]._MotoRoute
            self.present(showRouteController, animated: true, completion: nil)
        }
    }
}
