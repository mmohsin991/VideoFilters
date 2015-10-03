//
//  THMovieWriter.swift
//  VideoFilters
//
//  Created by Mohsin on 30/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation

let THVideoFilename = "movie.mov"


protocol THMovieWriterDelegate{
    func didWriteMovieAtURL(outputURL : NSURL)
    
}


class THMovieWriter: NSObject {
   
    var isWriting : Bool =  false
    var delegate : THMovieWriterDelegate?
    var assetWriter : AVAssetWriter!
    var assetWriterVideoInput : AVAssetWriterInput!
    var assetWriterAudioInput : AVAssetWriterInput!
    var assetWriterInputPixelBufferAdaptor : AVAssetWriterInputPixelBufferAdaptor!

    
    var dispatchQueue : dispatch_queue_t!
    var ciContext : CIContext!
    var colorSpace : CGColorSpaceRef!
    var activeFilter : CIFilter!
    var videoSettings : [NSObject : AnyObject]!
    var audioSettings : [NSObject : AnyObject]!

    var firstSample : Bool!
    
    
    
    
    init(videoSettings: [NSObject : AnyObject], audioSettings: [NSObject : AnyObject], dispatchQueue: dispatch_queue_t){
        
        super.init()
        
        self.videoSettings = videoSettings
        self.audioSettings = audioSettings
        self.dispatchQueue = dispatchQueue

        self.ciContext = THContextManager.sharedInstance.ciContext
        self.colorSpace = CGColorSpaceCreateDeviceRGB()
        
        self.activeFilter = THPhotoFilters.defaultFilter
        self.firstSample = true
        
        
    }
    
    func filterChanged(newFilter : CIFilter){
        self.activeFilter = newFilter
    }
    
    

    
    func startWriting(){
        
        dispatch_async(self.dispatchQueue, { () -> Void in
            var error : NSError?
            
            let fileType = AVFileTypeQuickTimeMovie
            self.assetWriter = AVAssetWriter(URL: self.outputURL(), fileType: fileType, error: &error)
            if (self.assetWriter == nil || error != nil) {
                println("Could not create AVAssetWriter")
                return
            }
            
            self.assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: self.videoSettings as [NSObject : AnyObject])
            self.assetWriterVideoInput.expectsMediaDataInRealTime = true
            
            
            let orientation : UIDeviceOrientation = UIDevice.currentDevice().orientation
            self.assetWriterVideoInput.transform = THTransformForDeviceOrientation(orientation)
            
            
            let attributes : [NSObject : AnyObject] = [
                kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey : self.videoSettings[NSString(string: AVVideoWidthKey)]!,
                kCVPixelBufferWidthKey : self.videoSettings[NSString(string: AVVideoHeightKey)]!,                kCVPixelFormatOpenGLESCompatibility : kCFBooleanTrue,
            ]
            
            self.assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.assetWriterVideoInput, sourcePixelBufferAttributes: attributes)
            
            if self.assetWriter.canAddInput(self.assetWriterVideoInput){
                self.assetWriter.addInput(self.assetWriterVideoInput)
            }
            else{
                println("Unable to add video input.")
                return
            }
            
            self.assetWriterAudioInput =  AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: self.audioSettings)
            
            self.assetWriterAudioInput.expectsMediaDataInRealTime = true
            
            if self.assetWriter.canAddInput(self.assetWriterAudioInput){
                self.assetWriter.addInput(self.assetWriterAudioInput)
            }
            else{
                println("Unable to add audio input.")
            }
            
            self.isWriting = true
            self.firstSample = true

        })
        
        
    }
    
    
    func processSampleBuffer(sampleBuffer : CMSampleBufferRef){
        if !self.isWriting{
            return
        }
        
        let formatDesc : CMFormatDescriptionRef = CMSampleBufferGetFormatDescription(sampleBuffer)
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc)
        
        if Int(mediaType) == kCMMediaType_Video{
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            if self.firstSample! {
                if self.assetWriter.startWriting(){
                    self.assetWriter.startSessionAtSourceTime(timestamp)
                }
                else{
                    println("Failed to start writing.")
                }
                self.firstSample = false
            }
        
//            var outputRenderBuffer : CVPixelBufferRef?
            //            var _outputRenderBuffer = UnsafeMutablePointer<Unmanaged<CVPixelBuffer>?>.alloc(1)

            var _outputRenderBuffer:Unmanaged<CVPixelBuffer>?

            var pixelBufferPool : CVPixelBufferPoolRef = self.assetWriterInputPixelBufferAdaptor.pixelBufferPool
            
            var err : OSStatus? = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &_outputRenderBuffer)
            
            if err != nil{
                println("Unable to obtain a pixel buffer from the pool.")
                return
            }
            
            var imageBuffer : CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
            let sourceImage : CIImage = CIImage(CVPixelBuffer: imageBuffer, options: nil)
            
            self.activeFilter.setValue(sourceImage, forKey: kCIInputMaskImageKey)
            
            var filteredImage = self.activeFilter.outputImage
            
            if filteredImage == nil {
                filteredImage = sourceImage
            }
            
            let outputRenderBuffer = _outputRenderBuffer!.takeRetainedValue() as CVPixelBuffer
            self.ciContext.render(filteredImage, toCVPixelBuffer: outputRenderBuffer, bounds: filteredImage.extent(), colorSpace: self.colorSpace)
            
            
            if self.assetWriterVideoInput.readyForMoreMediaData {
                if !(self.assetWriterInputPixelBufferAdaptor.appendPixelBuffer(outputRenderBuffer, withPresentationTime: timestamp)) {
                    println("Error appending pixel buffer.")
                }
            }
            
        
        
        }
        
        else if (!self.firstSample && Int(mediaType) == kCMMediaType_Audio) {
            if (self.assetWriterAudioInput.readyForMoreMediaData) {
                if self.assetWriterAudioInput.appendSampleBuffer(sampleBuffer) {
                    println("Error appending audio sample buffer.")
                }
            }
        }
    }
    
    func stopWriting(){
        self.isWriting = false
        dispatch_async(self.dispatchQueue, { () -> Void in
        self.assetWriter.finishWritingWithCompletionHandler({ () -> Void in

            if self.assetWriter.status == AVAssetWriterStatus.Completed {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let fileUrl = self.assetWriter.outputURL
                        self.delegate?.didWriteMovieAtURL(fileUrl)
                        
                    })
                }
                else{
                    println("Failed to write movie: \(self.assetWriter.error)")
                }
            })
        })
    }
    
    
    func outputURL() -> NSURL?{
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent(THVideoFilename)
        let url = NSURL(fileURLWithPath: filePath)
        if NSFileManager.defaultManager().fileExistsAtPath(url!.path!){
            NSFileManager.defaultManager().removeItemAtURL(url!, error: nil)
        }
        
        return url
        
    }
    
}
