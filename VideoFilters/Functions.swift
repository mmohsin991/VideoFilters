//
//  Functions.swift
//  ToothFairyMagicApp
//
//  Created by Mohsin on 19/08/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation


func imageWithColor(color : UIColor, imageSize :  CGSize) -> UIImage{
    
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    color.setFill()
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height))   // Fill it with your color
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image;
}


func TFGetThumbnailOfVideo(videoUrl: NSURL, snapTime: Double) -> UIImage?{
    
    let asset: AVAsset = AVAsset.assetWithURL(videoUrl) as! AVAsset
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    // set the thumb image orientation automatically
    imageGenerator.appliesPreferredTrackTransform = true
    
    // take the snapshoot of the middle duration of video
    
    //    let timeInSec = CMTimeGetSeconds(asset.duration)/2
    //   let time = CMTimeMakeWithSeconds(timeInSec, 1)
    
    
    let time = CMTimeMakeWithSeconds(snapTime, 1)
    
    var error : NSError?
    let myImage = imageGenerator.copyCGImageAtTime(time, actualTime: nil, error: &error)
    
    if myImage != nil {
        return UIImage(CGImage: myImage!)
    }
    
    return nil
}