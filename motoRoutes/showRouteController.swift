//
//  showRouteController.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 01.02.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import RealmSwift
import Mapbox
import Crashlytics
import pop
//import SwiftKeychainWrapper




class showRouteController: UIViewController {
    
    //MARK: Outles
    
    //Outlets
    @IBOutlet weak var  cancelButton:UIButton!
    @IBOutlet weak var  flyButton:UIButton!
    //@IBOutlet var SpeedLabel:UILabel!
    @IBOutlet weak var  DistanceLabel:UILabel!
    @IBOutlet weak var  TimeLabel:UILabel!
    @IBOutlet weak var  AltitudeLabel:UILabel!
    @IBOutlet weak var followCameraButton: UIButton!
    @IBOutlet weak var googleImage: UIImageView!
    
    @IBOutlet weak var  routeSlider:RouteSlider!{
        didSet{
            routeSlider.setLabel("0.000", timeText: "00:00")
        }
    }
    
    @IBOutlet weak var  routeImageView:UIImageView!
    @IBOutlet weak var  mapViewShow: MGLMapView!
    @IBOutlet weak var  debugLabel: UILabel!
    @IBOutlet weak var  optionsButton: UIButton!
    
    
    //MARK: Vars
    
    //add gesture
    var toggleImageViewGesture = UISwipeGestureRecognizer()
    
    // Get the default Realm
    let realm = try! Realm()
    
    // realm object list
    var motoRoute: Route?
    let _RouteMaster = RouteMaster()
    var RouteList = [LocationMaster]()
   // var markersSet = [MarkerAnnotation]()
    
    //media stuff
    var markerImageName:String = ""
    
    //slider route value
    var sliderRouteValue = 0
    var sliceStart = 0
    var sliceAmount = 1
    var key = 0
    var count:Int = 0
    var countGoogle:Int = 0
    var timer = Timer()
    var timeIntervalMarker = 0.01
    var performanceTime:Double = 0
    var tmpRoutePos = 0
    var followCamera = false
    
    //Debug Label
    var debugTimer = Timer()
    var debugSeconds = 0
    
    //init custom speedometer
    var speedoMeter = Speedometer()
    let speedoWidth:Int = 6
    var cameraCustomSlider = CameraSliderCustom()
    let frameSizeCameraSlider = 40 //extra space for slidethumb image
    
    //make screenshot
    var funcType = FuncTypes.Default
    var msgOverlay: MsgOverlay!
    var countReuse = 0
    
    //Custom Views
    var routeInfos: RouteInfos!
   // var chartSpeed: MotoChart!
   // var chartAlt: MotoChart!
    
    //Display Vars
    var screenSize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    
    //MARK: viewDidLoad, didAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let x = CFAbsoluteTimeGetCurrent()
        
        //Set screensize
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // MODEL: set max on route slider
        routeSlider.maximumValue = Float(motoRoute!.locationsList.count-1)
        
        //MODEL: covert Realm LocationList to Location Master Object
        _RouteMaster.associateRoute(motoRoute!)
        RouteList = _RouteMaster._RouteList
        
        //center mapview to route coords
        mapViewShow.zoomLevel = 9
        mapViewShow.camera.heading = globalHeading.gHeading
        mapViewShow.setCenter(CLLocationCoordinate2D(latitude: RouteList[0].latitude, longitude: RouteList[0].longitude),  animated: false)
        
        // Toggle Camera recognizer
        toggleImageViewGesture.direction = .right
        toggleImageViewGesture.addTarget(self, action: #selector(showRouteController.togglePhotoView))
        routeImageView.addGestureRecognizer(toggleImageViewGesture)
        routeImageView.isUserInteractionEnabled = true
        
        //slider drag end of route slider
        routeSlider.addTarget(self, action: #selector(showRouteController.touchUpRouteSlide), for: UIControlEvents.touchUpInside)
        routeSlider.addTarget(self, action: #selector(showRouteController.touchUpRouteSlide), for: UIControlEvents.touchUpOutside)
        routeSlider.addTarget(self, action: #selector(showRouteController.touchDowntRouteSlide), for: UIControlEvents.touchDown)
        
        //init RouteInfos
        routeInfos = Bundle.main.loadNibNamed("RouteInfos", owner: self, options: nil)?[0] as? RouteInfos
        routeInfos.setInfos(_RouteMaster)
        AnimationEngine.hideViewBottomLeft(routeInfos) //move view to bottom ad off screen to the left for now
        self.view.addSubview(routeInfos)
        
        //init Charts
        /*
        chartSpeed = Bundle.main.loadNibNamed("MotoChart", owner: self, options: nil)?[0] as? MotoChart
        chartSpeed.setupChart(_RouteMaster, type: "")
        AnimationEngine.hideViewBottomLeft(chartSpeed) //move view to bottom ad off screen to the left for now
        self.view.addSubview(chartSpeed)
        
        //init Charts Alt
        chartAlt = Bundle.main.loadNibNamed("MotoChart", owner: self, options: nil)?[0] as? MotoChart
        chartAlt.setupChart(_RouteMaster, type: "alt")
        AnimationEngine.hideViewBottomLeft(chartAlt) //move view to bottom ad off screen to the left for now
        self.view.addSubview(chartAlt)
         */
        cameraCustomSlider.addTarget(self, action: #selector(showRouteController.cameraSliderValueChanged), for: .valueChanged)
        setupCustomUI()
        hideAllBottomController()
        //showRouteInfos()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //write to firebase test
        
        //if let keychain =  KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID){
        // FirebaseData.dataService.addRouteToFIR(_RouteMaster, keychain: keychain)
        // print("MR: try to add to firebase")
        //} else{
        //    print("MR: not logged in")
        //}
 
        //Listen from FlyoverRoutes if Markers are set
        NotificationCenter.default.addObserver(self, selector: #selector(showRouteController.switchFromFly2PrintMarker), name: NSNotification.Name(rawValue: markerNotSetNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRouteController.saveLocationString), name: NSNotification.Name(rawValue: getLocationSetNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRouteController.keyFromChart), name: NSNotification.Name(rawValue: chartSetNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRouteController._GoogleImage), name: NSNotification.Name(rawValue: googleGetImagesNotificationKey), object: nil)
        
        //get locationString if emtpy and set start/end marker
        checkLocationStartEnd(motoRoute!)
        
        //print the route in 1 color
        mapUtils.printRouteOneColor(RouteList, mapView: mapViewShow)
        //printCricleRoute()
        
        //define camera and set it to startpoint
        let camera = mapUtils.cameraDestination(RouteList[0].latitude, longitude:RouteList[0].longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: RouteList[0].course + globalHeading.gHeading)
        
        mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        
    }
    
    
    func _GoogleImage(_ notification: Notification){
        
        if let notifyObj =  notification.object as? [UIImage] {
            for image in notifyObj{
              print("back from google \(image)")
              displayGoogleImage(image)
            }
        }
    }
    
    
    func getGoogleImageCache(_ id: String, key: Int){
    
        let imageFile = utils.getDocumentsDirectory().appendingPathComponent("/\(id)/\(key).jpeg")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imageFile) {
            print("GOOGLE IMAGE AVAILABLE )")
            
            let image = imageUtils.loadImageFromPath(imageFile as NSString)
            displayGoogleImage(image!)
            
        } else {
            print("LOAD IMAGE FROm GOOGLE")
            GoogleData.dataService.getGoogleImages(self._RouteMaster._RouteList[key].latitude, longitude: self._RouteMaster._RouteList[key].longitude, heading: self._RouteMaster._RouteList[key].course, id: id, key: key )
        }
    }
    
    
    func displayGoogleImage(_ image: UIImage){
        
         googleImage.image = image
       
    }
    
    
    
    //
    // view will disappear, stop everythink
    //
    override func viewWillDisappear(_ animated:Bool) {
        stopAll()
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    
    //int and setup custom controlls
    func setupCustomUI(){
        
        //init Speedometer
        let speedoHeight = screenHeight/2

        speedoMeter.frame = CGRect(x: (Int(screenWidth) - speedoWidth), y: 0, width: speedoWidth, height: Int(speedoHeight))
        speedoMeter.setup(speedoWidth, height: Int(speedoHeight))
        
        //init and setup custom camera slider
        let cameraCustomHeightMinus = CGFloat(60)
        cameraCustomSlider.frame = CGRect(x: (Int(screenWidth) - frameSizeCameraSlider), y: Int(screenHeight/2), width: frameSizeCameraSlider, height: Int(speedoHeight - cameraCustomHeightMinus))
        cameraCustomSlider.setup(speedoWidth, height: Int(speedoHeight - cameraCustomHeightMinus), frameWidth: frameSizeCameraSlider)
        
        //add Subviews
        view.addSubview(speedoMeter)
        view.addSubview(cameraCustomSlider)
        
        hidePlaybackViews() // hide after setup
    }
    
    
    
    //MARK: Show/Hide Bottom Controls
    
    //
    // Hide Playback Buttons & Slider
    //
    
    func hidePlaybackViews(){
        followCameraButton.isHidden = true
        flyButton.isHidden = true
        routeSlider.isHidden = true
        speedoMeter.isHidden = true
        cameraCustomSlider.isHidden = true
    }
    
    func showPlaybackViews(){
        followCameraButton.isHidden = false
        flyButton.isHidden = false
        routeSlider.isHidden = false
        speedoMeter.isHidden = false
        cameraCustomSlider.isHidden = false
    }

    func showRouteInfos(){
        AnimationEngine.showViewAnimCenterBottomPosition(routeInfos)
    }
    
    func hideRouteInfos(){
        AnimationEngine.hideViewBottomLeft(routeInfos)
    }
    
    func hideChartSpeed(){
      //  AnimationEngine.hideViewBottomLeft(chartSpeed)
    }
    
    func showChartSpeed(){
     //   AnimationEngine.showViewAnimCenterBottomPosition(chartSpeed)
    }
    
    func hideChartAlt(){
      //  AnimationEngine.hideViewBottomLeft(chartAlt)
    }
    
    func showChartAlt(){
      //  AnimationEngine.showViewAnimCenterBottomPosition(chartAlt)
    }
    
    func hideAllBottomController(){
        hideChartSpeed()
        hideRouteInfos()
        hidePlaybackViews()
        hideChartAlt()
    }
    
    
    //MARK: Stuff
    
    //  check if we have the locationStrings already
    func checkLocationStartEnd(_ route:Route){
    
        if(route.locationStart.isEmpty || route.locationEnd.isEmpty || route.locationStart == "Start Location" ) {
            
       //     let fromLocation = CLLocationCoordinate2D(latitude: route.locationsList[0].latitude, longitude:route.locationsList[0].longitude)
       //     let toLocation = CLLocationCoordinate2D(latitude: route.locationsList[route.locationsList.count-1].latitude, longitude: route.locationsList[route.locationsList.count-1].longitude)
            //assign async text to label
          //  GeocodeUtils.getAdressFromCoord(fromLocation, field: "to")
          //  GeocodeUtils.getAdressFromCoord(toLocation, field: "from")
            print("location is empty")
        
        } else{
            print("location not empty \(route.locationStart)")
            setStartEndMarker()
        }
    }
    
    
    // add start/end markers with locationString text
    func setStartEndMarker(){
        print("Add Start/End Marker")
        
        funcType = .PrintStartEnd
        
        let startMarker = MGLPointAnnotation()
        startMarker.coordinate = CLLocationCoordinate2DMake(self.RouteList[0].latitude, self.RouteList[0].longitude)
        startMarker.title = "motoRoute!.locationStart"
        startMarker.subtitle = motoRoute!.locationStart
        self.mapViewShow.addAnnotation(startMarker)
        
        let endMarker = MGLPointAnnotation()
        endMarker.coordinate = CLLocationCoordinate2DMake(self.RouteList[RouteList.count-1].latitude, self.RouteList[RouteList.count-1].longitude)
        endMarker.title = " motoRoute!.locationEnd"
        endMarker.subtitle = motoRoute!.locationEnd
        self.mapViewShow.addAnnotation(endMarker)
    }
    
    
    
    //MARK: Notification observer functions
    
    //save location string from geolocation(notification center to realm
    func saveLocationString(_ notification: Notification){
        
         print("from notifycation 1\(notification.object)")
        
        let arrayObject =  notification.object as! [AnyObject]
        
        if let address = arrayObject[0] as? String {
            if let field = arrayObject[1] as? String {
                RealmUtils.updateLocation2Realm(motoRoute!, location: address, field: field)
            }
            setStartEndMarker()
        }
    }
    
    //notifycenter func: get key from swipe on chart
    func keyFromChart(_ notification: Notification){
        
        print("Key from chart")
        let arrayObject =  notification.object as! [AnyObject]
        
        if let receivedKey = arrayObject[0] as? Int {
            flyToRouteKey(receivedKey)
        }
    }
    
    //notifycenter func: when no marker while flying over routesm switch to stop all and start marker printing
    func switchFromFly2PrintMarker(_ notification: Notification){
        
        //get object from notification
        let arrayObject =  notification.object as! [AnyObject]
        
        if let receivedKey = arrayObject[0] as? Int {
            
            //set new sliceStartKey
            sliceStart = receivedKey
            stopAll()
            StartStop(true)
        }
    }
    
    
    
    //MARK: Slider Stuff
    
    //custom camera value changed
    func cameraSliderValueChanged(){
        
        //print("current value target print")
        //print(cameraCustomSlider.currentValue)
        
        let currentValue = cameraCustomSlider.currentValue
        
        globalCamDistance.gCamDistance = Double(200*currentValue)
        //print( globalCamDistance.gCamDistance)
        globalCamDuration.gCamDuration = Double(currentValue/1000) + 0.2
        //globalArrayStep.gArrayStep = currentValue/10 > 1 ? currentValue/10 : 1
        globalCamPitch.gCamPitch = currentValue*2 < 80 ? CGFloat(60 ) : 60.0
        
        //zoom camera also when not flying,
        if( globalAutoplay.gAutoplay==false && flyButton.isSelected==false ) {
            
            //get current center coords
            let centerCoords = mapViewShow.centerCoordinate
            
            //define camera and flyTo with zoom level
            let camera = mapUtils.cameraDestination(centerCoords.latitude, longitude:centerCoords.longitude, fromDistance:globalCamDistance.gCamDistance, pitch: globalCamPitch.gCamPitch, heading: globalHeading.gHeading)
            mapViewShow.setCamera(camera, withDuration: globalCamDuration.gCamDuration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
            
            // print("\(mapViewShow.centerCoordinate)")
        }
    }
    

    
    func flyToRouteKey(_ key: Int){
    
        //googel Test
        globalRoutePos.gRoutePos = key
        
        getGoogleImageCache(_RouteMaster._MotoRoute.id, key: key)
        
        //routeSlider.setValues()
        //stop camera flightm when selecting new route point
        globalAutoplay.gAutoplay = false
        
        //fly to route to destination
        mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: globalRoutePos.gRoutePos, routeSlider: routeSlider, initInstance: utils.getUniqueUUID(), identifier: "i1", speedoMeter: speedoMeter)
    
    }
    
    
    //touch event for rourte slider
    func touchDowntRouteSlide(){
        stopAll()
    }
    
    //touch event for rourte slider
    func touchUpRouteSlide(){
    }
    
    
    

    //MARK: Start/Stop Print Marker  & Timer
    
    //start marker timer
    func startMarkerTimer(){
        timer = Timer.scheduledTimer(timeInterval: timeIntervalMarker, target: self, selector: #selector(showRouteController.printMarker), userInfo: nil, repeats: true)
    }
    
    //start debug timer
    func startDebugTimer(){
        debugTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showRouteController.updateDebugLabel), userInfo: nil, repeats: true)
    }
    
    //stop all running Timer flying cameras
    func stopAll(){
        timer.invalidate()
        debugTimer.invalidate()
        globalAutoplay.gAutoplay =  false
        flyButton.isSelected = false
    }

    
    //start auto fly over routes when marker are set
    func startFlytoAuto(){
        
        flyButton.isSelected = true
        globalAutoplay.gAutoplay =  true
        
        //make route fly
        mapUtils.flyOverRoutes(RouteList, mapView: mapViewShow, n: sliceStart, routeSlider: routeSlider, initInstance: utils.getUniqueUUID(), identifier: "i3", speedoMeter: speedoMeter)
        
    }
    
    
    //start/stop button function
    func StartStop(_ active: Bool){
        
        if (active){
            startMarkerTimer()
            startDebugTimer()
            flyButton.isSelected = true
            
        } else{
            stopAll()
        }
        
    }
    
    //update debug label
    func updateDebugLabel(){
        debugSeconds += 1
        debugLabel.text = "\(debugSeconds) / \(sliceStart) "
    }
    
    
    //MARK: Print Marker, Print All, Delete Marker
    
    //
    // printing speedmarker on the map
    //
    func printMarker(){
        
        //if not at end of array
        if( self.RouteList.count > globalRoutePos.gRoutePos+self.sliceAmount){
            
            //Print Marker if not already set
            if(self.RouteList[globalRoutePos.gRoutePos].marker==false){
            
                DispatchQueue.global(qos: .userInitiated).async {

                    
                    self.funcType = .PrintMarker
                    
                    let newMarker = MGLPointAnnotation()
                    newMarker.coordinate = CLLocationCoordinate2DMake(self.RouteList[globalRoutePos.gRoutePos].latitude, self.RouteList[globalRoutePos.gRoutePos].longitude)
                    newMarker.title = "SpeedAltMarker"
        
                    /* set globals */
                    globalSpeed.gSpeed = self.RouteList[globalRoutePos.gRoutePos].speed
                    globalAltitude.gAltitude = self.RouteList[globalRoutePos.gRoutePos].altitude
                    
                    self.mapViewShow.addAnnotation(newMarker)
                    
                    self.RouteList[globalRoutePos.gRoutePos].annotation = newMarker
                    self.RouteList[globalRoutePos.gRoutePos].marker = true
                    
                    // self.unsetMarker(&self.markersSet)
                    globalRoutePos.gRoutePos = globalRoutePos.gRoutePos + self.sliceAmount //move array to next route
                    self.tmpRoutePos = globalRoutePos.gRoutePos
                    
                    self.count+=1 //counter to center map, fly camer to marker
                    self.countGoogle+=1
                    //print("a: \(globalRoutePos.gRoutePos) - \(self.RouteList[globalRoutePos.gRoutePos].marker)")
                    
                    //delete marker trail
                    let delPos = 120
                    if((self.tmpRoutePos - delPos) > 0 && self.RouteList[self.tmpRoutePos-delPos].marker==true){
                        self.mapViewShow.removeAnnotation(self.RouteList[self.tmpRoutePos-delPos].annotation)
                        
                    }
                    
                   DispatchQueue.main.async  {
                        
                       // print("b: \(self.tmpRoutePos) - \(self.RouteList[globalRoutePos.gRoutePos].marker)")
                        
                        self.speedoMeter.moveSpeedo(Double(utils.getSpeed(self.RouteList[self.tmpRoutePos].speed)))
                        
                        self.routeSlider.setValue(Float(self.tmpRoutePos), animated: true)
                        //print("Slider Move \(n)")
                        self.routeSlider.setLabel((utils.distanceFormat(0)), timeText: "wtf")
                        
                        
                        
                        if(self.countGoogle > 10){
                            self.getGoogleImageCache(self._RouteMaster._MotoRoute.id, key: globalRoutePos.gRoutePos)
                            self.countGoogle = 0
                        }
                    
                        
                        if(self.count > 0 && self.followCamera == true){
                             mapUtils.flyOverRoutes(self.RouteList, mapView: self.mapViewShow, n: self.tmpRoutePos, routeSlider: nil, initInstance: utils.getUniqueUUID(), identifier: "i2", speedoMeter: nil)
                            self.count=0
                            //self.startMarkerTimer()
                        }
                    }

                    
                }
                
            }
            
        } else{ // end of array
            print("All Marker took: ")
            self.stopAll()
            //print(RouteList[0].marker)
        }
        
    }
    
    

    func printAllMarker(_ funcSwitch: FuncTypes){
        
        self.funcType = funcSwitch
        self.deleteAllMarker()
        
        DispatchQueue.global(qos: .background).async {
            
            let tmpGap = 5
            print("image reuse size \(self.RouteList.count / tmpGap)")
            
            DispatchQueue.main.async {
                mapUtils.printMarker(self.RouteList, mapView: self.mapViewShow, key: 0, amount: self.RouteList.count-1 , gap: tmpGap, funcType: self.funcType )
                self.setStartEndMarker()
            }
        }
    }
    
    
    func deleteAllMarker(){
        
        guard (mapViewShow.annotations != nil ) else{
            print("guard")
            return
        }
        
        self.mapViewShow.removeAnnotations(self.mapViewShow.annotations!)
        
        //Set marker bool to false, to print new marker
        for marker in RouteList{
            marker.marker = false
        }
    }
    
    
    //MARK: IB Actions Buttons
    
    // new screenshot
    @IBAction func flyRoute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        sender.isHighlighted = !sender.isHighlighted
        StartStop(sender.isSelected )
    }
    
    
    //Route Slider value changed
    @IBAction func sliderRouteChanged(_ sender: UISlider) {
        //get slider value as int
        let key = Int(sender.value)
        flyToRouteKey(key)
    }
    
    @IBAction func printAltitude(_ sender: AnyObject) {
        deleteAllMarker()
        printAllMarker(FuncTypes.PrintAltitude)
        self.centerMap(52, duration: 1)
        hideAllBottomController()
        showChartAlt()
    }
    
    @IBAction func printCircleMarker(_ sender: AnyObject) {
        deleteAllMarker()
        printAllMarker(FuncTypes.PrintCircles)
        self.centerMap(50, duration: 3)
        hidePlaybackViews()
        hideAllBottomController()
        showChartSpeed()
    }
    
    
    @IBAction func printSpeedMarker(_ sender: AnyObject) {
        deleteAllMarker()
        printAllMarker(FuncTypes.PrintMarker)
        self.centerMap(54, duration: 3)
        hideAllBottomController()
        showRouteInfos()
    }
    


    @IBAction func resetMarker(_ sender: AnyObject) {
        deleteAllMarker()
        mapUtils.printRouteOneColor(RouteList, mapView: mapViewShow)
        self.centerMap(50, duration: 3)
        hideAllBottomController()
        showPlaybackViews()
        print("playback show/hide")
    }
    
    
    @IBAction func printRoute(_ sender: AnyObject) {
        deleteAllMarker()
        mapUtils.printRoute(RouteList, mapView: mapViewShow)
        self.centerMap(53, duration: 3)
    }
    
    
    @IBAction func switchCameraFollow(_ sender: AnyObject) {
        
        if followCamera==false{
            followCamera=true
            followCameraButton.tintColor = UIColor.lightGray
        } else{
            followCamera=false
            followCameraButton.tintColor = UIColor.white
        }
    }
    
    
    // new screenshot
    @IBAction func newScreenshot(_ sender: UIButton) {
              
        let screenshotFilename = imageUtils.screenshotMap(self.mapViewShow)
        
        //save new screenshot to realm
        //print(motoRoute)
        try! self.realm.write {
            self.realm.create(Route.self, value: ["id": self.motoRoute!.id, "image": screenshotFilename], update: true)
            
        }
    }
    
    
    //MARK: Center Map
    func centerMap(_ pitch: CGFloat, duration: Double){
    
        //get bounds, centerpoints, of the whole Route
        let Bounds = mapUtils.getBoundCoords(RouteList)
        let coordArray = Bounds.coordboundArray
        //let coordBounds = Bounds.coordbound
        let distanceDiagonal = Bounds.distance
        let distanceFactor = Bounds.distanceFactor
    
        //get centerpoint
        let centerPoint = mapUtils.getCenterFromBoundig(coordArray)
        
        //define camera and set it to startpoint
        let camera = mapUtils.cameraDestination(centerPoint.latitude, longitude:centerPoint.longitude, fromDistance: distanceDiagonal*distanceFactor, pitch: pitch, heading: 0)
        
        //animate camera to center point, launch save overlay
        mapViewShow.setCamera(camera, withDuration: duration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {
    
        }
    }


    func togglePhotoView(){
        
        let animateX:CGFloat = self.routeImageView.frame.origin.x<100 ? 320 : -320; //animnate x var
        //print("x: \(self.routeImageView.frame.origin.x)")
        
        //aimate view
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.routeImageView.transform = CGAffineTransform(translationX: animateX, y: 0)
            
            }, completion: nil)
    }
    
    
    //MARK: SEGUE Stuff
    
    //
    // Prepare Segue / camera stuff
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        //prepare for camera/photo store to MediaObhect
        if segue.identifier == "showRouteOptions" {
            //  let destinationController = segue.destinationViewController as! motoRouteOptions
        }
        
        //unwind
        if segue.identifier == "unwindExitShowRoute" {
            //print("unwinding")
        }
    }
    
    
    @IBAction func unwindTo(_ unwindSegue: UIStoryboardSegue) {
        //print("unwind segue \(unwindSegue)")
    }
    
    
    @IBAction func close(_ segue:UIStoryboardSegue) {
        
        if let optionController = segue.source as? motoRouteOptions {
            sliceAmount = optionController.sliceAmount
            timeIntervalMarker = optionController.timeIntervalMarker
        }
    }
    
}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        //Try to reuse the existing ‘pisa’ annotation image, if it exists
        //var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("routeline\(utils.getSpeed(globalSpeed.gSpeed))")
        var image: UIImage
        
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
        
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        
        if annotationImage == nil {
            
            countReuse+=1
            print("reuse count \(countReuse)")
            
            if(annotation.title! == "SpeedAltMarker"){
                image = imageUtils.drawLineOnImage(self.funcType)
            } else{
                image = UIImage(named: "ic_place.png")!
            }
            
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
            
           //print("iamge is nil \(reuseIdentifier) \(globalSpeed.gSpeed) \(annotation.title!) \(self.funcType) \(image)")
        }
        
        
        return annotationImage

    }

    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        // print("regionDidChangeAnimated")
        
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        //print("region is chanhing")
    }
    
    
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        //print("region will change")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MGLMapView) {
        //print("mapViewWillStartLoadingMap")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MGLMapView, fullyRendered: Bool) {
        //print("mapViewDidFinishRenderingMap")
    }
    
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        //print("annotation")
        //  print(" a \(annotation.subtitle!!)")
        
        
        /*
         if let imgNameAnnotation:String = annotation.subtitle!! {
         let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgNameAnnotation)
         let image = imageUtils.loadImageFromPath(imgPath)
         
         //show image
         routeImageView.image = image
         togglePhotoView()
         
         //deselect annotation
         mapView.deselectAnnotation(annotation, animated: false)
         }
         */
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped
        return true
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 3.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        //let speedIndex =  Int(round(speed/10))
        //print(globalSpeedSet.speedSet)
        return colorUtils.polylineColors(globalSpeedSet.speedSet)
    }
    
}

extension showRouteController: msgOverlayDelegate{
    
    func pressedResume() {
        print("pressed resume")
        AnimationEngine.hideViewAnim(msgOverlay)
        
    }
    
    func pressedSave(){
        print("pressed save")
        printAllMarker(FuncTypes.PrintMarker)
        //msgOverlay.saveButton.backgroundColor = colorUtils.randomColor()
    }
}
