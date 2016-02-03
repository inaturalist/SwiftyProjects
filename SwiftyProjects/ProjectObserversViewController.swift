//
//  ProjectObserversViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/2/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import UIKit

class ProjectObserversViewController: UITableViewController, ObservedScrollView, ProjectObservationVisualizer {
    
    var userCounts: [UserCount]?
    var userTotal: Int = 0
    var slug: String?
    weak var containedScrollViewDelegate: ContainedScrollViewDelegate?

    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        if let s = self.slug {
            self.fetchProjectSlug(s)
        } else {
            self.fetchProjectSlug("inat-observation-of-the-day")
        }
    }
    
    // MARK: - iNat api fetch

    func fetchProjectSlug(slug: String) {
        let api = INatAPI()
        api.fetchObservers(slug) { (json, error) -> Void in
            if let j = json {
                if let count = j["total_results"] as? Int {
                    self.userTotal = count
                }
                let array: [UserCount]? = decodeWithRootKey("results", j)
                self.userCounts = array
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - ProjectObservationVisualizer

    func reload() {
        self.tableView.reloadData()
    }
    
    func choseProjectSlug(slug: String) {
        if slug == self.slug {
            return
        }
        
        self.userCounts?.removeAll()
        self.userTotal = 0
        self.tableView?.reloadData()
        
        self.fetchProjectSlug(slug)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ucs = self.userCounts {
            return ucs.count
        } else {
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCount", forIndexPath: indexPath) as! UserCountCell
        
        cell.selectionStyle = .None
        
        if let ucs = self.userCounts {
            let uc = ucs[indexPath.item]
            
            cell.userLoginLabel?.text = uc.user.login
            
            cell.observationCountLabel?.text = "Observations: \(uc.observationCount)"
            cell.speciesCountLabel?.text = "Species: \(uc.speciesCount)"
            
            if let urlString = uc.user.iconUrl,
                let url = NSURL(string: urlString) {
                    
                    cell.userImageView?.hnk_setImageFromURL(url)
            }
            
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do nothing for now
    }
    
    // MARK: - UIScrollViewDelegate
    // having trouble getting this to execute as a protocol extension
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.containedScrollViewDelegate?.scrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.containedScrollViewDelegate?.scrollViewDidEndScrolling(scrollView)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.containedScrollViewDelegate?.scrollViewDidEndScrolling(scrollView)
    }
}
