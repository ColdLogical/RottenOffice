//
//  ViewController.swift
//  RottenOffice
//
//  Created by Cold Logic on 2/2/15.
//  Copyright (c) 2015 Cold and Logical. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
        lazy var movies: [Movie] = [Movie]()

        override func viewDidLoad() {
                super.viewDidLoad()
                
                func completion(movies: [Movie]!) -> Void {
                        self.movies = movies
                        self.tableView.reloadData()
                }
                
                WebOperations.fetchMovies(completion, failure: nil)
        }

        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
        }
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return movies.count
        }
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                var cell = self.tableView.dequeueReusableCellWithIdentifier("MovieCell") as MovieCell
                
                let m = movies[indexPath.row]
                
                cell.titleLabel!.text = m.title
                cell.synopsisLabel!.text = m.synopsis
                
                if !m.thumbnail.isEmpty {
                        cell.thumbnailImage!.image = ImageCache.sharedInstance.cachedImage(m.thumbnail)
                }
                
                return cell
        }
}

