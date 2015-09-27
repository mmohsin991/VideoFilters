//
//  TFFairyDust.swift
//  ToothFairyMagicApp
//
//  Created by Mohsin on 20/08/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation



class TFFairyDust {
    
    class func fairyDust(emittingPath : CGPath, frame: CGRect) -> CAEmitterLayer{
        
        
        var emit = CAEmitterLayer()
        emit.frame.size = frame.size
        emit.frame.origin = frame.origin
        emit.emitterPosition = frame.origin
        emit.emitterShape = kCAEmitterLayerPoint
        emit.emitterMode = kCAEmitterLayerPoints
        
        emit.lifetime = 1.5
        
        let cell = makeEmitterCellSmall()
        let cellGlow = makeEmitterCellGlow()
        
        emit.emitterCells = [cell,cellGlow]
        
        
        return emit
        
    }
    
    
    private class func makeEmitterCellSmall() -> CAEmitterCell{
        
        // make a partical image
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(3,3), false, 1)
        let con = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(con, CGRectMake(0,0,3,3))
        CGContextSetFillColorWithColor(con, kTFGoldenColor.CGColor)
        CGContextFillPath(con)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        // make a cell with that image
        let cell = CAEmitterCell()
        cell.contents = image.CGImage
        
        cell.birthRate = 30
        cell.lifetime = 1.5
        cell.velocity = 80
        cell.emissionRange = CGFloat(M_PI)
        
        cell.lifetimeRange = 0.5
        cell.velocityRange = 40
        
        
        return cell
    }
    
    private class func makeEmitterCellGlow() -> CAEmitterCell{
        
        let image = UIImage(named: "glow.png")
        
        // make a cell with that image
        let cell = CAEmitterCell()
        cell.contents = image!.CGImage
        
        cell.birthRate = 10
        cell.lifetime = 1.5
        cell.velocity = 80
        cell.emissionRange = CGFloat(M_PI)
        
        cell.scale = 0.3
        cell.scaleRange = 1.0
        cell.scaleSpeed = 0.3
        cell.spin = 0.7
        
        
        cell.lifetimeRange = 0.5
        cell.velocityRange = 40
        //        cell.scaleRange = 0.2
        //        cell.scaleSpeed = 0.2
        //        cell.greenRange = 0.5
        
        return cell
    }
    
    
    
}



