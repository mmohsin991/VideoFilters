//
//  THPhotoFilters.swift
//  VideoFilters
//
//  Created by Mohsin on 28/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit

class THPhotoFilters: NSObject {
    
    var filterNames : [String] = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone",
        "CIColorInvert",
    ]
    
    var defaultFilter : CIFilter {
        get{
            return CIFilter(name: self.filterNames[0])
        }
    }

    
    
    
    func filterDisplayNames() -> [String]{
        var filterNamess = [String]()
        
        for filter in self.filterNames{
            filterNamess.append(filter)
        }
        
        return filterNamess
    }

    
    func filterForDisplayName(displayName : String)-> CIFilter?{
        
        for name in self.filterNames{
            if NSString(string: name).containsString(displayName){
                return CIFilter(name: name)
            }
        }
        
        return nil
    }
}
