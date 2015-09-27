//
//  VideoOverlay.swift
//  ToothFairyMagicApp
//
//  Created by Mohsin on 19/08/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import AVFoundation
import AssetsLibrary
import MediaPlayer


class VideoOverlay {
    
    
    class func mergeAudiVideoAndAnimation(#audioUrl: NSURL, videoUrl : NSURL, outputVideName: String, maximumVideoDuration: Double,musicMixLevel: Float, audioMixLevel: Float,fairySize: TFFairySize, fairyColor: TFFairyColors, fairyDustOn: Bool, callBack : (outputUrl: NSURL? , errorDesc: String?)->Void){
        var mixComposition = AVMutableComposition()
        
        println("audioUrl: \(audioUrl)")
        
        //first load your audio file using AVURLAsset, Make sure you give the correct path of your videos.
        let audioAsset = AVURLAsset(URL: audioUrl, options: nil)
        let  audio_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        
        
        //Now we will load video file.
        let videoAsset = AVURLAsset(URL: videoUrl, options: nil)
        
        
        var durationOfVideoInSec = Float64(maximumVideoDuration)
        
        println(durationOfVideoInSec)
        println( Float64(CMTimeGetSeconds(videoAsset.duration)) )
        // if the duration of video is less then 24 sec then update the duration of video
        if durationOfVideoInSec > CMTimeGetSeconds(videoAsset.duration) {
            durationOfVideoInSec = CMTimeGetSeconds(videoAsset.duration)
        }
        
        
        
        let  video_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(durationOfVideoInSec, 1))
        
        
        //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
        
        let b_compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        var error : NSError?
        let audios = audioAsset.tracksWithMediaType(AVMediaTypeAudio)
        let assetTrackAudio:AVAssetTrack = audios[0] as! AVAssetTrack
        
        
        // increment it for looping the while condition
        var incDurationOfAudioInSec = CMTimeGetSeconds(kCMTimeZero)
        
        // variable audio time range (it will be deserase in last repeation b/c to fit with video duration)
        var variable_audio_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        var addDurationOfAudio = kCMTimeZero
        
        
        
        if CMTimeGetSeconds(audioAsset.duration) < durationOfVideoInSec{
            
            // do loop here
            while incDurationOfAudioInSec < durationOfVideoInSec{
                
                // if audio duration is increases from the whole video duration then reduce the last repeate track of audio to fit with video duration
                if incDurationOfAudioInSec+CMTimeGetSeconds(audioAsset.duration) > durationOfVideoInSec{
                    let calculateTimeInSec = durationOfVideoInSec-incDurationOfAudioInSec
                    let tempDuration = CMTimeMakeWithSeconds(calculateTimeInSec, 1)
                    variable_audio_timeRange = CMTimeRangeMake(kCMTimeZero, tempDuration)
                }
                
                b_compositionAudioTrack.insertTimeRange(variable_audio_timeRange, ofTrack: assetTrackAudio, atTime: addDurationOfAudio, error: nil)
                
                // add the next starting point of the audio
                addDurationOfAudio = CMTimeAdd(addDurationOfAudio, audioAsset.duration)
                
                // increment audio duration
                incDurationOfAudioInSec += CMTimeGetSeconds(audioAsset.duration)
            }
            
        }
            
            // if audio duration is greater then video duration
        else if CMTimeGetSeconds(audioAsset.duration) > durationOfVideoInSec{
            b_compositionAudioTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackAudio, atTime: kCMTimeZero, error: nil)
            
        }
        
        
        
        //define the path where you want to store the final video created with audio and video merge.
        let dirPaths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsDir = dirPaths[0]as! NSString
        
        let outputFilePath = docsDir.stringByAppendingPathComponent("\(outputVideName).MOV")
        
        let outputFileUrl = NSURL(fileURLWithPath: outputFilePath)
        
        if NSFileManager.defaultManager().fileExistsAtPath(outputFilePath){
            NSFileManager.defaultManager().removeItemAtPath(outputFilePath, error: nil)
        }
        
        
        //Now create an AVAssetExportSession object that will save your final video at specified path.
        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        
        assetExport.outputFileType = "com.apple.quicktime-movie"
        assetExport.outputURL = outputFileUrl
        
        
        
        // start new implementation
        
        
        // check if the video is portraite mode then forcefully stoped it and do animation
        assetExport.videoComposition = SetVideoOrientationAndAnimation.getVideoCompositionWithAnimation(videoAsset, composition:mixComposition, durationOfVideoInSec: durationOfVideoInSec, fairySize: fairySize, fairyColor: fairyColor, fairyDustOn: fairyDustOn)
        
        
        
        // slow down the music sound in last 2 seconds
        let params = AVMutableAudioMixInputParameters(track:b_compositionAudioTrack)
        
        // set the volume of the music
        //let volume: Float  = 0.4
        params.setVolume(musicMixLevel, atTime:CMTimeMakeWithSeconds(0,1))
        // let timeStart = CMTimeMakeWithSeconds(durationOfVideoInSec - 2.0, 1)
        let timeStart = CMTimeMakeWithSeconds(durationOfVideoInSec, 1)
        let timeDuration = CMTimeMakeWithSeconds(2.0, 1)
        
        // if toEndVolume : 0 then it willm slow down the sound in last 2 second
        //  params.setVolumeRampFromStartVolume( musicMixLevel, toEndVolume:1, timeRange:CMTimeRangeMake(timeStart,timeDuration))
        //        let mix = AVMutableAudioMix()
        //        mix.inputParameters = [params]
        //
        //        assetExport.audioMix = mix
        
        
        
        
        // extract the audio from video file
        let a_compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        let audiosTemp = videoAsset.tracksWithMediaType(AVMediaTypeAudio)
        let assetTrackAudioTemp:AVAssetTrack = audiosTemp[0] as! AVAssetTrack
        a_compositionAudioTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackAudioTemp, atTime: kCMTimeZero, error: nil)
        
        let params1 = AVMutableAudioMixInputParameters(track:a_compositionAudioTrack)
        
        // slow down the video's audio sound in last 2 seconds
        // set the volume of the video's audio
        //let volume: Float  = 0.4
        params1.setVolume(audioMixLevel, atTime:CMTimeMakeWithSeconds(0,1))
        let timeStart1 = CMTimeMakeWithSeconds(durationOfVideoInSec - 2.0, 1)
        let timeDuration1 = CMTimeMakeWithSeconds(2.0, 1)
        //params1.setVolumeRampFromStartVolume( audioMixLevel, toEndVolume:0, timeRange:CMTimeRangeMake(timeStart,timeDuration))
        
        
        // integrate audio and music levels in final output video audio
        let mix = AVMutableAudioMix()
        mix.inputParameters  = [params,params1]
        assetExport.audioMix = mix
        
        
        
        
        
        assetExport.exportAsynchronouslyWithCompletionHandler { () -> Void in
            // when export Finished
            if assetExport.status == AVAssetExportSessionStatus.Completed{
                let outputUrl = assetExport.outputURL
                let library = ALAssetsLibrary()
                
                callBack(outputUrl: outputUrl, errorDesc: nil)

                // uncomment if you save the videos in photos album
//                if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(assetExport.outputURL){
//                    library.writeVideoAtPathToSavedPhotosAlbum(outputUrl, completionBlock: { (url, error) -> Void in
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            if error != nil {
//                                //  println("Some error: \(error)")
//                                callBack(outputUrl: nil, errorDesc: "Some error: \(error)")
//                            }
//                            else{
//                                println("video saved")
//                                
//                                callBack(outputUrl: assetExport.outputURL, errorDesc: nil)
//                            }
//                        })
//                    })
//                }
            }
        }
    }
    
    
    
    
    
    class func getDuratonInSec(url : NSURL) -> Double{
        
        let tempAsset = AVURLAsset(URL: url, options: nil)
        
        return Double(CMTimeGetSeconds(tempAsset.duration))
        
    }
    
    class func getThumbnailOfVide(videoUrl: NSURL) -> UIImage?{
        
        let asset: AVAsset = AVAsset.assetWithURL(videoUrl) as! AVAsset
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // set the thumb image orientation automatically
        imageGenerator.appliesPreferredTrackTransform = true
        
        // take the snapshoot of the middle duration of video
        let timeInSec = CMTimeGetSeconds(asset.duration)/2
        
        let time = CMTimeMakeWithSeconds(timeInSec, 1)
        
        var error : NSError?
        let myImage = imageGenerator.copyCGImageAtTime(time, actualTime: nil, error: &error)
        
        if myImage != nil {
            return UIImage(CGImage: myImage!)
        }
        
        return nil
    }

    
}



// new class which helps in video orientation
class SetVideoOrientationAndAnimation {
    
    
    class func getVideoCompositionWithAnimation(asset: AVAsset, composition: AVMutableComposition, durationOfVideoInSec: Double, fairySize: TFFairySize, fairyColor: TFFairyColors, fairyDustOn: Bool) -> AVMutableVideoComposition{
        
        //let isPortrait = self.isVideoPortrait(asset)
        let orientation = self.getVideoOrientation(asset)
        
        // change kCMPersistentTrackID_Invalid to CMPersistentTrackID()
        let compositionVideoTrack : AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        let videoTrack: AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
        compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(durationOfVideoInSec, 1)), ofTrack: videoTrack, atTime: kCMTimeZero, error: nil)
        //        println((AVMediaTypeVideo).count)
        
        
        let layerInst : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        
        let transform : CGAffineTransform = videoTrack.preferredTransform
        layerInst.setTransform(transform, atTime: kCMTimeZero)
        
        
        // change [AVMutableVideoCompositionInstruction videoCompositionInstruction]; to AVMutableVideoCompositionInstruction()
        let inst : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        inst.layerInstructions = [layerInst]
        
        
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [inst]
        
        
        var videoSize : CGSize = videoTrack.naturalSize
        

        
        if orientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown {
            println("video is portrait")
            videoSize = CGSizeMake(videoSize.height, videoSize.width)
        }
        else if orientation == UIInterfaceOrientation.LandscapeLeft || orientation == UIInterfaceOrientation.LandscapeRight {
            println("video is landscap")
            videoSize = CGSizeMake(videoSize.width, videoSize.height)
        }
        
        
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTimeMake(1,30)
        videoComposition.renderScale = 1.0
        
        
        
        
        // MARK: videoOverlay animation
        
        applyVideoEffectsToComposition(videoComposition, size: videoComposition.renderSize, image: imageWithColor(UIColor.blueColor(), videoComposition.renderSize), videoDuration: durationOfVideoInSec, fairySize: fairySize, fairyColor: fairyColor, fairyDustOn: fairyDustOn)
        
        
        
        
        
        return videoComposition
        
    }
    
    
    
    // MARK: apply video overlay Animation

    private class func applyVideoEffectsToComposition(composition:AVMutableVideoComposition, size:CGSize, image:UIImage, videoDuration : Double, fairySize: TFFairySize, fairyColor: TFFairyColors, fairyDustOn: Bool){
        
        
        println("video size: \(size)")
        
        var overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: CGPointZero , size: size )
        
        // animation
//
//        Fairy.fairy(fairySize, fairyColor: fairyColor, center: CGPoint(x: 200, y: 300), fairyDustOn: fairyDustOn, useInAVFoundation: true, animationDuration: videoDuration,  parentLayer: overlayLayer)
        
        Fairy.glowFairy(fairySize, fairyColor: fairyColor, center: CGPoint(x: 200, y: 300), fairyDustOn: fairyDustOn, useInAVFoundation: true, animationDuration: videoDuration,  parentLayer: overlayLayer)

        
        var videoLayer = CALayer()
        videoLayer.frame = CGRectMake(0, 0, size.width, size.height)
        videoLayer.masksToBounds = true
        
        
        var parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, size.width, size.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        
        
    }
    

    
    
    
    class func isVideoPortrait(asset : AVAsset) -> Bool {
        var isPortrait = false
        
        let tracks = asset.tracksWithMediaType(AVMediaTypeVideo)
        
        if tracks.count > 0 {
            
            let videoTrack = tracks[0] as! AVAssetTrack
            
            let t : CGAffineTransform = videoTrack.preferredTransform
            
            // Portrait
            if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
            {
                isPortrait = true
            }
            // PortraitUpsideDown
            if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
                
                isPortrait = true
            }
            // LandscapeRight
            if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
            {
                isPortrait = false
            }
            // LandscapeLeft
            if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
            {
                isPortrait = false
            }
            
        }
        return isPortrait
        
    }
    
    
    
    class func getVideoOrientation(asset : AVAsset) -> UIInterfaceOrientation {
        
        let tracks = asset.tracksWithMediaType(AVMediaTypeVideo)
        
        if tracks.count > 0 {
            
            let videoTrack = tracks[0] as! AVAssetTrack
            
            let t : CGAffineTransform = videoTrack.preferredTransform
            
            // Portrait
            if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
            {
                println("Portrait")
                return UIInterfaceOrientation.Portrait
            }
            // PortraitUpsideDown
            if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
                
                println("PortraitUpsideDown")
                return UIInterfaceOrientation.PortraitUpsideDown
                
            }
            // LandscapeRight
            if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
            {
                println("LandscapeRight")
                return UIInterfaceOrientation.LandscapeRight
                
            }
            // LandscapeLeft
            if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
            {
                println("LandscapeLeft")
                return UIInterfaceOrientation.LandscapeLeft
                
            }
            
        }
        
        
        // never execute
        return UIInterfaceOrientation.Portrait
    }
    
    
}

