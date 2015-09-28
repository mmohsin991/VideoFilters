//
//  THAssetsLibrary.swift
//  VideoFilters
//
//  Created by Mohsin on 28/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation


class THAssetsLibrary: NSObject {
   
    var library : ALAssetsLibrary!
    
    override init(){
        super.init()
        
        self.library = ALAssetsLibrary()
    }
    

    
    func writeImage(image : UIImage , complete : (success : Bool , error : NSError?) -> Void){
        
        self.library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock: { (assetUrl, error) -> Void in
            if error != nil{
                complete(success: false, error: error)
            }
            else{
                complete(success: true, error: nil)
            }
        })
    }
    
    
    func writeVideoAtURL(videoURL : NSURL, complete : (success : Bool , error : NSError?)->Void ){
        
        if self.library.videoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL){
            
            self.library.writeVideoAtPathToSavedPhotosAlbum(videoURL, completionBlock: { (url, error) -> Void in
                println("video write")
                
                if error != nil {
                    complete(success: false, error: error)
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        complete(success: true, error: nil)
                    })
                }
            })
            
        }
    }

    
    // helper func
    func generateThumbnailForVideoAtURL(videoUrl : NSURL , complete : (image: UIImage?) -> Void){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let asset = AVAsset.assetWithURL(videoUrl) as? AVAsset
            
            var imageGenerator : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.maximumSize = CGSizeMake(100.0, 0.0)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var cgImage : CGImage = imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil, error: nil)
            let image = UIImage(CGImage: cgImage)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                println("image generated : \(image?.description)")
                complete(image: image)
            })
        })
    }
    
    
}

