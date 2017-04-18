//
//  ViewController.swift
//  SimpleCamera
//
//  Created by Simon Ng on 25/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class motoRouteCamera: UIViewController {
    
    @IBOutlet weak var cameraButton:UIButton!
    @IBOutlet weak var cancelButton:UIButton!
    @IBOutlet weak var savedImage:UIImageView!
    
    //Capture Session
    let captureSession = AVCaptureSession()
    
    //camera devices
    var backFacingCamera:AVCaptureDevice?
    var frontFacingCamera:AVCaptureDevice?
    var currentDevice:AVCaptureDevice?
    
    //output
    var stillImageOutput:AVCaptureStillImageOutput?
    var stillImage:UIImage?

    //preview layer / input
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    //add gesture
    var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    
    //zoo, gesture
    var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
    
    // model store 
    var imageURL:String?
    var latitude:Double = 0
    var longitude:Double = 0
    var MediaObjects = [MediaMaster]()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        
        // Get the front and back-facing camera for taking photos
        for device in devices {
            if device.position == AVCaptureDevicePosition.back {
                backFacingCamera = device
            } else if device.position == AVCaptureDevicePosition.front {
                frontFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
            
            
            // Configure the session with the output for capturing still images
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            // Configure the session with the input and the output devices
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput)
            
            
        } catch {
            print(error)
        }
        
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        // Bring the camera button to front
        view.bringSubview(toFront: cameraButton)
        view.bringSubview(toFront: cancelButton)
        view.bringSubview(toFront: savedImage)
        
        captureSession.startRunning()
        
        
        // Toggle Camera recognizer
        toggleCameraGestureRecognizer.direction = .up
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(motoRouteCamera.toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        
        // Zoom In recognizer
        zoomInGestureRecognizer.direction = .right
        zoomInGestureRecognizer.addTarget(self, action: #selector(motoRouteCamera.zoomIn))
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // Zoom Out recognizer
        zoomOutGestureRecognizer.direction = .left
        zoomOutGestureRecognizer.addTarget(self, action: #selector(motoRouteCamera.zoomOut))
        view.addGestureRecognizer(zoomOutGestureRecognizer)
        
        print("latitude: \(latitude) / longitude: \(longitude) ")
        
    }
    
    
    /*
    *   toolge camera by swipe up
    */
    func toggleCamera() {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevicePosition.back) ? frontFacingCamera : backFacingCamera
        
        // Remove all inputs from the session
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    /*
    *   zooom in/put by swipe right/left
    */
    func zoomIn() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func zoomOut() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor > 1.0 {
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("memory warning from camera ")
    }
    

    
    @IBAction func capture(_ sender: AnyObject) {
       
        print("capture")
        
        let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo)
        stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            self.stillImage = UIImage(data: imageData!)
            self.savedImage.image = self.stillImage
            
            let timestampFilename = String(Int(Date().timeIntervalSince1970)) + "_routeimg.png"
            
           
            let filenamePath =  URL(fileReferenceLiteralResourceName: Utils.getDocumentsDirectory().appendingPathComponent(timestampFilename))
           // let imgData = try! imageData?.write(to: filenamePath, options: [])
            
            self.imageURL = String(describing: filenamePath) //assign for unwind seague
            
            print("capture done")
            
            
            //save to Media Object
            let tmpMediaObject = MediaMaster()
            
            tmpMediaObject.latitude = self.latitude
            tmpMediaObject.longitude = self.longitude
            tmpMediaObject.image = timestampFilename
            tmpMediaObject.timestamp = Date()

            
            self.MediaObjects.append(tmpMediaObject)
            
            
        })

       
        /** deubg testing on simulator **/
        //save to Media Object
        /*
        let tmpMediaObject = MediaMaster()
        
        tmpMediaObject.latitude = self.latitude
        tmpMediaObject.longitude = self.longitude
        tmpMediaObject.image = "1458236404.png"
        tmpMediaObject.timestamp = NSDate()
        
        self.MediaObjects.append(tmpMediaObject)

        print("########capture for simulator")
        */

    }
    
    
}

    
