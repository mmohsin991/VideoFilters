//
//  THPreviewView1.swift
//  VideoFilters
//
//  Created by Mohsin on 03/10/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit





protocol THImageTarget{
    func setImage(image : CIImage)
}

// page no 177,178

class THPreviewView1 : GLKView, THImageTarget {
    
    var filter : CIFilter!
    var coreImageContext : CIContext!
    var drawableBounds : CGRect!
    
    
    
    override init(frame : CGRect, context : EAGLContext){
        super.init(frame: frame, context: context)
        self.enableSetNeedsDisplay = false
        self.backgroundColor = UIColor.blackColor()
        self.opaque = false
        
        
        // because the native video image from the back camera is in
        // UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right),
        // we need to apply a clockwise 90 degree transform so that we can draw
        // the video preview as if we were in a landscape-oriented view;
        // if you're using the front camera and you want to have a mirrored
        // preview (so that the user is seeing themselves in the mirror), you
        // need to apply an additional horizontal flip (by concatenating
        // CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
        self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        self.frame = frame
        
        self.bindDrawable()
        
        self.drawableBounds = self.bounds;
        self.drawableBounds.size.width = CGFloat(self.drawableWidth)
        self.drawableBounds.size.height = CGFloat(self.drawableHeight)
        

        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func filterChange(filter:CIFilter){
        self.filter = filter
    }
    
    
    // MARK: THImageTarget functions
    func setImage(sourceImage : CIImage){
        self.bindDrawable()
        self.filter.setValue(sourceImage, forKey: kCIInputImageKey)
        let filteredImage = self.filter.outputImage
        
        if filteredImage != nil {
            let cropRect : CGRect = THCenterCropImageRect(sourceImage.extent(), self.drawableBounds)
            self.coreImageContext.drawImage(filteredImage, inRect: self.drawableBounds, fromRect: cropRect)
        }
        
        self.display()
        self.filter.setValue(nil, forKey: kCIInputImageKey)
        
    }
    
    
}


