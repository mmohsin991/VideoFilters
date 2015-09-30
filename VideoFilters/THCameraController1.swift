//
//  THCameraController1.swift
//  VideoFilters
//
//  Created by Mohsin on 28/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation

class THCameraController1: THBaseCameraController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, THMovieWriterDelegate{
   
    var videoDataOutput : AVCaptureVideoDataOutput!
    var audioDataOutput : AVCaptureAudioDataOutput!
    var movieWriter : THMovieWriter!
    override var sessionPreset : String{
        get{
            return AVCaptureSessionPreset1280x720
        }
    }
    
    var recording : Bool = false
    var imageTarget : THImageTarget!
    
    
    override func setupSessionOutputs(error : NSError) -> Bool{
        self.videoDataOutput = AVCaptureVideoDataOutput()
        let outputSettings : [NSObject : AnyObject] = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
        
        self.videoDataOutput.videoSettings = outputSettings
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = false
        
        self.videoDataOutput.setSampleBufferDelegate(self, queue: self.dispatchQueue)
        if self.captureSession.canAddOutput(self.videoDataOutput) {
            self.captureSession.addOutput(self.videoDataOutput)
        }
        else{
            return false
        }
        
        self.audioDataOutput = AVCaptureAudioDataOutput()
        self.audioDataOutput.setSampleBufferDelegate(self, queue: self.dispatchQueue)
        
        if self.captureSession.canAddOutput(self.audioDataOutput) {
            self.captureSession.addOutput(self.audioDataOutput)
        }
        else{
            return false
        }
        
        let fileType = AVFileTypeQuickTimeMovie
        
        let videoSettings = self.videoDataOutput.recommendedVideoSettingsForAssetWriterWithOutputFileType(fileType)
        
        let audioSettings = self.audioDataOutput.recommendedAudioSettingsForAssetWriterWithOutputFileType(fileType)
        
        // temp comment
        
//        self.movieWriter = THMovieWriter()
//        self.movieWriter.delegate = self
        
        
        return true
    }
    
    
    func startRecording(){
        self.movieWriter.startWriting()
        self.recording = true
    }
    
    func stopRecording(){
        self.movieWriter.stopWriting()
        self.recording = false
    }
    
    
    
    // MARK: delegateMethod
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // temp comment
//        self.movieWriter.processSampleBuffer(sampleBuffer)
        if captureOutput == self.videoDataOutput{
            let imageBuffer : CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
            let sourceImage = CIImage(CVPixelBuffer: imageBuffer, options: nil)
            self.imageTarget.setImage(sourceImage)
        }
    }
    
    // MARK: THMovieWriterDelegate func
    func didWriteMovieAtURL(outputURL: NSURL) {
        
    }
    
}
