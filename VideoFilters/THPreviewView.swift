//
//  THPreviewView.swift
//  VideoFilters
//
//  Created by Mohsin on 25/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


// page no 177
protocol THPreviewViewDelegate {
    func tappedToFocusAtPoint(point: CGPoint)
    func tappedToExposeAtPoint(point: CGPoint)
    func tappedToExposeAtPoint()
}

// page no 177,178

class THPreviewView : UIView {
    
    
    //    for objC to swift - (void)setSession:(AVCaptureSession *)session
    
    var session : AVCaptureSession!{
        set{
            (self.layer as? AVCaptureVideoPreviewLayer)?.setSessionWithNoConnection(newValue)
        }
        get{
            return (self.layer as? AVCaptureVideoPreviewLayer)?.session

        }
    }
    var delegate : THPreviewViewDelegate!
    
    var tapToFocusEnabled : Bool!
    var tapToExposeEnabled : Bool!
    
    
    override class func layerClass() -> AnyClass{
        return AVCaptureVideoPreviewLayer.classForCoder()
    }
    
    
    private func captureDevicePointForPoint(point : CGPoint) -> CGPoint{
        let layer = self.layer as? AVCaptureVideoPreviewLayer
        
        return layer!.captureDevicePointOfInterestForPoint(point)
    }

    
}


