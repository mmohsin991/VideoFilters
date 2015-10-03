
//
//  THContextManager.swift
//  VideoFilters
//
//  Created by Mohsin on 03/10/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import OpenGLES


class THContextManager: NSObject {
   
    var eaglContext :EAGLContext!
    var ciContext : CIContext!
    
    static var sharedInstance : THContextManager{
        get {
            return THContextManager()
        }
    }
    
    override init(){
        super.init()
        self.eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let options : [NSObject : AnyObject] = [kCIContextWorkingColorSpace : NSNull()]
        ciContext = CIContext(EAGLContext: self.eaglContext, options: options)
    }
    
    
    
}
