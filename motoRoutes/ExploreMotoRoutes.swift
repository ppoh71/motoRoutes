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

class ExploreMotoRoutes: UIViewController {
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var collection: UICollectionView!
    
    //MARK: my routes vars
    var myMotoRoutesRealm: Results<Route>!
    var myRoutesMaster = [RouteMaster]()
    var markerViewResueIdentifier = ""
    var lastIndex = IndexPath(item: 0, section: 0)
    var activeIndex = IndexPath(item: 0, section: 0)
    var activeAnnotationView: MarkerView?
    var activeRouteCell: RouteCell?
    var activeRouteMaster = RouteMaster()
    var myRouteMarker = [MGLAnnotation]()
    var zoomOnSelect = true
    
    //MARK: explore routes vars
    var firebaseRouteMasters = [RouteMaster]()
    var activeFirebaseRoute = RouteMaster()
    var selectedMarkerView = [MGLAnnotation]()
    
    //MARK: vars
    var funcType = FuncTypes.Default
    var countReuse = 0
    
    
    //MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        collection.allowsSelection = true
        
        updateMyRouteMaster()
        self.view.backgroundColor = UIColor.black
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collection.reloadData() // [2]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        print(userID ?? "no userid")
        
        //Listen from FlyoverRoutes if Markers are set
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreMotoRoutes.FIRRoutes), name: NSNotification.Name(rawValue: firbaseGetRoutesNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreMotoRoutes.FIRLocations), name: NSNotification.Name(rawValue: firbaseGetLocationsNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreMotoRoutes.actionMenuConfirm), name: NSNotification.Name(rawValue: actionConfirmNotificationKey), object: nil)
        
        //FirebaseData.dataService.getRoutesFromFIR()
        setRouteMarkers(myRoutesMaster, markerTitle: "myMarker")
    }
    
    
    func updateMyRouteMaster(){
        let realm = try! Realm()
        myMotoRoutesRealm = realm.objects(Route.self).sorted(byProperty: "timestamp", ascending: false)
        myRoutesMaster = RouteMaster.realmResultToMasterArray(myMotoRoutesRealm)
        setRouteMarkers(myRoutesMaster, markerTitle: "myMarker")
    }
    
    
    //print route loaction marker for each route
    func actionMenuConfirm(_ notification: Notification){
        
        print("###ActionButton NotifY Explore")
        //get object from notification
        let notifyObj =  notification.object as! [AnyObject]
        
        if let actionType = notifyObj[0] as? ActionButtonType {
            
            switch(actionType) {
                
            case .Details:
                print("NOTFY: Clicked Details")
                gotoShowRoute(activeRouteMaster)
               
            case .ConfirmDelete:
                print("NOTFY: Confirm Delete")
                deleteRoute()
               
            case .ConfirmShare:
                print("NOTFY: Confirm Share")
                
            case .ConfirmDownload:
                print("NOTFY: Confirm Download")
                addRoutetoRealm(routeMaster: activeRouteMaster)
                
            default:
                print("default click")
                
            }
        }
    }
    
    
    //display Routes routes on map as Marker
    func FIRRoutes(_ notification: Notification){
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            firebaseRouteMasters = notifyObj
            
            setRouteMarkers(firebaseRouteMasters, markerTitle: "firebaseMarker")
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
       
        print("###got all loctions for fire_route")
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            activeAnnotationView?.setupAll(notifyObj[0])
        }
        /*
        if let notifyObj =  notification.object as? [RouteMaster] {
            print("get notified FIR Locations ")
            for (key,item) in notifyObj.enumerated(){
                print(key)
                printAllMarker(FuncTypes.PrintCircles, _RouteMaster: item)
                activeFirebaseRoute = item
            }
        }
        */
    }
    
    
    func showActiveRoute(){
    }
    
    
    func printAllMarker(_ funcSwitch: FuncTypes, _RouteMaster: RouteMaster){
        
        self.funcType = funcSwitch
        //self.deleteAllMarker()
        
       // DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let tmpGap = 20
         //   	("image reuse size \(_RouteMaster._RouteList.count / tmpGap)")
            
         //   DispatchQueue.global().async {
                MapUtils.printMarker(_RouteMaster._RouteList, mapView: self.mapView, key: 0, amount: _RouteMaster._MotoRoute.locationsList.count-1 , gap: tmpGap, funcType: self.funcType )
            //}
       // }
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
    
    
    func setRouteMarkers(_ routes: [RouteMaster], markerTitle: String){
        deleteMyRouteMarker()
        for item in routes {
            setMarker(item, markerTitle: markerTitle)
        }
    }
    
    
    func setMarker(_ routeMaster: RouteMaster, markerTitle: String){
        let newMarker = makeMarker(routeMaster, markerTitle: markerTitle)
        mapView.addAnnotation(newMarker)
        routeMaster._marker = newMarker
        
        if(markerTitle=="myMarker"){
            myRouteMarker.append(newMarker)
        }
    }

    
    func setViewMarker(_ routeMaster: RouteMaster, markerTitle: String){
        deleteSelectedMarkerView()
        let newMarker = makeMarker(routeMaster, markerTitle: markerTitle)
        mapView.addAnnotation(newMarker)
        selectedMarkerView.append(newMarker)
    }
    
    func makeMarker(_ routeMaster: RouteMaster, markerTitle: String) -> MGLPointAnnotation {
        let latitude = routeMaster.startLat
        let longitude = routeMaster.startLong
        let id = routeMaster._MotoRoute.id
        
        let newMarker = MGLPointAnnotation()
        newMarker.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        newMarker.title = markerTitle
        newMarker.subtitle = "\(id)"
        markerViewResueIdentifier = "\(id)"
        
        return newMarker
    }
    
    
    func deleteSelectedMarkerView(){
       // print("#### delete markerView\(selectedMarkerView)")
        for marker in selectedMarkerView{
           mapView.deselectAnnotation(marker, animated: true)
           mapView.removeAnnotation(marker)
        }
        selectedMarkerView = [MGLAnnotation]()
    }

    func deleteMyRouteMarker(){
        // print("#### delete markerView\(selectedMarkerView)")
        for marker in myRouteMarker{
            mapView.deselectAnnotation(marker, animated: true)
            mapView.removeAnnotation(marker)
        }
        myRouteMarker = [MGLAnnotation]()
    }

    /*
    func deleteSingleMarker(_ marker: MGLAnnotation){
        print("#####delete single marker \(marker)")
        //mapView.deselectAnnotation(marker, animated: true)
        mapView.removeAnnotation(marker)
    }*/
    
    
    func deleteAllMarker(){
        guard (mapView.annotations != nil) else {
            return
        }
        self.mapView.removeAnnotations(mapView.annotations!)
    }
    
    
    func gotoShowRoute(_ routeMaster: RouteMaster){
        if let showRouteController = self.storyboard?.instantiateViewController(withIdentifier: "showRouteVC") as? showRouteController {
            print("got it")
            showRouteController.motoRoute = routeMaster._MotoRoute
            self.present(showRouteController, animated: true, completion: nil)
        }
    }
    
    func addRoutetoRealm(routeMaster: RouteMaster){
        print("active id \(routeMaster._MotoRoute.id)")
        
        mapView.deselectAnnotation(routeMaster._marker, animated: false)
        mapView.removeAnnotation(routeMaster._marker)
        
        RealmUtils.saveRouteFromFIR(routeMaster)
        print("#### marker from delete \(routeMaster._marker)")
        
        reloadData()
    }
    
    
    func deleteRoute(){
        let realm = try! Realm()
        try! realm.write {
            
            deleteSelectedMarkerView()
            print("try delete \(activeRouteMaster) ")
            realm.delete(activeRouteMaster._MotoRoute)
            self.reloadData()
        }
    }
    
    
    func reloadData() {
        updateMyRouteMaster()
        collection.reloadData()
    }
    

    @IBAction func showFirRoutes(_ sender: AnyObject) {
        FirebaseData.dataService.getRoutesFromFIR()
    }
    
    
    @IBAction func showMyrRoutes(_ sender: AnyObject) {
        deleteAllMarker()
        updateMyRouteMaster()
    }
    
    
    @IBAction func closeToExplore(_ segue:UIStoryboardSegue) {
        print("close mc \(segue.source)")
        segue.source.removeFromParentViewController()
    }
}


//MARK: CollectionView Delegate Extension
extension ExploreMotoRoutes: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myRoutesMaster.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let latitude = myRoutesMaster[(indexPath as NSIndexPath).item].startLat
        let longitude = myRoutesMaster[(indexPath as NSIndexPath).item].startLong
        //let routeID = myRoutesMaster[(indexPath as NSIndexPath).item]._MotoRoute.id
        let routeMaster = myRoutesMaster[(indexPath as NSIndexPath).item]
        routeMaster.associateRouteListOnly()
        activeRouteMaster = routeMaster
        print("####selected marker \(activeRouteMaster._marker)")

        if(zoomOnSelect==true){
            MapUtils.flyToLoactionSimple(latitude, longitude: longitude, mapView: mapView, distance: 2000000, pitch: 0)
        }
       
        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
            cell.isSelected = true
            cell.toggleSelected()
            activeIndex = IndexPath(item: indexPath.item, section: 0)
        }
        
        collection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        setViewMarker(routeMaster, markerTitle: "MyRouteMarkerViewSelected")
        printAllMarker(.PrintMarker, _RouteMaster: routeMaster)
        zoomOnSelect = true // set back, false from mapview delegate select
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
           // print("### did really deselect \(indexPath)")
            cell.isSelected = false
            cell.toggleSelected()
        }
        collection.reloadData()
    }
    
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteCell", for: indexPath) as? RouteCell {
            //print("ROUTE CELL INIT deque")
            cell.delegate = self
            let route = myRoutesMaster[indexPath.row]
            var image = UIImage()
            let routeId:String = route._MotoRoute.id
            let imgName = route._MotoRoute.image
            
            if(imgName.characters.count > 0){
                let imgPath = Utils.getDocumentsDirectory().appendingPathComponent(imgName)
                image = ImageUtils.loadImageFromPath(imgPath as NSString)!
            }
            
            cell.configureCell("test", id: routeId, route: route, image: image, index: indexPath.item)
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
        return CGSize(width: 170, height: 170)
    }
}

// MARK: - MKMapViewDelegate
extension ExploreMotoRoutes: MGLMapViewDelegate {
    
   
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        guard let markerTitle = annotation.subtitle else {
            print("guard no tile")
            return nil
        }
        
        guard annotation.title!! != "MyRouteMarkerViewSelected" else {
            print("guard annotation no image for: MyRouteMarkerViewSelected")
            return nil
        }
        
        var image: UIImage?
        let reuseIdentifier = "Marker-\(annotation.title!))"
        var dotColor: UIColor {
            return  annotation.title! == "firebaseMarker" ? red1 : green3
        }
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        
        if annotationImage == nil {
            image = ImageUtils.dotColorMarker(10, height: 10, color: dotColor)
            annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: reuseIdentifier)
        }
        
        annotationImage?.isEnabled = true
        print("#### print image marker ")
        return annotationImage
    }
 
    /*
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        print("explore slect it")
    }
    */
    
    func mapView(_ mapView: MGLMapView, didAdd annotationViews: [MGLAnnotationView]) {
        print("")
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
       
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        guard let markerTitle = annotation.title else {
            return nil
        }

        guard (markerTitle == "MyRouteMarkerViewSelected") || (markerTitle == "FirebaseMarkerViewSelected") else {
            return nil
        }
        

        var viewType = MarkerViewType()
        
        switch markerTitle! {
            case "MyRouteMarkerViewSelected":
                viewType = .MyRoute
        
            case "FirebaseMarkerViewSelected":
                viewType = .FirRoute
          
            default:
                viewType = .MyRoute
        }
        
        
        let reuseIdentifier = markerViewResueIdentifier
        //print("resuse Identifier: \(markerViewResueIdentifier)")
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            let annotationMarkerView = MarkerView(reuseIdentifier: reuseIdentifier, routeMaster: activeRouteMaster, type: viewType)
            activeAnnotationView = annotationMarkerView
            return annotationMarkerView
        } else {
            return annotationView
        }
   }

    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        guard let titleID = annotation.subtitle else {
            print("guard exploreMotoRoutes didSelect")
            return
        }
 
        //deleteSelectedMarkerView()
        //selectedMarker = annotation as! MGLPointAnnotation

        print("##did select marker \(annotation) ")
        
        if(annotation.title! == "firebaseMarker"){
            let routeMaster = findRouteInRouteMasters(firebaseRouteMasters, key: titleID!).0
            if (!routeMaster._MotoRoute.id.isEmpty) {

            activeRouteMaster = routeMaster
            setViewMarker(routeMaster, markerTitle: "FirebaseMarkerViewSelected")
            
                //get locationsList for this Route from firebase
                if(routeMaster._MotoRoute.locationsList.count<1){
                        FirebaseData.dataService.geLocationsRouteFIR(routeMaster)
                } else{
                     activeAnnotationView?.setupAll(routeMaster)
                }
                
            }
            
        } else {
            let index = findRouteInRouteMasters(myRoutesMaster, key: titleID!).1
            if(index <= myRoutesMaster.count) {
                collection.delegate?.collectionView!(collection, didDeselectItemAt: activeIndex)
                collection.selectItem(at: IndexPath(item: index, section: 0) , animated: true, scrollPosition: .centeredHorizontally)
                zoomOnSelect = false
                collection.delegate?.collectionView!(collection, didSelectItemAt: IndexPath(item: index, section: 0))
                activeIndex = IndexPath(item: index, section: 0)
            }
        }
    }
    
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        //   print("regionDidChangeAnimated")
    }
    
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        // print("region is chanhing")
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
}

extension ExploreMotoRoutes: RouteCellDelegate{
    
    func pressedDetails(id: String, index: Int) {
        print("pressed Details id: \(id)")
         gotoShowRoute(activeRouteMaster)
            }
}
