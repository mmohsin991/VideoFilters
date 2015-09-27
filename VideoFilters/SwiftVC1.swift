//
//  ViewController.swift
//  VideoFilters
//
//  Created by Mohsin on 04/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


class SwiftVC1 : UIViewController, THPreviewViewDelegate, THCameraControllerDelegate{
    
    @IBOutlet weak var previewView: THPreviewView!
    
    
    let cameraController = THCameraController()
    let megicalSound1 = NSBundle.mainBundle().URLForResource("MagicalSound1", withExtension: ".mp3")
    var player:MPMoviePlayerViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        Fairy.glowFairy(TFFairySize.Medium, fairyColor: TFFairyColors.Pink, center: CGPoint(x: 200, y: 300), fairyDustOn: true, useInAVFoundation: false, animationDuration: 44.0,  parentLayer: self.view.layer)
        //
        
        var error : NSError?
        
        if self.cameraController.setupSession(&error) {
            self.previewView.session = self.cameraController.captureSession
            self.previewView.delegate = self
            self.previewView.addGestures(self)
            
            self.cameraController.delegate = self
            self.cameraController.startSession()
        }
        else{
            println(error?.localizedDescription)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK : THPreviewViewDelegate
    func tappedToFocusAtPoint(point: CGPoint) {
        self.cameraController.focusAtPoint(point)
        println("tappedToFocusAtPoint")
    }
    
    func tappedToExposeAtPoint(point: CGPoint) {
        self.cameraController.exposeAtPoint(point)
        println("tappedToExposeAtPoint")
    }
    func tappedToResetFocusAndExposure() {
        self.cameraController.resetFocusAndExposureModes()
        println("tappedToResetFocusAndExposure")
    }
    
    
    //MARK : THCameraControllerDelegate implimentation
    func deviceConfigurationFailedWithError(error: NSError?) {
        
    }
    func mediaCaptureFailedWithError(error: NSError?) {
        
    }
    func assetLibraryWriteFailedWithError(error: NSError?) {
        
    }
    
    var videoAnimationCompleted = false
    
    func videoCaptured(videoUrl: NSURL!) {
        
        println("video captured : \(videoUrl)")
        
        if videoUrl != nil {
            let timeStamp = Int(NSDate().timeIntervalSince1970).description
            
            var musicMixLevel : Float = 1.0
            var audioMixLevel : Float = 1.0
            
            
            VideoOverlay.mergeAudiVideoAndAnimation(audioUrl: self.megicalSound1!, videoUrl: videoUrl, outputVideName: timeStamp, maximumVideoDuration: Double(videomaximumDuration), musicMixLevel: musicMixLevel, audioMixLevel: audioMixLevel, fairySize: TFFairySize.Medium, fairyColor: TFFairyColors.White, fairyDustOn: true, callBack: { (outputUrl, errorDesc) -> Void in
                
                if outputUrl != nil {
                    self.videoAnimationCompleted = true
                    self.cameraController.writeVideoToAssetsLibrary(outputUrl!)
                }
            })
        }
        
        
    }
    func imageCaptured(image: UIImage!) {
        println("image captured : \(image.description)")
        
    }
    
    func videoWritenToAssetsLibrary(videoUrl : NSURL!){
        if self.videoAnimationCompleted{
            self.playVideo(videoUrl)
        }
    }

    
    
    
    
    
    func playVideo(videoURL: NSURL){
        
        player = MPMoviePlayerViewController(contentURL: videoURL)
        //player.moviePlayer.prepareToPlay()
        self.presentMoviePlayerViewControllerAnimated(player)
    }
    
    
    
    
    
    
    
    @IBAction func startVideo(sender: UIButton) {
        self.cameraController.startRecording()
    }
    
    @IBAction func stopVideo(sender: UIButton) {
        self.cameraController.stopRecording()
        
    }
    
    
    @IBAction func captureImage(sender: UIButton) {
        self.cameraController.captureStillImage()
    }
    
    
    @IBAction func switchCamera(sender: UIButton) {
        if self.cameraController.canSwitchCameras{
            self.cameraController.switchCameras()
        }
    }
    
    
    var flashModeCount = 0
    @IBAction func flashMode(sender: UIButton) {
        
        self.flashModeCount++
        if self.cameraController.cameraHasFlash{
            println("camera has flash")
            if self.flashModeCount%3 == 0{
                self.cameraController.setFlashMode(AVCaptureFlashMode.Auto)
            }
            else if self.flashModeCount%3 == 1{
                self.cameraController.setFlashMode(AVCaptureFlashMode.On)
            }
            else if self.flashModeCount%3 == 2{
                self.cameraController.setFlashMode(AVCaptureFlashMode.Off)
            }
        }
        if self.cameraController.cameraHasTorch {
            println("camera has torch")
            if self.flashModeCount%3 == 0{
                self.cameraController.setTorchhMode(AVCaptureTorchMode.Auto)
            }
            else if self.flashModeCount%3 == 1{
                self.cameraController.setTorchhMode(AVCaptureTorchMode.On)
            }
            else if self.flashModeCount%3 == 2{
                self.cameraController.setTorchhMode(AVCaptureTorchMode.Off)
            }
        }
        
    }
    
    
    
}
