//
//  THPhotoFilters.swift
//  VideoFilters
//
//  Created by Mohsin on 28/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit

class THPhotoFilters: NSObject {
    
    static var filterNames : [String] = [
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
    
    class var defaultFilter : CIFilter {
        get{
            return CIFilter(name: filterNames[5])
        }
    }

    
    
    
    func filterDisplayNames() -> [String]{
        var filterNamess = [String]()
        
        for filter in THPhotoFilters.filterNames{
            filterNamess.append(filter)
        }
        
        return filterNamess
    }

    
    func filterForDisplayName(displayName : String)-> CIFilter?{
        
        for name in THPhotoFilters.filterNames{
            if NSString(string: name).containsString(displayName){
                return CIFilter(name: name)
            }
        }
        
        return nil
    }
}
