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


func THCenterCropImageRect(sourceRect : CGRect, previewRect : CGRect) -> CGRect{
    let sourceAspectRatio = sourceRect.size.width / sourceRect.size.height
    let previewAspectRatio = previewRect.size.width  / previewRect.size.height
    
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    var drawRect = sourceRect
    
    if sourceAspectRatio > previewAspectRatio {
        // use full height of the video image, and center crop the width
        let scaledHeight = drawRect.size.height * previewAspectRatio
        drawRect.origin.x += (drawRect.size.width - scaledHeight) / 2.0
        drawRect.size.width = scaledHeight
    }
    else{
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) / 2.0
        drawRect.size.height = drawRect.size.width / previewAspectRatio
    }
    
    return drawRect

}