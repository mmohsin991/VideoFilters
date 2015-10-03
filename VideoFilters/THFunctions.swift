//
//  THFunctions.swift
//  VideoFilters
//
//  Created by Mohsin on 03/10/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit



func THTransformForDeviceOrientation(orientation : UIDeviceOrientation)-> CGAffineTransform {
    
    
    var result : CGAffineTransform!
    
    
    switch orientation {
    case UIDeviceOrientation.LandscapeRight:
        result = CGAffineTransformMakeRotation(CGFloat(M_PI))
    case UIDeviceOrientation.PortraitUpsideDown:
        result = CGAffineTransformMakeRotation(CGFloat(M_PI_2 * 3))

    case .Portrait , .FaceUp, .FaceDown:
        result = CGAffineTransformMakeRotation(CGFloat(M_PI_2))

    default :
        result = CGAffineTransformIdentity
    }

    return result
}