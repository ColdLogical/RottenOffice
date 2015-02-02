//
//  Movie.swift
//  RottenOffice
//
//  Created by Cold Logic on 2/2/15.
//  Copyright (c) 2015 Cold and Logical. All rights reserved.
//

import Foundation

let kPostersKey = "posters"
let kSynopsisKey = "synopsis"
let kThumbnailKey = "thumbnail"
let kTitleKey = "title"

class Movie: NSObject {
        lazy var synopsis = String()
        lazy var thumbnail = String()
        lazy var title = String()
        
        init(title: String, synopsis: String, thumbnail: String) {
                super.init()
                self.synopsis = synopsis
                self.thumbnail = thumbnail
                self.title = title
        }
        
        class func parseDictionary(dictionary: NSDictionary) -> Movie {
                let title: String = dictionary[kTitleKey] as? String ?? ""
                let synop: String = dictionary[kSynopsisKey] as? String ?? ""
                
                var thumb: String = ""
                
                if let posters = dictionary[kPostersKey] as? NSDictionary {
                        if let t = posters[kThumbnailKey] as? String {
                                thumb = t
                        }
                }
                
                return Movie(title: title, synopsis: synop, thumbnail: thumb)
        }
}
