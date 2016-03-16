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
    
    
    
    @IBOutlet weak var cameraButton:UIButton!
    @IBOutlet weak var cancelButton:UIButton!
    @IBOutlet weak var savedImage:UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        
        // Get the front and back-facing camera for taking photos
        for device in devices {
            if device.position == AVCaptureDevicePosition.Back {
                backFacingCamera = device
            } else if device.position == AVCaptureDevicePosition.Front {
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
        view.bringSubviewToFront(cameraButton)
        view.bringSubviewToFront(cancelButton)
        view.bringSubviewToFront(savedImage)
        
        captureSession.startRunning()
        
        
        // Toggle Camera recognizer
        toggleCameraGestureRecognizer.direction = .Up
        toggleCameraGestureRecognizer.addTarget(self, action: "toggleCamera")
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        
        // Zoom In recognizer
        zoomInGestureRecognizer.direction = .Right
        zoomInGestureRecognizer.addTarget(self, action: "zoomIn")
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // Zoom Out recognizer
        zoomOutGestureRecognizer.direction = .Left
        zoomOutGestureRecognizer.addTarget(self, action: "zoomOut")
        view.addGestureRecognizer(zoomOutGestureRecognizer)
        
    }
    
    
    /*
    *   toolge camera by swipe up
    */
    func toggleCamera() {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevicePosition.Back) ? frontFacingCamera : backFacingCamera
        
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
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
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
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
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
    

    
    @IBAction func capture(sender: AnyObject) {
       
        print("capture")
        
        let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
        stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            self.stillImage = UIImage(data: imageData)
            self.savedImage.image = self.stillImage
            
            var filenamePath:String = ""
            let timestampFilename = String(Int(NSDate().timeIntervalSince1970)) + "_routeimg.png"
            
            
            filenamePath = utils.getDocumentsDirectory().stringByAppendingPathComponent(timestampFilename)
            imageData.writeToFile(filenamePath, atomically: true)

            
             print("capture done")
        })

        
            //screenShotRoute.image = screenShot
            
           //if let data = UIImageJPEGRepresentation(self.stillImage!, 80) {
           
             print("capture save")
                
        
                 print("capture save done")
            
                /*
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(NSURL(fileURLWithPath: filenamePath))
                    }) { completed, error in
                        if completed {
                            print("Image is saved!")
                            print(timestampFilename)
                        }
                }
                */
                
                //  UIImageWriteToSavedPhotosAlbum(imageToSave, self, "image:didFinishSavingWithError:contextInfo:", nil)
                //ismissViewControllerAnimated(true, completion: nil)
          //  }
            

    }
    
        
}

    