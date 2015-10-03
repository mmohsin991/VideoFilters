//
//  THBaseCameraController.swift
//  VideoFilters
//
//  Created by Mohsin on 28/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


let THThumbnailCreatedNotification : NSString = "THThumbnailCreated"
let THMovieCreatedNotification : NSString = "THMovieCreated"

class THBaseCameraController: NSObject {
 
    var delegate : THCameraControllerDelegate!
    var captureSession : AVCaptureSession!
    var dispatchQueue : dispatch_queue_t!
    var activeVideoInput : AVCaptureDeviceInput!
    
    var outputURL : NSURL!
    var library : THAssetsLibrary!

    //    - (NSString *)sessionPreset;
    var sessionPreset : String{
        get{
            return AVCaptureSessionPresetHigh
        }
    }
    
    
    //    var cameraCount : NSUInteger!
    var cameraCount : Int!{
        get{
            return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count
        }
    }
    //    - (BOOL)canSwitchCameras;
    var canSwitchCameras : Bool{
        get{
            return self.cameraCount > 1
        }
    }

    var activeCamera : AVCaptureDevice{
        get{
            return self.activeVideoInput.device
        }
    }

    var inactiveCamera : AVCaptureDevice?{
        var device : AVCaptureDevice?
        
        if self.cameraCount > 1{
            if self.activeCamera.position == AVCaptureDevicePosition.Back{
                device = self.cameraWithPosition(AVCaptureDevicePosition.Front)
            }
            else{
                device = self.cameraWithPosition(AVCaptureDevicePosition.Back)
            }
        }
        
        return device
    }
    
    
    
    override init(){
        super.init()
        self.library =  THAssetsLibrary()
        dispatchQueue =  dispatch_queue_create("com.tapharmonic.CaptureDispatchQueue", nil)
    }
    
    
    
//    // Session Configuration
//    - (BOOL)setupSession:(NSError **)error;
    func setupSession(inout error : NSError?) -> Bool{
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if !self.setupSessionInputs(&error){
           return false
        }
        
        if !self.setupSessionOutputs(&error){
            return false
        }
        
        return true
    }
    


    
    
//    - (BOOL)setupSessionInputs:(NSError **)error;
    func setupSessionInputs(inout error : NSError?) -> Bool{
        // Set up default camera device
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as? AVCaptureDeviceInput

        if videoInput != nil {
            if self.captureSession.canAddInput(videoInput){
                self.captureSession.addInput(videoInput)
                self.activeVideoInput = videoInput
            }
            else{
                return false
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
            else{
                return false
            }
        }
        else{
            return false
        }
  
        return true
    }
//    - (BOOL)setupSessionOutputs:(NSError **)error;
    func setupSessionOutputs(inout error : NSError?) -> Bool{
        return false
    }
    //- (void)startSession;
    func startSession(){
        if !self.captureSession.running{
            dispatch_async(self.dispatchQueue, { () -> Void in
                self.captureSession.startRunning()
            })
        }
    }
    
    //- (void)stopSession;
    func stopSession(){
        if self.captureSession.running{
            dispatch_async(self.dispatchQueue, { () -> Void in
                self.captureSession.stopRunning()
            })
        }
    }

    
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
    
    

    
    //MARK: Device Configuration

    
    
    
}
