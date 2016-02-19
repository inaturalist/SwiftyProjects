//
//  ProjectIdentifiersViewController.swift
//  ProjectsViewPager
//
//  Created by Alex Shepard on 2/18/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

    //http://api.inaturalist.org/observations/identifiers

import Argo
import UIKit

class ProjectIdentifiersViewController: UITableViewController, ObservedScrollView, ProjectObservationVisualizer {
    
    var identifierCounts: [IdentifierCount]?
    var identifierTotal: Int = 0
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("identifiers")
    }

    
    // MARK: - iNat api fetch
    
    func fetchProjectSlug(slug: String) {
        let api = INatAPI()
        api.fetchIdentifiers(slug) { (json, error) -> Void in
            if let j = json {
                if let count = j["total_results"] as? Int {
                    self.identifierTotal = count
                }
                let array: [IdentifierCount]? = decodeWithRootKey("results", j)
                self.identifierCounts = array
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
        
        self.identifierCounts?.removeAll()
        self.identifierTotal = 0
        self.tableView?.reloadData()
        
        self.fetchProjectSlug(slug)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ics = self.identifierCounts {
            return ics.count
        } else {
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("identifierCount", forIndexPath: indexPath) as! IdentifierCountCell
        
        cell.selectionStyle = .None
        
        if let ics = self.identifierCounts {
            let ic = ics[indexPath.item]
            
            cell.userLoginLabel?.text = ic.user.login
            
            cell.identificationsCountLabel?.text = "Identifications: \(ic.identificationCount)"
            
            if let urlString = ic.user.iconUrl,
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
