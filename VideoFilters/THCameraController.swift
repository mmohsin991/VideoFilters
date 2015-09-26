//
//  THCameraController.swift
//  VideoFilters
//
//  Created by Mohsin on 25/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary


//let const : THThumbnailCreatedNotification?
var THCameraAdjustingExposureContext : NSString = "THCameraAdjustingExposureContext"




// page no 180
protocol THCameraControllerDelegate {
    func deviceConfigurationFailedWithError(error : NSError?)
    func mediaCaptureFailedWithError(error : NSError?)
    func assetLibraryWriteFailedWithError(error : NSError?)
}




// page no 180
class THCameraController: NSObject, AVCaptureFileOutputRecordingDelegate {
    
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

    var cameraHasTorch : Bool!{
        get{
            return self.activeCamera.hasTorch
        }
    }
    var cameraHasFlash : Bool!{
        get{
            return self.activeCamera.hasFlash
        }
    }
    
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
    var torchMode : AVCaptureTorchMode!{
        get{
            return self.activeCamera.torchMode
        }
    }
    var flashMode : AVCaptureFlashMode!{
        get{
            return self.activeCamera.flashMode
        }
    }
    // pg:203  - (BOOL)isRecording;
    var isRecording : Bool{
        get{
            return self.movieOutput.recording
        }
    }
    
    
    
    // page 181
    var videoQueue : dispatch_queue_t!
    var activeVideoInput : AVCaptureDeviceInput!
    
    // output
    var imageOutput : AVCaptureStillImageOutput!
    var movieOutput : AVCaptureMovieFileOutput!
    var outputURL : NSURL!
    
    var captureImage : UIImage?
    
    
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
    
    // pg: 195   - (void)resetFocusAndExposureModes;
    func resetFocusAndExposureModes(){
        let device = self.activeCamera
        
        let focusMode = AVCaptureFocusMode.ContinuousAutoFocus
        let canResetFocus = device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode)
        
        let exposureMode : AVCaptureExposureMode = AVCaptureExposureMode.ContinuousAutoExposure
        let canResetExposure = device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode)
        
        let centerPoint = CGPointMake(0.5, 0.5)
        
        var error : NSError?
        
        if device.lockForConfiguration(&error){
            if canResetFocus{
                device.focusMode = focusMode
                device.focusPointOfInterest = centerPoint
            }
            if canResetExposure{
                device.exposureMode = exposureMode
                device.exposurePointOfInterest = centerPoint
            }
            device.unlockForConfiguration()
        }
        else{
            self.delegate.deviceConfigurationFailedWithError(error)
        }
    }
    
    
    // flash and torch mode
    func setFlashMode(flashMode : AVCaptureFlashMode){
        let device = self.activeCamera
        if device.isFlashModeSupported(flashMode){
            var error : NSError?
            if device.lockForConfiguration(&error){
                device.flashMode = flashMode
                device.unlockForConfiguration()
            }
            else{
                self.delegate.deviceConfigurationFailedWithError(error)
            }
        }
    }
    
    func setTorchhMode(torchMode : AVCaptureTorchMode){
        let device = self.activeCamera
        if device.isTorchModeSupported(torchMode){
            var error : NSError?
            if device.lockForConfiguration(&error){
                device.torchMode = torchMode
                device.unlockForConfiguration()
            }
            else{
                self.delegate.deviceConfigurationFailedWithError(error)
            }
        }
    }
    
    
    /** Media Capture Methods **/
    
    // Still Image Capture
    
    //    - (void)captureStillImage;
    
    func captureStillImage(){
        let connection : AVCaptureConnection = self.imageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        if connection.supportsVideoOrientation{
            connection.videoOrientation = self.currentVideoOrientation()
        }
        
        self.imageOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (sampleBuffer, error) -> Void in
          
            if sampleBuffer != nil {
                let imageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image : UIImage? = UIImage(data: imageData)
                // editiona
                if image != nil {
                    println("image succefully captured")
                    self.captureImage = image
                }
            }
            else{
                println("nil image sample buffer: \(error.localizedDescription)")
            }
        })
        // Capture still image

        
    }
    
    // helper func
    func currentVideoOrientation() -> AVCaptureVideoOrientation{
        var orientation : AVCaptureVideoOrientation!
        
        switch (UIDevice.currentDevice().orientation){
        case .Portrait:
            orientation = AVCaptureVideoOrientation.Portrait
        case .PortraitUpsideDown:
            orientation = AVCaptureVideoOrientation.PortraitUpsideDown
        case .LandscapeRight:
            orientation = AVCaptureVideoOrientation.LandscapeLeft
        case .LandscapeLeft:
            orientation = AVCaptureVideoOrientation.LandscapeRight
        default:
            orientation = AVCaptureVideoOrientation.LandscapeRight

        }
        
        return orientation
    }
    
    
    
    // Video Recording
    
    //pg: 203    - (void)startRecording;
    func startRecording(){
        if !self.isRecording{
            let videoConnection : AVCaptureConnection = self.movieOutput.connectionWithMediaType(AVMediaTypeVideo)
            if videoConnection.supportsVideoOrientation{
                videoConnection.videoOrientation = self.currentVideoOrientation()
            }
            if videoConnection.supportsVideoStabilization{
                videoConnection.enablesVideoStabilizationWhenAvailable = true
            }
            
            let device = self.activeCamera
            
            if device.smoothAutoFocusSupported{
                var error: NSError?
                if device.lockForConfiguration(&error){
                    device.smoothAutoFocusEnabled = true
                    device.unlockForConfiguration()
                }
                else{
                   self.delegate.deviceConfigurationFailedWithError(error)
                }
            }
            
            self.outputURL = self.uniqueURL()
            self.movieOutput.startRecordingToOutputFileURL(self.outputURL, recordingDelegate: self)
            
        }
    }
    
    // pg: 203  - (void)stopRecording;
    func stopRecording(){
        if self.isRecording{
            self.movieOutput.stopRecording()
        }
    }
    
    // helper func
    func uniqueURL() -> NSURL?{
        let fileManager = NSFileManager.defaultManager()
        
        let paths = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as? String
        
        if documentsDirectory != nil {
        
            var filePath:String? = documentsDirectory!.stringByAppendingPathComponent("kamera_movie.mov")
            
            
            return NSURL(fileURLWithPath: filePath!)!
        }
        
        return nil
    }
    // helper func
    func writeVideoToAssetsLibrary(videoURL : NSURL){
        let library = ALAssetsLibrary()
        
        if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL){
            var completionBlock : ALAssetsLibraryWriteVideoCompletionBlock!
            completionBlock = {(url, error) -> Void in
                if error != nil {
                    self.delegate.assetLibraryWriteFailedWithError(error)
                }
                else{
//                    self.gen
                }
            }
            library.writeVideoAtPathToSavedPhotosAlbum(videoURL, completionBlock: { (url, error) -> Void in
                println("video write")
            })
            
        }
    }
    
    // helper func 
    func generateThumbnailForVideoAtURL(videoUrl : NSURL){
        
        dispatch_async(self.videoQueue, { () -> Void in
            let asset = AVAsset.assetWithURL(videoUrl) as? AVAsset
            
            var imageGenerator : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.maximumSize = CGSizeMake(100.0, 0.0)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var cgImage : CGImage = imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil, error: nil)
            let image = UIImage(CGImage: cgImage)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                println("image generated : ")
            })
            
        })
        
    }
    
    
    // MARK: AVCaptureFileOutputRecordingDelegate func
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!){
        
        if error != nil {
            self.delegate.mediaCaptureFailedWithError(error)
        }
        else{
            self.writeVideoToAssetsLibrary(self.outputURL)
        }
        self.outputURL = nil
    }
    
    

    
}




