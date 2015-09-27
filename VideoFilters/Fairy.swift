//
//  Fairy.swift
//  ToothFairyMagicApp
//
//  Created by Mohsin on 20/08/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


class Fairy {
    
    class func fairy(fairySize: TFFairySize, fairyColor: TFFairyColors, center: CGPoint, fairyDustOn : Bool, useInAVFoundation : Bool, animationDuration: Double, parentLayer: CALayer){
        
        println(animationDuration)
        
        var fairyLayer = CALayer()
        var rightWing = CALayer()
        var leftWing = CALayer()
        var fairyBody = CALayer()
        var fairyUpperBody = CALayer()
        var fairyLeg1 = CALayer()
        var fairyLeg2 = CALayer()
        var size = CGSize(width: 100, height: 100)
        let fairyBodyImg = UIImage(named: "fairyBody.png")
        
        var fairyWingImg = UIImage(named: "fairyWing.png")
        var fairyUpperBodyImg = UIImage(named: "fairyUpperBody.png")
        var fairyLeg1Img = UIImage(named: "fairyLeg1.png")
        var fairyLeg2Img = UIImage(named: "fairyLeg2.png")
        
        if fairyColor == TFFairyColors.Yellow{
            fairyWingImg = UIImage(named: "fairyWingYellow.png")
            fairyUpperBodyImg = UIImage(named: "fairyUpperBodyYellow.png")
            fairyLeg1Img = UIImage(named: "fairyLeg1Yellow.png")
            fairyLeg2Img = UIImage(named: "fairyLeg2Yellow.png")
        }
        else if fairyColor == TFFairyColors.Pink{
            fairyWingImg = UIImage(named: "fairyWingPink.png")
            fairyUpperBodyImg = UIImage(named: "fairyUpperBodyPink.png")
            fairyLeg1Img = UIImage(named: "fairyLeg1Pink.png")
            fairyLeg2Img = UIImage(named: "fairyLeg2Pink.png")
        }
        else if fairyColor == TFFairyColors.Blue{
            fairyWingImg = UIImage(named: "fairyWingBlue.png")
            fairyUpperBodyImg = UIImage(named: "fairyUpperBodyBlue.png")
            fairyLeg1Img = UIImage(named: "fairyLeg1Blue.png")
            fairyLeg2Img = UIImage(named: "fairyLeg2Blue.png")
        }
        
        
        //MARK: set for UIView or AVFoundation
        var xAxis : CGFloat = 0.5
        var yAxis : CGFloat = 0.38
        var anchorPoint = CGPointMake(1,1)
        var transform = CATransform3DMakeRotation(0.1, 0, 0, 1)
        var fairyUpperBodyYAxis : CGFloat = 0.17
        var fairyLegsYAxis : CGFloat = 0.56
        var fairyLeg1AnchorPoint = CGPointMake(0.93,0.62)
        var fairyLeg2AnchorPoint = CGPointMake(0.77,0.91)
        // if use in AVLayer b/c the window cordinates in AVFoundaiton is starting from bottom left corner
        if useInAVFoundation {
            xAxis = 0.5
            yAxis = 0.0
            fairyUpperBodyYAxis = 0.18
            fairyLegsYAxis = 0.09
            fairyLeg1AnchorPoint = CGPointMake(0.93,0.38)
            fairyLeg2AnchorPoint = CGPointMake(0.77,0.09)
            anchorPoint = CGPointMake(1,0)
            transform = CATransform3DMakeRotation(-0.1, 0, 0, 1)
            
        }
        
        
        
        leftWing.contents = fairyWingImg?.CGImage
        rightWing.contents = fairyWingImg?.CGImage
        fairyBody.contents = fairyBodyImg?.CGImage
        
        fairyUpperBody.contents = fairyUpperBodyImg?.CGImage
        fairyLeg1.contents = fairyLeg1Img?.CGImage
        fairyLeg2.contents = fairyLeg2Img?.CGImage
        
        switch(fairySize){
        case .Small:
            size = CGSize(width: 150, height: 150)
        case .Medium:
            size = CGSize(width: 200, height: 200)
        case .Large:
            size = CGSize(width: 250, height: 250)
        }
        
        
        
        
        
        println("environmentSize: \(parentLayer.frame.size)")
        //        fairyLayer.frame = CGRect(origin: CGPoint(x: parentLayer.frame.size.width*0.0-(size.width/2),y: parentLayer.frame.size.height*0.5-(size.height/2)), size: size)
        fairyLayer.frame = CGRect(origin: parentLayer.frame.origin, size: size)
        
        
        rightWing.frame = CGRect(x: size.width*xAxis, y: size.width*yAxis, width: size.width*0.6, height: size.height*0.6)
        leftWing.frame = CGRect(x: size.width*xAxis, y: size.width*yAxis, width: size.width*0.6, height: size.height*0.6)
        fairyBody.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        fairyUpperBody.frame = CGRect(x: size.width*0.34, y: size.height*fairyUpperBodyYAxis, width: size.width*0.65, height: size.height*0.65)
        fairyLeg1.frame =  CGRect(x: size.width*0.20, y: size.width*fairyLegsYAxis, width: size.width*0.35, height: size.height*0.35)
        fairyLeg2.frame =  CGRect(x: size.width*0.20, y: size.width*fairyLegsYAxis, width: size.width*0.35, height: size.height*0.35)
        
        
        
        //        rightWing.backgroundColor = UIColor.lightGrayColor().CGColor
        //        leftWing.backgroundColor = UIColor.blueColor().CGColor
        ////        fairyBody.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.7).CGColor
        //        parentLayer.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.7).CGColor
        //        fairyUpperBody.backgroundColor = UIColor.yellowColor().CGColor
        //        fairyLeg1.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.7).CGColor
        
        
        // apply the distance-mapping transform.
        //        var transform = CATransform3DIdentity
        //        transform.m34 = -1.0/1000.0
        //        parentLayer.sublayerTransform = transform
        
        
        //MARK: Right wing animation
        rightWing.transform = transform
        //        rightWing.anchorPoint = CGPointMake(1,1)
        rightWing.anchorPoint = anchorPoint
        let animX_R = CAKeyframeAnimation(keyPath:"transform")
        animX_R.values = [0.0,0.9,0.0]
        animX_R.additive = true
        animX_R.valueFunction = CAValueFunction(name: kCAValueFunctionRotateX)
        
        let animZ_R = CAKeyframeAnimation(keyPath:"transform")
        if useInAVFoundation {
            animZ_R.values = [0.0,-0.4,0.0]
        }else{
            animZ_R.values = [0.0,0.4,0.0]
        }
        animZ_R.additive = true
        
        animZ_R.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
        
        let groupAnimation_R = CAAnimationGroup()
        groupAnimation_R.animations = [animX_R,animZ_R]
        groupAnimation_R.repeatCount = Float.infinity
        groupAnimation_R.duration = 0.5
        groupAnimation_R.beginTime = AVCoreAnimationBeginTimeAtZero
        
        rightWing.addAnimation(groupAnimation_R, forKey:nil)
        
        
        
        //MARK: Left wing animation
        leftWing.transform = transform
        //leftWing.anchorPoint = CGPointMake(1,1)
        leftWing.anchorPoint = anchorPoint
        let animX_L = CAKeyframeAnimation(keyPath:"transform")
        animX_L.values = [0.0,0.9,0.0]
        animX_L.additive = true
        animX_L.valueFunction = CAValueFunction(name: kCAValueFunctionRotateX)
        
        let animZ_L = CAKeyframeAnimation(keyPath:"transform")
        animZ_L.values = [0.0,0.0,0.0]
        animZ_L.additive = true
        animZ_L.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
        
        let groupAnimation_L = CAAnimationGroup()
        groupAnimation_L.animations = [animX_L,animZ_L]
        groupAnimation_L.repeatCount = Float.infinity
        groupAnimation_L.duration = 0.5
        groupAnimation_L.beginTime = AVCoreAnimationBeginTimeAtZero
        
        
        leftWing.addAnimation(groupAnimation_L, forKey: nil)
        
        
        
        //MARK: fairy Leg1 animation
        fairyLeg1.anchorPoint = fairyLeg1AnchorPoint
        
        let animZ_Leg1 = CAKeyframeAnimation(keyPath:"transform")
        if useInAVFoundation {
            animZ_Leg1.values = [0.0,(30*kDegToRad),0.0]
        }else{
            animZ_Leg1.values = [0.0,-(30*kDegToRad),0.0]
        }
        animZ_Leg1.additive = true
        animZ_Leg1.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
        animZ_Leg1.repeatCount = Float.infinity
        animZ_Leg1.duration = 1.0
        animZ_Leg1.beginTime = AVCoreAnimationBeginTimeAtZero
        
        fairyLeg1.addAnimation(animZ_Leg1, forKey: nil)
        
        
        
        //MARK: fairy Leg2 animation
        fairyLeg2.anchorPoint = fairyLeg2AnchorPoint
        let animZ_Leg2 = CAKeyframeAnimation(keyPath:"transform")
        if useInAVFoundation {
            fairyLeg2.transform = CATransform3DMakeRotation((50*kDegToRad), 0, 0, 1)
            animZ_Leg2.values = [0.0,-(30*kDegToRad),0.0]
            
        }else{
            fairyLeg2.transform = CATransform3DMakeRotation(-(50*kDegToRad), 0, 0, 1)
            animZ_Leg2.values = [0.0,(30*kDegToRad),0.0]
        }
        animZ_Leg2.additive = true
        animZ_Leg2.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
        animZ_Leg2.repeatCount = Float.infinity
        animZ_Leg2.duration = 1.0
        animZ_Leg2.beginTime = AVCoreAnimationBeginTimeAtZero
        
        fairyLeg2.addAnimation(animZ_Leg2, forKey: nil)
        
        
        //MARK: fairy dust
        if fairyDustOn{
            
            let fairyDustPath = TFToothFairyPaths.getPathType2(animationDuration, size:parentLayer.frame.size)
            
            // MARK: fairy dust path animation
            
            let fairyDust = TFFairyDust.fairyDust(fairyDustPath, frame: parentLayer.frame)
            
            //   fairyDust.transform = CATransform3DMakeScale(0.5, 0.5, 1)
            fairyDust.scale = 2.0
            
            // create a new CAKeyframeAnimation that animates the objects position
            let fairyDustAnimation = CAKeyframeAnimation(keyPath: "emitterPosition")
            
            // set the animations path to our bezier curve
            fairyDustAnimation.path = fairyDustPath
            
            fairyDustAnimation.repeatCount = Float.infinity
            fairyDustAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
            fairyDustAnimation.duration = 12
            
            // we add the animation to the squares 'layer' property
            fairyDust.addAnimation(fairyDustAnimation, forKey: nil)
            
            
            parentLayer.addSublayer(fairyDust)
            
        }
        
        
        
        fairyLayer.addSublayer(leftWing)
        fairyLayer.addSublayer(rightWing)
        //        parentLayer.addSublayer(fairyBody)
        fairyLayer.addSublayer(fairyLeg1)
        fairyLayer.addSublayer(fairyLeg2)
        
        fairyLayer.addSublayer(fairyUpperBody)
        
        
        
        //MARK: parent layer animation
        
        let animX_Parent = CAKeyframeAnimation(keyPath:"transform")
        animX_Parent.values = [0.0,0.9,0.0,-0.9,0.0]
        animX_Parent.additive = true
        animX_Parent.valueFunction = CAValueFunction(name: kCAValueFunctionRotateX)
        
        let groupAnimation_Parent = CAAnimationGroup()
        groupAnimation_Parent.animations = [animX_Parent]
        groupAnimation_Parent.repeatCount = Float.infinity
        groupAnimation_Parent.duration = 5.0
        groupAnimation_Parent.beginTime = AVCoreAnimationBeginTimeAtZero
        
        //fairyLayer.addAnimation(groupAnimation_Parent, forKey: nil)
        
        
        
        
        // MARK: fairy path animation
        let fairyPath = TFToothFairyPaths.getPathType2(animationDuration, size:parentLayer.frame.size)
        
        // create a new CAKeyframeAnimation that animates the objects position
        let fairyPathAnimation = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
        fairyPathAnimation.path = fairyPath
        
        fairyPathAnimation.rotationMode = kCAAnimationRotateAuto
        fairyPathAnimation.repeatCount = Float.infinity
        fairyPathAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        fairyPathAnimation.duration = animationDuration
        
        
        fairyPathAnimation.duration = 12
        
        
        let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        fadeAnimation.values = [1.0,0.0]
        fadeAnimation.beginTime = 11.0
        fadeAnimation.duration = 1.0
        
        
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [fairyPathAnimation, fadeAnimation]
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        groupAnimation.duration = 12
        
        
        // we add the animation to the squares 'layer' property
        fairyLayer.addAnimation(groupAnimation, forKey: nil)
        
        
        
        parentLayer.addSublayer(fairyLayer)
        
    }
    
    
    
    class func glowFairy(fairySize: TFFairySize, fairyColor: TFFairyColors, center: CGPoint, fairyDustOn : Bool, useInAVFoundation : Bool, animationDuration: Double, parentLayer: CALayer){
        
        var size = CGSize(width: 100, height: 100)
        var fairyLayer = CALayer()
        let glowImage = UIImage(named: "glowWhite.png")
        
        
        switch(fairySize){
        case .Small:
            size = CGSize(width: 150, height: 150)
        case .Medium:
            size = CGSize(width: 200, height: 200)
        case .Large:
            size = CGSize(width: 250, height: 250)
        }
        
        
        fairyLayer.contents = glowImage?.CGImage
        
        // MARK: fairy path animation
        let fairyPath = TFToothFairyPaths.getPathType2(animationDuration, size:parentLayer.frame.size)
        let fairyEndPath = TFToothFairyPaths.endPath(parentLayer.frame.size)

        fairyLayer.frame = CGRect(origin: parentLayer.frame.origin, size: size)
        
        
        // create a new CAKeyframeAnimation that animates the objects position
        let fairyPathAnimation = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
        fairyPathAnimation.path = fairyPath
        fairyPathAnimation.rotationMode = kCAAnimationRotateAuto
        fairyPathAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
        fairyPathAnimation.removedOnCompletion = false
        fairyPathAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        // animationDuration-6 because end animation and 2 sec hide and 4 sec for end animation
        fairyPathAnimation.duration = animationDuration-8
        
        
        
        let fairyEndPathAnimation = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
        fairyEndPathAnimation.path = fairyEndPath
        fairyEndPathAnimation.rotationMode = kCAAnimationRotateAuto
        fairyEndPathAnimation.beginTime = animationDuration-4
        fairyEndPathAnimation.duration = 4
        
        
        
        let shrinkAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        shrinkAnimation.values = [1.0,0.0,0.0,0.0,1.0]
        shrinkAnimation.beginTime = animationDuration-8
        shrinkAnimation.duration = 4.0
        shrinkAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        
        
        let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        fadeAnimation.values = [2.0,0.3]
        fadeAnimation.autoreverses = true
        fadeAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        fadeAnimation.repeatCount = Float.infinity
        
        fadeAnimation.duration = 3.0
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [fairyPathAnimation, fadeAnimation, fairyEndPathAnimation, shrinkAnimation]
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        groupAnimation.duration = animationDuration
        
        
        
        // we add the animation to the squares 'layer' property
        fairyLayer.addAnimation(groupAnimation, forKey: nil)
        
        parentLayer.addSublayer(fairyLayer)
        
        
        
        
        //MARK: fairy dust
        if fairyDustOn{
            
            let fairyDustPath = TFToothFairyPaths.getPathType2(animationDuration, size:parentLayer.frame.size)
            
            // MARK: fairy dust path animation
            
            let fairyDust = TFFairyDust.fairyDust(fairyDustPath, frame: parentLayer.frame)
            
            // create a new CAKeyframeAnimation that animates the objects position
            let fairyDustAnimation = CAKeyframeAnimation(keyPath: "emitterPosition")
            
            // set the animations path to our bezier curve
            fairyDustAnimation.path = fairyDustPath
            fairyDustAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
            fairyDustAnimation.removedOnCompletion = false
            fairyDustAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
            // animationDuration-6 because end animation and 2 sec hide and 4 sec for end animation
            fairyDustAnimation.duration = animationDuration-8
            
            
            
            
            let fairyDustEndPathAnimation = CAKeyframeAnimation(keyPath: "position")
            
            // set the animations path to our bezier curve
            fairyDustEndPathAnimation.path = fairyEndPath
            fairyDustEndPathAnimation.rotationMode = kCAAnimationRotateAuto
            fairyDustEndPathAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
            fairyDustEndPathAnimation.removedOnCompletion = false
            fairyDustEndPathAnimation.beginTime = animationDuration-4
            fairyDustEndPathAnimation.duration = 4
            
            
            
            // group animation
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [fairyDustAnimation, fairyDustEndPathAnimation]
            groupAnimation.repeatCount = Float.infinity
            groupAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
            groupAnimation.duration = animationDuration
            
            
            fairyDust.addAnimation(groupAnimation, forKey: nil)
            
            
            parentLayer.addSublayer(fairyDust)
            
        }
        
    }
    
}