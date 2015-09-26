//
//  THPreviewView.swift
//  VideoFilters
//
//  Created by Mohsin on 25/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


let BOX_BOUNDS = CGRectMake(0.0, 0.0, 150.0, 150.0)


// page no 177
protocol THPreviewViewDelegate {
    func tappedToFocusAtPoint(point: CGPoint)
    func tappedToExposeAtPoint(point: CGPoint)
    func tappedToResetFocusAndExposure()
}

// page no 177,178

class THPreviewView : UIView {
    
    
    //    for objC to swift - (void)setSession:(AVCaptureSession *)session
    
    var session : AVCaptureSession!{
        set{
            (self.layer as? AVCaptureVideoPreviewLayer)?.session = newValue
        }
        get{
            return (self.layer as? AVCaptureVideoPreviewLayer)?.session
        }
    }
    var delegate : THPreviewViewDelegate!
    var tapToFocusEnabled : Bool!
    var tapToExposeEnabled : Bool!
    
    // gestures
    var singleTapRecognizer : UITapGestureRecognizer!
    var doubleTapRecognizer : UITapGestureRecognizer!
    var doubleDoubleTapRecognizer : UITapGestureRecognizer!
    
    // sub views
    var focusBox : UIView!
    var exposureBox : UIView!
    var timer : NSTimer!
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    
    
    func setupView(){
        
        (self.layer as? AVCaptureVideoPreviewLayer)?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.singleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        
        self.doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        self.doubleTapRecognizer.numberOfTapsRequired = 2
        
        self.doubleDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleDoubleTap:")
        self.doubleDoubleTapRecognizer.numberOfTapsRequired = 2
        self.doubleDoubleTapRecognizer.numberOfTouchesRequired = 2
        
        self.addGestureRecognizer(self.singleTapRecognizer)
        self.addGestureRecognizer(self.doubleTapRecognizer)
        self.addGestureRecognizer(self.doubleDoubleTapRecognizer)
        
        self.singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        
        self.focusBox = self.viewWithColor(UIColor.greenColor())
        self.exposureBox = self.viewWithColor(UIColor.brownColor())
        
        self.addSubview(self.focusBox)
        self.addSubview(self.exposureBox)
    }
    
    
    func handleSingleTap(recognizer : UIGestureRecognizer){
        let point = recognizer.locationInView(self)
        self.runBoxAnimationOnView(self.focusBox, point: point)
        if self.delegate != nil {
            self.delegate.tappedToFocusAtPoint(self.captureDevicePointForPoint(point))
        }
    }

    func handleDoubleTap(recognizer : UIGestureRecognizer){
        let point = recognizer.locationInView(self)
        self.runBoxAnimationOnView(self.exposureBox, point: point)
        if self.delegate != nil {
            self.delegate.tappedToExposeAtPoint(self.captureDevicePointForPoint(point))
        }
    }
    func handleDoubleDoubleTap(recognizer : UIGestureRecognizer){
        self.runResetAnimation()
        if self.delegate != nil {
            self.delegate.tappedToResetFocusAndExposure()
        }
    }

    
    // helper func
    func runBoxAnimationOnView(view : UIView, point : CGPoint){
        view.center = point
        view.hidden = false

        UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
        }) { (bool) -> Void in
            let delayInSeconds = 0.5
            let popTime : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delayInSeconds)*NSEC_PER_SEC))
            dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                view.hidden = true
                view.transform = CGAffineTransformIdentity
            })
        }
    }
    
    func runResetAnimation(){
        if !self.tapToExposeEnabled && !self.tapToFocusEnabled{
            return
        }
        
        let previewLayer : AVCaptureVideoPreviewLayer? = self.layer as? AVCaptureVideoPreviewLayer
        let centerPoint : CGPoint = previewLayer!.pointForCaptureDevicePointOfInterest(CGPointMake(0.5, 0.5))
        self.focusBox.center = centerPoint
        self.exposureBox.center = centerPoint
        self.exposureBox.transform = CGAffineTransformMakeScale(1.2, 1.2)
        self.focusBox.hidden = false
        self.exposureBox.hidden = false
        
        UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.focusBox.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
            self.exposureBox.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0)
        }) { (complete) -> Void in
            let delayInSeconds = 0.5
            let popTime : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delayInSeconds)*NSEC_PER_SEC))
            dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                self.focusBox.hidden = true
                self.exposureBox.hidden = true
                self.focusBox.transform = CGAffineTransformIdentity
                self.exposureBox.transform = CGAffineTransformIdentity
            })
        }
    }
    
    // helper func
    func setTapToFocusEnabled(enabled : Bool){
        self.tapToFocusEnabled = enabled
        self.singleTapRecognizer.enabled = enabled
    }
    // helper func
    func setTapToExposeEnabled(enabled : Bool){
        self.tapToExposeEnabled = enabled
        self.doubleTapRecognizer.enabled = enabled
    }
    
    // helper func
    func viewWithColor(color : UIColor) -> UIView{
        let view = UIView(frame: BOX_BOUNDS)
        view.backgroundColor = UIColor.clearColor()
        view.layer.borderColor = color.CGColor
        view.layer.borderWidth = 3.0
        view.hidden = true
        
        return view
    }
    
    override class func layerClass() -> AnyClass{
        return AVCaptureVideoPreviewLayer.classForCoder()
    }
    
    
    private func captureDevicePointForPoint(point : CGPoint) -> CGPoint{
        let layer = self.layer as? AVCaptureVideoPreviewLayer
        
        return layer!.captureDevicePointOfInterestForPoint(point)
    }

    
}


