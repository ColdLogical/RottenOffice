//
//  ImageCache.swift
//  RottenOffice
//
//  Created by Cold Logic on 2/2/15.
//  Copyright (c) 2015 Cold and Logical. All rights reserved.
//

import UIKit

class ImageCache: NSObject {
        lazy var cache: NSCache = NSCache()
        
        class var sharedInstance: ImageCache {
                struct Static {
                        static var instance: ImageCache?
                        static var token: dispatch_once_t = 0
                }
                
                dispatch_once(&Static.token) {
                        Static.instance = ImageCache()
                }
                
                return Static.instance!
        }
        
        func cachedImage(key: String) -> UIImage {
                var image: UIImage = UIImage()
                
                if let i = cache.objectForKey(key) as? UIImage {
                        image = i
                } else {
                        if let url = NSURL(string: key ) {
                                if let data = NSData(contentsOfURL: url) {
                                        if let i = UIImage(data: data) {
                                                cache.setObject(i, forKey: key)
                                                image = i
                                        }
                                }
                        }
                }
                
                return image
        }
}
