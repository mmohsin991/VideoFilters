//
//  THCameraController.swift
//  VideoFilters
//
//  Created by Mohsin on 25/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


//let const : THThumbnailCreatedNotification?
var THCameraAdjustingExposureContext : NSString = "THCameraAdjustingExposureContext"




// page no 180
protocol THCameraControllerDelegate {
    func deviceConfigurationFailedWithError(error : NSError?)
    func mediaCaptureFailedWithError(error : NSError?)
    func assetLibraryWriteFailedWithError(error : NSError?)
}




// page no 180
class THCameraController: NSObject {
    
    var delegate : THCameraControllerDelegate!
    var captureSession: AVCaptureSession!
    
    
    // Camera Device Support
    
    //    var cameraCount : NSUInteger! pg 187
    var cameraCount : Int!{
        get{
           return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count
        }
    }
    // pg 187    //    - (BOOL)canSwitchCameras;
    var canSwitchCameras : Bool{
        get{
            return self.cameraCount > 1
        }
    }
    // pg 187
    var activeCamera : AVCaptureDevice{
        get{
            return self.activeVideoInput.device
        }
    }
    // pg 187
    var inactiveCamera : AVCaptureDevice?{
        var device : AVCaptureDevice?
        
        if self.cameraCount > 1{
            if self.activeCamera.position == AVCaptureDevicePosition.Back{
                device = self.cameraWithPosition(AVCaptureDevicePosition.Front)
            }
            else{
                device = self.cameraWithPosition(AVCaptureDevicePosition.Front)
            }
        }
        
        return device
    }

    var cameraHasTorch : Bool!
    var cameraHasFlash : Bool!
    var cameraSupportsTapToFocus : Bool!{
        get{
            return self.activeCamera.focusPointOfInterestSupported
        }
    }
    var cameraSupportsTapToExpose : Bool!{
        get{
            return self.activeCamera.exposurePointOfInterestSupported
        }
    }
    var torchMode : AVCaptureTorchMode!
    var flashMode : AVCaptureFlashMode!
    
    // page 181
    var videoQueue : dispatch_queue_t!
    var activeVideoInput : AVCaptureDeviceInput!
    
    // output
    var imageOutput : AVCaptureStillImageOutput!
    var movieOutput : AVCaptureMovieFileOutput!
    var outputURL : NSURL!
    
    
    
    
    // Session Configuration
    //    - (BOOL)setupSession:(NSError **)error;
    func setupSession(inout error : NSError?) -> Bool{
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Set up default camera device
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as? AVCaptureDeviceInput
        
        if videoInput != nil {
            if self.captureSession.canAddInput(videoInput){
                self.captureSession.addInput(videoInput)
                self.activeVideoInput = videoInput
            }
        }
        else{
            return false
        }
        
        // Setup default microphone
        let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        let audioInput = AVCaptureDeviceInput.deviceInputWithDevice(audioDevice, error: &error) as? AVCaptureDeviceInput
        
        if audioInput != nil {
            if self.captureSession.canAddInput(audioInput){
                self.captureSession.addInput(audioInput)
            }
        }
        else{
            return false
        }
        
        // Set up the still image output
        self.imageOutput = AVCaptureStillImageOutput()
        self.imageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        if self.captureSession.canAddOutput(imageOutput){
            self.captureSession.addOutput(self.imageOutput)
        }
        
        // Set up movie file output
        self.movieOutput = AVCaptureMovieFileOutput()
        if self.captureSession.canAddOutput(self.movieOutput){
            self.captureSession.addOutput(self.movieOutput)
        }
        
        self.videoQueue = dispatch_queue_create("com.tapharmonic.VideoQueue", nil)
        
        
        return true
    }
    
    // page 184
    //- (void)startSession;
    func startSession(){
        if !self.captureSession.running{
            dispatch_async(self.videoQueue, { () -> Void in
                self.captureSession.startRunning()
            })
        }
    }
    
    //- (void)stopSession;
    func stopSession(){
        if self.captureSession.running{
            dispatch_async(self.videoQueue, { () -> Void in
                self.captureSession.stopRunning()
            })
        }
        
    }
    
    // Camera Device Support
    // helper func
    func cameraWithPosition(position : AVCaptureDevicePosition) -> AVCaptureDevice?{
        var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice]
        
        if devices != nil{
            for device in devices!{
                if device.position == position{
                    return device
                }
            }
        }
        
        return nil
    }
    //      (BOOL)switchCameras;
    func switchCameras() -> Bool{
        if !self.canSwitchCameras{
            return false
        }
        var error : NSError?
        let videoDevice = self.inactiveCamera
        
        let videoInput : AVCaptureDeviceInput? = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as? AVCaptureDeviceInput
        

        if videoInput != nil{
            self.captureSession.beginConfiguration()
            self.captureSession.removeInput(self.activeVideoInput)
            
            if self.captureSession.canAddInput(videoInput){
                self.captureSession.addInput(videoInput)
                self.activeVideoInput = videoInput
            }
            else{
                self.captureSession.addInput(self.activeVideoInput)
            }
            
            self.captureSession.commitConfiguration()
        }
        else{
            self.delegate.deviceConfigurationFailedWithError(error)
            return false
        }
        
        return true
    }
    
    
    
    
    // Tap to * Methods
    //    - (void)focusAtPoint:(CGPoint)point;
    
    func focusAtPoint(point : CGPoint){
        let device = self.activeCamera
        
        if device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
            var error : NSError?
            if device.lockForConfiguration(&error){
                device.focusPointOfInterest = point
                device.focusMode = AVCaptureFocusMode.AutoFocus
                device.unlockForConfiguration()
            }
            else{
                self.delegate.deviceConfigurationFailedWithError(error)
            }
        }
        
    }
    
    //    - (void)exposeAtPoint:(CGPoint)point;
    // Define KVO context pointer for observing 'adjustingExposure" device property.
    
    func exposeAtPoint(point : CGPoint){
        let device = self.activeCamera
        
        let exposureMode : AVCaptureExposureMode = AVCaptureExposureMode.ContinuousAutoExposure
        
        if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode){
            
            var error : NSError?
            
            if device.lockForConfiguration(&error){
                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
                
                if device.isExposureModeSupported(AVCaptureExposureMode.Locked){
                    device.addObserver(self, forKeyPath: "adjustingExposure", options: NSKeyValueObservingOptions.New, context: &THCameraAdjustingExposureContext)
                }
                device.unlockForConfiguration()
            }
            else{
                self.delegate.deviceConfigurationFailedWithError(error)
            }
        }
    }
    
    // observer
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &THCameraAdjustingExposureContext{
            let device : AVCaptureDevice = AVCaptureDevice()
            
            if !device.adjustingExposure && device.isExposureModeSupported(AVCaptureExposureMode.Locked){
                self.removeObserver(self, forKeyPath: "adjustingExposure", context: &THCameraAdjustingExposureContext)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var error : NSError?
                    if device.lockForConfiguration(&error){
                        device.exposureMode = AVCaptureExposureMode.Locked
                        device.unlockForConfiguration()
                    }
                    else{
                       self.delegate.deviceConfigurationFailedWithError(error)
                    }
                })
            }
        }
        else{
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
        
    //    - (void)resetFocusAndExposureModes;
    
    /** Media Capture Methods **/
    
    // Still Image Capture
    
    //    - (void)captureStillImage;
    
    // Video Recording
    
    //    - (void)startRecording;
    //    - (void)stopRecording;
    //    - (BOOL)isRecording;
    
}




