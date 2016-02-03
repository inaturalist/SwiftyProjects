//
//  ProjectSpeciesViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/2/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Argo
import Curry

class ProjectSpeciesViewController: UITableViewController, ObservedScrollView, ProjectObservationVisualizer {

    var taxonCounts: [TaxonCount]?
    var speciesTotal: Int = 0
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
        // fetch tpwd
        let api = INatAPI()
        api.fetchSpecies(slug) { (json, error) -> Void in
            if let j = json {
                if let count = j["total_results"] as? Int {
                    self.speciesTotal = count
                }
                let array: [TaxonCount]? = decodeWithRootKey("results", j)
                self.taxonCounts = array
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
        
        self.taxonCounts?.removeAll()
        self.speciesTotal = 0
        self.tableView?.reloadData()
        
        self.fetchProjectSlug(slug)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tcs = self.taxonCounts {
            return tcs.count
        } else {
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taxonCount", forIndexPath: indexPath) as! TaxonCountCell
        
        cell.selectionStyle = .None
        
        if let tcs = self.taxonCounts {
            let tc = tcs[indexPath.item]
            
            var scientificName: String?
            if tc.taxon.rankLevel >= 20 {
                scientificName = "\(tc.taxon.rank.capitalizedString) \(tc.taxon.scientificName)"
            } else {
                scientificName = tc.taxon.scientificName
            }
            
            if let commonName = tc.taxon.commonName {
                cell.taxonMainNameLabel?.text = commonName
                cell.taxonSecondaryNameLabel?.text = scientificName
                if tc.taxon.rankLevel < 30 {
                    if let pointSize = cell.taxonSecondaryNameLabel?.font.pointSize {
                        cell.taxonSecondaryNameLabel?.font = UIFont.italicSystemFontOfSize(pointSize)
                    }
                }
            } else {
                cell.taxonMainNameLabel?.text = scientificName
                if tc.taxon.rankLevel < 30 {
                    if let pointSize = cell.taxonMainNameLabel?.font.pointSize {
                        cell.taxonMainNameLabel?.font = UIFont.italicSystemFontOfSize(pointSize)
                    }
                }
                cell.taxonSecondaryNameLabel?.text = ""
            }
            
            cell.countLabel?.text = "\(tc.count)"
            if let urlString = tc.taxon.taxonPhotoUrlString,
                let url = NSURL(string: urlString) {
                    
                    cell.taxonImageView?.hnk_setImageFromURL(url)
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


