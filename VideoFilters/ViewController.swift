//
//  ViewController.swift
//  VideoFilters
//
//  Created by Mohsin on 04/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, THPreviewViewDelegate {

    
    let cameraController = THCameraController()

    
    
    @IBOutlet weak var previewView: THPreviewView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        var error : NSError?
        
        if self.cameraController.setupSession(&error) {
            self.previewView.session = self.cameraController.captureSession
            self.previewView.delegate = self
            
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

    
    // MARK : THPreviewViewDelegate
    func tappedToFocusAtPoint(point: CGPoint) {
        println("tappedToFocusAtPoint")
    }
    
    func tappedToExposeAtPoint(point: CGPoint) {
        println("tappedToExposeAtPoint")
    }
    func tappedToResetFocusAndExposure() {
        println("tappedToResetFocusAndExposure")
    }
    

    
    
    @IBAction func picture(sender: UIButton) {
        self.cameraController.captureStillImage()
    }
    
    @IBAction func start(sender: UIButton) {
        self.cameraController.startRecording()
    }
    
    @IBAction func stop(sender: UIButton) {
        self.cameraController.stopRecording()
    }
    
    
    
}

