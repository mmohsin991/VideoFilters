//
//  SwiftVC2.swift
//  VideoFilters
//
//  Created by Mohsin on 03/10/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import GLKit

class SwiftVC2: UIViewController {

    var controller: THCameraController1!
    var previewView: THPreviewView1!
//    @property (weak, nonatomic) IBOutlet THOverlayView *overlayView;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controller = THCameraController1()
        
        let frame = self.view.bounds
        
        let eaglContext : EAGLContext = THContextManager.sharedInstance.eaglContext
        self.previewView = THPreviewView1(frame: frame, context: eaglContext)
        
        self.previewView.filter = THPhotoFilters.defaultFilter
        
        self.previewView.coreImageContext = THContextManager.sharedInstance.ciContext
        
//        self.view.insertSubview(self.previewView, aboveSubview: self.view)
        self.view.addSubview(self.previewView)
        
        var error : NSError?
        
        if self.controller.setupSession(&error) {
            self.controller.startSession()
        }
        else {
            println("errorr : \(error?.localizedDescription)")
        }
    }
    
}
