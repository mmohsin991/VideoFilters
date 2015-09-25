//
//  THCameraController.swift
//  VideoFilters
//
//  Created by Mohsin on 25/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


// page no 180
protocol THCameraControllerDelegate {
    func deviceConfigurationFailedWithError(error : NSError)
    func mediaCaptureFailedWithError(error : NSError)
    func assetLibraryWriteFailedWithError(error : NSError)
}


//let const : THThumbnailCreatedNotification?

// page no 180
class THCameraController: NSObject {
    
    var delegate : THCameraControllerDelegate!
    var captureSession: AVCaptureSession!
    
    
    // Camera Device Support
    
    //    var cameraCount : NSUInteger!
    var cameraCount : UInt!
    var cameraHasTorch : Bool!
    var cameraHasFlash : Bool!
    var cameraSupportsTapToFocus : Bool!
    var cameraSupportsTapToExpose : Bool!
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
    func setupSession(var error : NSError?) -> Bool{
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
    //      (BOOL)switchCameras;
    //    - (BOOL)canSwitchCameras;
    
    
    //    var cameraCount : NSUInteger!
    
    
    
    
    
    // Tap to * Methods
    //    - (void)focusAtPoint:(CGPoint)point;
    //    - (void)exposeAtPoint:(CGPoint)point;
    //    - (void)resetFocusAndExposureModes;
    
    /** Media Capture Methods **/
    
    // Still Image Capture
    
    //    - (void)captureStillImage;
    
    // Video Recording
    
    //    - (void)startRecording;
    //    - (void)stopRecording;
    //    - (BOOL)isRecording;
    
}

