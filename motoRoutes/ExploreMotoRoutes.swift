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
        print(myMotoRoutesRealm.count)
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
        
        setRouteMarkers(myRoutesMaster, markerTitle: "myMarker")
        FirebaseData.dataService.getRoutesFromFIR()
    }
    
    
    func updateMyRouteMaster(){
        let realm = try! Realm()
        myMotoRoutesRealm = realm.objects(Route.self).sorted(byProperty: "timestamp", ascending: false)
        myRoutesMaster = RouteMaster.realmResultToMasterArray(myMotoRoutesRealm)
    }
    
    
    //print route loaction marker for each route
    func actionMenuConfirm(_ notification: Notification){
        
        //get object from notification
        let notifyObj =  notification.object as! [AnyObject]
        
        if let actionType = notifyObj[0] as? ActionButtonType {
            
            switch(actionType) {
                
            case .Details:
                print("NOTFY: Clicked Details")
                gotoShowRoute(activeIndex.item)
               
            case .ConfirmDelete:
                print("NOTFY: Confirm Delete")
                deleteRoute()
               
            case .ConfirmShare:
                print("NOTFY: Confirm Share")
                
            case .ConfirmDownload:
                print("NOTFY: Confirm Download")
               
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
        
        if let notifyObj =  notification.object as? [RouteMaster] {
            print("get notified FIR Locations ")
            for (key,item) in notifyObj.enumerated(){
                print(key)
                printAllMarker(FuncTypes.PrintCircles, _RouteMaster: item)
                activeFirebaseRoute = item
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
                MapUtils.printMarker(_RouteMaster._RouteList, mapView: self.mapView, key: 0, amount: _RouteMaster._MotoRoute.locationsList.count-1 , gap: tmpGap, funcType: self.funcType )
            }
        }
    }
    
    
    func findRouteInRouteMasters(_ routes: [RouteMaster], key: String) -> (RouteMaster, Int){
        
        var _route = RouteMaster()
        var index = 0
        print("test 2 \(routes.count) \(key)")
        
        for item in routes{
                print("test 3 \(item._MotoRoute.id)")
        }
        
        print("test 4")
        if let i = routes.index(where: {$0._MotoRoute.id == key}) {
            print("test 5")
            _route = routes[i]
            index = i
        }

        return (_route, index)
    }
    
    
    func setMarker(_ latitude: Double, longitude: Double, id: String, markerTitle: String){
        let newMarker = MGLPointAnnotation()
        newMarker.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        newMarker.title = markerTitle
        newMarker.subtitle = "\(id)"
        markerViewResueIdentifier = "\(id)"
        mapView.addAnnotation(newMarker)
        
        if(markerTitle == "SelectedRouteMarker"){
            selectedMarkerView.append(newMarker)
        }
    }
    
    
    func setRouteMarkers(_ myRoutes: [RouteMaster], markerTitle: String){
        for item in myRoutes {
            setMarker(item.startLat, longitude: item.startLong, id: item._MotoRoute.id, markerTitle: markerTitle)
        }
    }
    
    
    func deleteSelectedMarker(){
        for marker in selectedMarkerView{
           self.mapView.removeAnnotation(marker)
        }
    }
    
    
    func deleteAllMarker(){
        
        guard (mapView.annotations != nil) else {
            return
        }
        self.mapView.removeAnnotations(mapView.annotations!)
    }
    
    
    func gotoShowRoute(_ index: Int){
        if let showRouteController = self.storyboard?.instantiateViewController(withIdentifier: "showRouteVC") as? showRouteController {
            print("got it")
            showRouteController.motoRoute = myRoutesMaster[index]._MotoRoute
            self.present(showRouteController, animated: true, completion: nil)
        }
    }
    
    
    func deleteRoute(){
        
        let realm = try! Realm()
        try! realm.write {
            print("try delete \(myMotoRoutesRealm[activeIndex.item]) ")
            realm.delete(myMotoRoutesRealm[activeIndex.item])
            self.reloadData()
        }
       
    }
    
    func reloadData() {
        // TODO: retrieve data from the database
       // collection.reloadSections(NSIndexSet(index: 0) as IndexSet)
         updateMyRouteMaster()
        collection.reloadData()
    }
    
    func addRoutetoRealm(routeMaster: RouteMaster){
        print("active id \(routeMaster._MotoRoute.id)")
        RealmUtils.saveRouteFromFIR(routeMaster)
        reloadData()
    }
    
    /*
    @IBAction func addRoutetoRealm(_ sender: AnyObject) {
        print("active id \(activeRoute._MotoRoute.id)")
        RealmUtils.saveRouteFromFIR(activeRoute)
        collection.reloadData()
    }*/
    
    
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
        
        print("did Select")
        deleteSelectedMarker()
        
        let latitude = myRoutesMaster[(indexPath as NSIndexPath).item].startLat
        let longitude = myRoutesMaster[(indexPath as NSIndexPath).item].startLong
        let routeID = myRoutesMaster[(indexPath as NSIndexPath).item]._MotoRoute.id
        let routeMaster = myRoutesMaster[(indexPath as NSIndexPath).item]
        activeRouteMaster = routeMaster
        
        if(zoomOnSelect==true){
            MapUtils.flyToLoactionSimple(latitude, longitude: longitude, mapView: mapView, distance: 2000000, pitch: 0)
        }
       
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
            cell.isSelected = true
            cell.toggleSelected()
            activeIndex = IndexPath(item: indexPath.item, section: 0)
        }
        
        collection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        routeMaster.associateRouteListOnly()
        setMarker(latitude, longitude: longitude, id: routeID, markerTitle: "SelectedRouteMarker")
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
            print("ROUTE CELL INIT deque")
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
        
        guard annotation.title!! != "SelectedRouteMarker" else {
            print("guard annotation no image for: SelectedRouteMarker")
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
           // print("guard viewannottion: no pointannotation")
            return nil
        }
        
        guard let markerTitle = annotation.title else {
          //  print("guard annotationview no title")
            return nil
        }

        guard markerTitle == "SelectedRouteMarker" else {
          //  print("guard annotationview \(markerTitle)")
            return nil
        }
        
        let reuseIdentifier = markerViewResueIdentifier
        print(markerViewResueIdentifier)
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        var dotColor: UIColor { return  annotation.title! == "firebaseMarker" ? red1 : UIColor.yellow }
        
        if annotationView == nil {
            let annotationMarkerView = MarkerView(reuseIdentifier: reuseIdentifier, color: dotColor, routeMaster: activeRouteMaster)
            activeAnnotationView = annotationMarkerView
            return annotationMarkerView
        } else {
            return annotationView
        }
   }

    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        print("did select \(annotation.title) \(annotation.subtitle) ")
        
        guard let titleID = annotation.subtitle else {
            print("guard exploreMotoRoutes didSelect")
            return
        }
        
        //save to realm
        if(annotation.title! == "firebaseMarker"){
            print("test1")
            let routeMaster = findRouteInRouteMasters(firebaseRouteMasters, key: titleID!).0
            print("routeMaster: save \(routeMaster._MotoRoute.duration)")
            if (!routeMaster._MotoRoute.id.isEmpty) {
                addRoutetoRealm(routeMaster: routeMaster)
            }
            
        } else {
            let index = findRouteInRouteMasters(myRoutesMaster, key: titleID!).1
            
            print(findRouteInRouteMasters(myRoutesMaster, key: titleID!).0)
            
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
         gotoShowRoute(index)
            }
}
