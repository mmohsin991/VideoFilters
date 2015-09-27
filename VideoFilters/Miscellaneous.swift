//
//  Miscellaneous.swift
//  ToothFairyMagicApp
//
//  Created by Mohsin on 09/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import MediaPlayer
import AVFoundation




enum TFFairySize{
    case Small
    case Medium
    case Large
}

enum TFFairyColors{
    case White
    case Yellow
    case Pink
    case Blue
}


enum TFVideoRecordingStatus{
    case PreRecording
    case Recoding
    case Recorded
}


class MYPlayerVC : MPMoviePlayerViewController {
    
    override func supportedInterfaceOrientations() -> Int {
        
        return Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
    
}

extension CGRect{
    var center : CGPoint{
        get{
            return CGPoint(x: self.origin.x+(self.width/2), y: self.origin.y+(self.height/2))
        }
        set{
            self.origin = CGPoint(x: newValue.x-(self.width/2), y:  newValue.y-(self.height/2))
        }
    }
}


class TFRecordButton: UIButton {
    
    var forwardAnimation = true
    let ringShape = CAShapeLayer()
    let ringAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        let margin = self.bounds.width*0.04
        self.ringShape.bounds = CGRect(origin: CGPointZero, size: CGSize(width: self.bounds.width-(margin*2), height: self.bounds.width-(margin*2)))
        self.ringShape.frame.origin = CGPoint(x: margin, y: margin)
        self.ringShape.path = UIBezierPath(ovalInRect: self.ringShape.bounds).CGPath
        
        self.ringShape.lineWidth = self.frame.width*0.04
        self.ringShape.fillColor = UIColor.clearColor().CGColor
        
        // 2
        self.ringShape.strokeStart = 0.0
        self.ringShape.strokeEnd = 0.0
        
        //2.5
        self.ringShape.transform = CATransform3DMakeRotation(-(0.0174532925*90), 0, 0, 1)
    }
    
    
    func startCountdown(){
        self.ringAnimation.fromValue = 0.0
        self.ringAnimation.toValue = 1.0
        self.ringAnimation.duration = 10.0
        self.ringAnimation.delegate = self
        self.ringShape.strokeColor = UIColor.greenColor().CGColor
        
        self.ringAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
        self.self.ringAnimation.removedOnCompletion = false // don't remove after finishing
        
        self.ringShape.addAnimation(self.self.ringAnimation, forKey: "strokeEnd")
        self.layer.addSublayer(self.ringShape)
        
    }
    
    func endCountdown(){
        self.ringAnimation.fromValue = 1.0
        self.ringAnimation.toValue = 0.0
        self.ringAnimation.duration = 10.0
        ringShape.strokeColor = UIColor.redColor().CGColor
        
        self.ringAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
        self.ringAnimation.removedOnCompletion = false // don't remove after finishing
        self.ringShape.addAnimation(self.ringAnimation, forKey: nil)
    }
    
    
    func removeRing(){
        self.ringShape.removeAllAnimations()
        self.ringShape.removeFromSuperlayer()
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        self.enabled = true
        NSLog("finished")
        
    }
    
    
}