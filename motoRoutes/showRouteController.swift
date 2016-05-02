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

class showRouteController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //Outlets
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var screenshotButton:UIButton!
    @IBOutlet var flyButton:UIButton!
    @IBOutlet var SpeedLabel:UILabel!
    @IBOutlet var DistanceLabel:UILabel!
    @IBOutlet var TimeLabel:UILabel!
    @IBOutlet var AltitudeLabel:UILabel!
    @IBOutlet var cameraSlider:UISlider!
    @IBOutlet var routeSlider:UISlider!
    @IBOutlet var routeImageView:UIImageView!
    @IBOutlet var AddMarker:UIButton!
    @IBOutlet var MinusMarker:UIButton!
    @IBOutlet var mapViewShow: MGLMapView!
    @IBOutlet var debugLabel: UILabel!
    
    @IBOutlet var amountPicker: UIPickerView!
    
    //add gesture
    var toggleImageViewGesture = UISwipeGestureRecognizer()

    // Get the default Realm
    let realm = try! Realm()
    
    // realm object list
    var motoRoute =  Route()
    var _LocationMaster = [LocationMaster]()
    
    //media stuff
    var markerImageName:String = ""
    
    //slider route value
    var sliderRouteValue = 0
    
    var sliceStart = 0
    var sliceAmount = 1
    var key = 0
    var cnt:Double = 0
    lazy var timer = NSTimer()
    var timeIntervalMarker = 0.1
    lazy var performanceTime:Double = 0
    
    //Debug Label
    var debugTimer = NSTimer()
    var debugSeconds = 0
    
    
    //Picker Stuff
    let pickerData = [
        ["1","2","3","4","5","8","10","25","50","80","100","150","250","500","750","1000","1250","1500","1800","2000","2500","3000","3500","4000","4500"],
        ["0.01", "0.02", "0.03", "0.04", "0.05", "0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1.0","1.1","1.2","1.3","1.5","2","3","4","5"],
        ["1","2","3","4","5","8","10","25","50","80"]
    ]
    
    
    
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        
        
        globalCamDistance.gCamDistance = Double(200*currentValue)
        globalCamDuration.gCamDuration = Double(currentValue/1000) + 0.2
//        globalArrayStep.gArrayStep = currentValue/10 > 1 ? currentValue/10 : 1
        globalCamPitch.gCamPitch = currentValue*2 < 80 ? CGFloat(60 ) : 60.0
        
        print("Slider Camera Position \(currentValue)")
        print("cam distance \(globalCamDistance.gCamDistance )")
        print("cam duration \(globalCamDuration.gCamDuration)")
        print("arraystep \(globalArrayStep.gArrayStep)")
        print("camPitch \(globalCamPitch.gCamPitch)")
        
    }
    
    
    //
    @IBAction func sliderRouteChanged(sender: UISlider) {
        sliderRouteValue = Int(sender.value)
        
        globalAutoplay.gAutoplay = false
        
        mapUtils.flyOverRoutes(_LocationMaster, mapView: mapViewShow, n: sliderRouteValue,  SpeedLabel: SpeedLabel, DistanceLabel: DistanceLabel, TimeLabel: TimeLabel, AltitudeLabel: AltitudeLabel, RouteSlider: routeSlider )
        
        print("Slider Route \(sliderRouteValue)")

        
    }
    
    @IBAction func addMarker(sender: UIButton) {
        
        print("Slice Amount \(sliceAmount)")
        
        //var key = self.sliceStart
        performanceTime = CFAbsoluteTimeGetCurrent()

         timer = NSTimer.scheduledTimerWithTimeInterval(timeIntervalMarker, target: self, selector: #selector(showRouteController.printIt), userInfo: nil, repeats: true)
        
        debugTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(showRouteController.updateDebugLabel), userInfo: nil, repeats: true)
        
    }
    
    
    func updateDebugLabel(){
    
        debugSeconds += 1
        debugLabel.text = "\(debugSeconds) / \(sliceStart)"
    
    
    }
    
    
    func printIt(){
    
        
        
        if( _LocationMaster.count > self.sliceStart+self.sliceAmount){
            
            mapUtils.printSpeedMarker(self._LocationMaster, mapView: self.mapViewShow,  key:  self.sliceStart, amount: self.sliceAmount)
            
            self.sliceStart += self.sliceAmount
            
            print("key: ")
            
        } else{
        
         print("All Marker took: \(utils.absolutePeromanceTime(performanceTime)) ")
         timer.invalidate()
         debugTimer.invalidate()
            
        }
    
    
    }
    
    
    @IBAction func stopMarker(sender: UIButton){
    
        timer.invalidate()
        debugTimer.invalidate()
  
    
    }
    
    
    @IBAction func removewMarker(sender: UIButton) {
        
        for annotation in mapViewShow.annotations!{
            
            print("\(annotation.title)")
            mapViewShow.removeAnnotation(annotation)
            
        }
        
        sliceStart = 0
        debugSeconds = 0
        timer.invalidate()
        debugTimer.invalidate()
    }
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //color speed label
        screenshotButton.tintColor = globalColor.gColor
        
        //set max on route slider
        routeSlider.maximumValue = Float(motoRoute.locationsList.count-1)
        
        
        //let x = CFAbsoluteTimeGetCurrent()
        //covert Realm LocationList to Location Master Object
        _LocationMaster = utils.masterRealmLocation(motoRoute.locationsList)
        //sliceAmount = _LocationMaster.count-1
        
        //print(utils.absolutePeromanceTime(x))
        print(_LocationMaster.count)
        
        //center mapview to route coords
        mapViewShow.zoomLevel = 9
        mapViewShow.camera.heading = 60


        
        mapViewShow.setCenterCoordinate(CLLocationCoordinate2D(latitude: _LocationMaster[0].latitude, longitude: _LocationMaster[0].longitude),  animated: false)
        
        // Toggle Camera recognizer
        toggleImageViewGesture.direction = .Right
        toggleImageViewGesture.addTarget(self, action: #selector(showRouteController.togglePhotoView))
        routeImageView.addGestureRecognizer(toggleImageViewGesture)
        routeImageView.userInteractionEnabled = true
        
        
        
        self.amountPicker.dataSource = self;
        self.amountPicker.delegate = self;
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        mapUtils.printRouteOneColor(_LocationMaster, mapView: mapViewShow)
        
        
       
        
        //mapUtils.cameraAni(utils.masterRealmLocation(motoRoute.locationsList), mapView: mapViewShow)
        
        //Media Objects
        //print("########MediaObjects \(motoRoute.mediaList)")
        
    }

    
    // new screenshot
    @IBAction func newScreenshot(sender: UIButton) {
        
        //make new screenshot from actual mapView
        let screenshotFilename = imageUtils.screenshotMap(mapViewShow)
        
        //save new screenshot to realm
        print(motoRoute)
        try! realm.write {
            realm.create(Route.self, value: ["id": motoRoute.id, "image": screenshotFilename], update: true)
            
        }
    }
    
    
    // new screenshot
    @IBAction func flyRoute(sender: UIButton) {
        
        
        //switch
        globalAutoplay.gAutoplay = globalAutoplay.gAutoplay==false ? true : false
        
        //make route fly
        print("let it fly")
        mapUtils.flyOverRoutes(_LocationMaster, mapView: mapViewShow, n: sliderRouteValue, SpeedLabel: SpeedLabel, DistanceLabel: DistanceLabel, TimeLabel: TimeLabel, AltitudeLabel: AltitudeLabel, RouteSlider: routeSlider)
        
        
        
    }
    
    
    func togglePhotoView(){
    
    
        let animateX:CGFloat = self.routeImageView.frame.origin.x<100 ? 320 : -320; //animnate x var
        print("x: \(self.routeImageView.frame.origin.x)")
    
        //aimate view
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.routeImageView.transform = CGAffineTransformMakeTranslation(animateX, 0)
            
            }, completion: nil)
    
        print("x: \(self.routeImageView.frame.origin.x)")
        
    }
    
    

    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(
        pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
        ) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(
        pickerView: UIPickerView,
        titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
         return pickerData[component][row]
    }
    
    func pickerView(
        pickerView: UIPickerView,
        didSelectRow row: Int,
                     inComponent component: Int)
    {
        
       if let sliceAmountPicker = Int(pickerData[0][amountPicker.selectedRowInComponent(0)]) {
        
            sliceAmount = Int(sliceAmountPicker)
            
        }
        
        if let timeIntervalPicker = Double(pickerData[1][amountPicker.selectedRowInComponent(1)]) {
            
            timeIntervalMarker = timeIntervalPicker
            
        }
        
        if let arrayStepPicker = Double(pickerData[2][amountPicker.selectedRowInComponent(2)]){
            
             globalArrayStep.gArrayStep = Int(arrayStepPicker)
        }
        
        print("amount: \(pickerData[0][amountPicker.selectedRowInComponent(0)])")
        print("time: \(pickerData[1][amountPicker.selectedRowInComponent(1)])")
    }

    
}




// MARK: - MKMapViewDelegate
extension showRouteController: MGLMapViewDelegate {
    
    
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        //Try to reuse the existing ‘pisa’ annotation image, if it exists
        //var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("Marker-Speed-\(utils.getSpeed(globalSpeed.gSpeed)).png")
        
        //if annotationImage == nil {
         
        let image = imageUtils.drawLineOnImage()
        //let  image = UIImage(named: "Marker-Speed-\(utils.getSpeed(globalSpeed.gSpeed)).png")!
        
        let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "routeline\(utils.getSpeed(globalSpeed.gSpeed))")

        //}
       
         return annotationImage
    }
    
    
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        
        print("annotation")
      //  print(" a \(annotation.subtitle!!)")
        if let imgNameAnnotation:String = annotation.subtitle!! {
            let imgPath = utils.getDocumentsDirectory().stringByAppendingPathComponent(imgNameAnnotation)
            let image = imageUtils.loadImageFromPath(imgPath)
        
            //show image
            routeImageView.image = image
            togglePhotoView()
        
            //deselect annotation
        mapView.deselectAnnotation(annotation, animated: false)
        }
        
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped
        return true
    }
    
    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 3.0
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        //let speedIndex =  Int(round(speed/10))
        return colorUtils.polylineColors(0)
    }
    
}