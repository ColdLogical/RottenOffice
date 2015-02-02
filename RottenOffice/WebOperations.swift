//
//  WebOperations.swift
//  RottenOffice
//
//  Created by Cold Logic on 2/2/15.
//  Copyright (c) 2015 Cold and Logical. All rights reserved.
//

import Foundation

let kAPIKey = "apikey"
let kDefaultKey = "s9gd3xzejzsyjzrj5zfu3d6a"
let kBoxOfficeURL = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json"
let kMoviesKey = "movies"

class WebOperations: NSObject {
        class func fetchMovies(completion: ((movies: [Movie]!) -> Void)?, failure: ((error: NSError) -> Void)?) {
                let params = [kAPIKey : kDefaultKey]
                let url = kBoxOfficeURL
                let op = WebOperation(URL: url, parameters: params)
                
                func success(request: NSURLRequest, json: NSDictionary) {
                        var movies = [Movie]()
                        
                        if let moviesArray = json[kMoviesKey] as? NSArray {
                                for dict in moviesArray {
                                        let movie = Movie.parseDictionary(dict as NSDictionary)
                                        movies.append(movie)
                                }
                        }
                        
                        if completion != nil {
                                completion!(movies: movies)
                        }
                }
                
                func fail(request: NSURLRequest, error: NSError) {
                        if failure != nil {
                                failure!(error: error)
                        }
                }
                
                op.connect(success, failure: fail)
        }
}
