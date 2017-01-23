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
    var activeRouteCell: RouteCell?
    var zoomOnSelect = true
    var timer = Timer()
    var timeIntervalMarker = 0.06
    var markerCount = 0
    
    //MARK: explore routes vars
    var firebaseRouteMasters = [RouteMaster]()
    var activeFirebaseRoute = RouteMaster()
    var selectedMarkerView = [MGLAnnotation]()
    var activeAnnotationView: MarkerView?
    var activeDotView = [MGLAnnotation]()
    var activeRouteMaster = RouteMaster()
    var myRouteMarker = [MGLAnnotation]()
    var routeLine = MGLPolyline()
    var speedMarker = [MGLAnnotation]()
    var markerGap = 1
    
    //MARK: vars
    var funcType = FuncTypes()
    var countReuse = 0
    var firbaseUser = ""
    
    @IBAction func addRoute(_ sender: Any) {
    }
    
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
        if((FIRAuth.auth()?.currentUser?.uid) != nil){
            firbaseUser = (FIRAuth.auth()?.currentUser?.uid)!
        }

        let motoMenu = MotoMenu(frame: CGRect(x: self.view.frame.width-130, y: 30, width: 50, height: 50))
        self.view.addSubview(motoMenu)
        
        //Listen from FlyoverRoutes if Markers are set
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreMotoRoutes.gotRoutesfromFirbase),
                                               name: NSNotification.Name(rawValue: firbaseGetRoutesNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreMotoRoutes.gotLocationsFromFirbase),
                                               name: NSNotification.Name(rawValue: firbaseGetLocationsNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreMotoRoutes.actionMenuConfirm),
                                               name: NSNotification.Name(rawValue: actionConfirmNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreMotoRoutes.geoCode),
                                               name: NSNotification.Name(rawValue: googleGeoCodeNotificationKey), object: nil)
        
        
        
        //FirebaseData.dataService.getRoutesFromFIR()
        setRouteMarkers(myRoutesMaster, markerTitle: "myMarker")
        //print("---------active routemaster \(activeRouteMaster._MotoRoute.id)")
        
        

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func geoCode(_ notification: Notification){
        let notifyObj =  notification.object as! [AnyObject]
        if let geoCode = notifyObj[0] as? String {
            print("got sddress from googe:\(geoCode)")
        }
    }
    
    func updateMyRouteMaster(){
        let realm = try! Realm()
        myMotoRoutesRealm = realm.objects(Route.self).sorted(byProperty: "timestamp", ascending: false)
        myRoutesMaster = RouteMaster.realmResultToMasterArray(myMotoRoutesRealm)
        setRouteMarkers(myRoutesMaster, markerTitle: "myMarker")
    }
    
    func actionMenuConfirm(_ notification: Notification){//marker view notification
        //print("###ActionButton NotifY Explore")
        let notifyObj =  notification.object as! [AnyObject]
        if let actionType = notifyObj[0] as? ActionButtonType {
            switch(actionType) {
                
            case .Details:
                //print("NOTFY: Clicked Details")
                gotoShowRoute(activeRouteMaster)
                
            case .ConfirmDelete:
                //print("NOTFY: Confirm Delete")
                deleteRoute()
                
            case .ConfirmDeleteFIR:
                //print("NOTFY: Confirm Delete FIR")
                FirebaseData.dataService.deleteFIRRouteData(id: self.activeRouteMaster._MotoRoute.id)
                
            case .ConfirmShare:
                //print("NOTFY: Confirm Share")
                FirebaseData.dataService.addRouteToFIR(self.activeRouteMaster, keychain: self.firbaseUser)
                
            case .ConfirmDownload:
                //print("NOTFY: Confirm Download")
                addRoutetoRealm(routeMaster: activeRouteMaster)
                
            case .CloseMarkerView:
                //print("Closer MarkerView \(activeRouteMaster)")
                deleteMarkers(&selectedMarkerView)
                
            default: break
                //print("default click")
            }
        }
    }
    
    func gotRoutesfromFirbase(_ notification: Notification){
        if let notifyObj =  notification.object as? [RouteMaster] {
            firebaseRouteMasters = notifyObj
            setRouteMarkers(firebaseRouteMasters, markerTitle: "firebaseMarker")
        }
    }
    
    func gotLocationsFromFirbase(_ notification: Notification){
        if let notifyObj =  notification.object as? [RouteMaster] {
            activeAnnotationView?.setupAll(notifyObj[0], menuType: MarkerViewType.FirRoute)
        }
    }
    
    func startMarkerTimer(){
        timer.invalidate()
        deleteMarkers(&speedMarker)
        markerCount = 0
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeIntervalMarker), target: self, selector: #selector(ExploreMotoRoutes.printSpeeMarker), userInfo: nil, repeats: true)
    }
    
    func printSpeeMarker(){
        markerCount = markerCount+markerGap
        funcType = .PrintCircles
        DispatchQueue.global(qos: .background).async {
            if(self.markerCount<self.activeRouteMaster._RouteList.count && self.activeRouteMaster._RouteList.count>0){
                let location = self.activeRouteMaster._RouteList[self.markerCount]
                MapUtils.newSingleMarker(self.mapView, location: location, speedMarker: &self.speedMarker)
            } else {
                self.timer.invalidate()
            }
        }
        DispatchQueue.main.async  { /*nothing in main queue */}
    }
    
    func printAllMarker(_ funcSwitch: FuncTypes, _RouteMaster: RouteMaster){
        self.funcType = funcSwitch
        self.deletRouteLine(routeLine)
        markerGap = MapUtils.calcMarkerGap(activeRouteMaster._RouteList, route: activeRouteMaster)
        self.startMarkerTimer()
        
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async  {
                self.routeLine = MapUtils.printRouteOneColor(_RouteMaster._RouteList, mapView: self.mapView )
                self.deleteMarkers(&self.activeDotView)
                let endMarker = MapUtils.getEndMarker(_RouteMaster._RouteList)
                self.mapView.addAnnotation(endMarker)
                self.activeDotView.append(endMarker)
            }
        }
    }
    
    func setRouteMarkers(_ routes: [RouteMaster], markerTitle: String){
        deleteMarkers(&myRouteMarker)
        for item in routes {
            setMarker(item, markerTitle: markerTitle)
        }
    }
    
    func setMarker(_ routeMaster: RouteMaster, markerTitle: String){
        let newMarker = MapUtils.makeMarker(routeMaster, markerTitle: markerTitle)
        mapView.addAnnotation(newMarker)
        routeMaster._marker = newMarker
        
        if(markerTitle=="myMarker"){
            myRouteMarker.append(newMarker)
        }
    }
    
    func setViewMarker(_ routeMaster: RouteMaster, markerTitle: String){
        deleteMarkers(&selectedMarkerView)
        let newMarker = MapUtils.makeMarker(routeMaster, markerTitle: markerTitle)
        mapView.addAnnotation(newMarker)
        selectedMarkerView.append(newMarker)
    }
    
    func deleteMarkers(_ markers:inout [MGLAnnotation]){
        for marker in markers{
            mapView.deselectAnnotation(marker, animated: true)
            mapView.removeAnnotation(marker)
        }
        markers = [MGLAnnotation]()
    }
    
    func deleteAllMarker(){
        guard (mapView.annotations != nil) else {
            return
        }
        self.mapView.removeAnnotations(mapView.annotations!)
    }
    
    func deletRouteLine(_ routeLine: MGLPolyline){
        self.mapView.removeAnnotation(routeLine)
    }
    
    func gotoShowRoute(_ routeMaster: RouteMaster){
        if let showRouteController = self.storyboard?.instantiateViewController(withIdentifier: "showRouteVC") as? showRouteController {
            //print("got it")
            showRouteController.motoRoute = routeMaster._MotoRoute
            self.present(showRouteController, animated: true, completion: nil)
        }
    }
    
    func addRoutetoRealm(routeMaster: RouteMaster){
        //print("active id \(routeMaster._MotoRoute.id)")
        removeAnnotation(routeMaster)
        RealmUtils.saveRouteFromFIR(routeMaster)
        NotificationCenter.default.post(name: Notification.Name(rawValue: progressDoneNotificationKey), object: [ProgressDoneType.ProgressDoneDownload])
        reloadData()
    }
    
    func deleteRoute(){
        let realm = try! Realm()
        try! realm.write {
            removeAnnotation(activeRouteMaster)
            //print("try delete \(activeRouteMaster._MotoRoute.id) ")
            realm.delete(activeRouteMaster._MotoRoute)
            self.reloadData()
            activeRouteMaster = RouteMaster()
            deleteMarkers(&self.activeDotView)
            deleteMarkers(&speedMarker)
            deletRouteLine(routeLine)
            NotificationCenter.default.post(name: Notification.Name(rawValue: progressDoneNotificationKey), object: [ProgressDoneType.ProgressDoneDelete])
        }
    }
    
    func removeAnnotation(_ routeMaster: RouteMaster){
        mapView.deselectAnnotation(routeMaster._marker, animated: false)
        mapView.removeAnnotation(routeMaster._marker)
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
        collection.reloadData()
    }
    
    @IBAction func closeToExplore(_ segue:UIStoryboardSegue) {
        //print("close mc \(segue.source)")
        segue.source.removeFromParentViewController()
        
        if segue.source is motoRoutes.showRouteController {
            collection.reloadData()
        }
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
        let routeMaster = myRoutesMaster[(indexPath as NSIndexPath).item]
        routeMaster.associateRouteListOnly()
        activeRouteMaster = routeMaster
        //print("####selected marker \(activeRouteMaster._marker)")
        
        if(zoomOnSelect==true){
            let bounds = MapUtils.getBoundCoords(activeRouteMaster._RouteList)
            let distance = bounds.distance*7
            //print("Bounds: \(bounds)")
            MapUtils.flyToLoactionSimple(latitude, longitude: longitude, mapView: mapView, distance: distance, pitch: 0)
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RouteCell {
            cell.isSelected = true
            cell.toggleSelected()
            activeIndex = IndexPath(item: indexPath.item, section: 0)
        }
        
        collection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        setViewMarker(routeMaster, markerTitle: "MyRouteMarkerViewSelected")
        printAllMarker(.PrintCircles, _RouteMaster: routeMaster)
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
            let label = route._MotoRoute.locationStart
            if(imgName.characters.count > 0){
                let imgPath = Utils.getDocumentsDirectory().appendingPathComponent(imgName)
                image = ImageUtils.loadImageFromPath(imgPath as NSString)!
            }
            print("###label: \(label)")
            cell.configureCell(label: label, datetime: route.routeDate, id: routeId, route: route, image: image, index: indexPath.item)
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
        var reuseIdentifier = ""
        var markerImage: UIImage?
        
        guard (annotation.subtitle) != nil else {
            print("guard no tile")
            return nil
        }
        
        guard annotation.title != nil else {
            print("gurad mapviw image no title")
            return nil
        }
        
        switch(self.funcType) {
        case .PrintMarker:
            reuseIdentifier = "MarkerSpeed\(Utils.getSpeed(globalSpeed.gSpeed))-1"
        case .PrintCircles:
            reuseIdentifier = "MarkerCircle\(Utils.getSpeed(globalSpeed.gSpeed))-5"
        case .PrintStartEnd:
            reuseIdentifier = "StartEndMarker"
        default:
            reuseIdentifier = "Marker-\(annotation.title))"
            break
        }
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        if annotationImage == nil {
            if (self.funcType == .Default){
                markerImage = ImageUtils.dotColorMarker(10, height: 10, color: UIColor.white, style: .CircleFullLine)
            } else{
                let color = ColorUtils.getColorSpeedGlobal()
                markerImage = ImageUtils.dotColorMarker(5, height: 5, color: color, style: .Circle)
            }
            annotationImage = MGLAnnotationImage(image: markerImage!, reuseIdentifier: reuseIdentifier)
        }
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, didAdd annotationViews: [MGLAnnotationView]) {
        //print("annotationViews")
    }
    
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        //print("mgl view annotation")
        
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        guard let markerTitle = annotation.title else {
            return nil
        }
        
        guard (markerTitle == "MyRouteMarkerViewSelected") || (markerTitle == "FirebaseMarkerViewSelected") || (markerTitle == "DotMarkerView") else {
            return nil
        }
        
        guard let reuseIdentifier = annotation.subtitle else {
            return nil
        }
        //print("Markertile: \(markerTitle)")
        var viewType = MarkerViewType()
        
        switch markerTitle! {
        case "MyRouteMarkerViewSelected":
            viewType = .MyRoute
        case "FirebaseMarkerViewSelected":
            viewType = .FirRoute
        case "DotMarkerView":
            viewType = .DotView
        default:
            viewType = .MyRoute
        }
        
        //print("resuse Identifier: \(markerViewResueIdentifier)")
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier!)
        
        if annotationView == nil {
            if viewType == .DotView{
                let dotMarkerView = MarkerViewDot(reuseIdentifier: reuseIdentifier!, color: UIColor.cyan)
                return dotMarkerView
            } else {
                let markerView = MarkerView(reuseIdentifier: reuseIdentifier!, routeMaster: activeRouteMaster, type: viewType)
                markerView.isEnabled = false
                activeAnnotationView = markerView
                return markerView
            }
            
        } else {
            return annotationView
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        //print("didDeselect")
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        //print("test 1")
        print(annotation)
        
        guard let titleID = annotation.subtitle else {
            print("guard exploreMotoRoutes didSelect")
            return
        }
        
        //print("test 2")
        //print("##did select marker \(annotation) \(activeRouteMaster._MotoRoute.id)")
        
        if(annotation.title! == "firebaseMarker" && annotation.subtitle! !=  activeRouteMaster._MotoRoute.id){
            //print("test 3")
            let routeMaster = RouteMaster.findRouteInRouteMasters(firebaseRouteMasters, key: titleID!).0
            if (!routeMaster._MotoRoute.id.isEmpty) {
                //print("test 4")
                activeRouteMaster = routeMaster
                setViewMarker(routeMaster, markerTitle: "FirebaseMarkerViewSelected")
                //print("test 5")
                //get locationsList for this Route from firebase
                if(routeMaster._MotoRoute.locationsList.count<1){
                    FirebaseData.dataService.geLocationsRouteFIR(routeMaster)
                } else{
                    activeAnnotationView?.setupAll(routeMaster, menuType: MarkerViewType.FirRoute)
                }
            }
        }
        
        if(annotation.title! != "firebaseMarker" && annotation.subtitle! !=  activeRouteMaster._MotoRoute.id){
            //print("do if else")
            //print("test 10")
            let index = RouteMaster.findRouteInRouteMasters(myRoutesMaster, key: titleID!).1
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
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        //print("tapOnCalloutFor")
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        //print("did select ANNOTATION VIEW")
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        // print("region is chanhing")
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        //print("annotationCanShowCallout")
        return false
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 2.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return blue1
    }
}

extension ExploreMotoRoutes: RouteCellDelegate{
    
    func pressedDetails(id: String, index: Int) {
        //print("pressed Details id: \(id)")
        gotoShowRoute(activeRouteMaster)
    }
}
