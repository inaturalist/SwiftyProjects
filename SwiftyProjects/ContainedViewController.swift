//
//  ContainedViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/1/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry
import UIKit

class ContainedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var containedScrollViewDelegate: ContainedScrollViewDelegate?
    var tv: UITableView?
    var inatAPI: INatAPI?
    
    var taxonCounts: [TaxonCount]?
    var speciesTotal: Int = 0
    
    override func viewDidLoad() {
        
        self.title = "All Texas Nature"
        
        let tv = UITableView(frame: CGRectZero, style: .Plain)
        self.tv = tv
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        tv.backgroundColor = UIColor.clearColor()
        
        tv.delegate = self
        tv.dataSource = self
        tv.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tv)
        let views = ["tv": tv ]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[tv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[tv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // fetch tpwd
        let api = INatAPI()
        api.fetchSpecies("all-texas-nature") { (json, error) -> Void in
            if let j = json {
                if let count = j["total_results"] as? Int {
                    self.speciesTotal = count
                }
                let array: [TaxonCount]? = decodeWithRootKey("results", j)
                self.taxonCounts = array
                dispatch_async(dispatch_get_main_queue(), {
                    self.tv?.reloadData()
                })
            }
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tc = self.taxonCounts {
            return tc.count
        } else {
            return 0
        }
    }
    
    func taxonCell(inTableView: UITableView, forIndexPath: NSIndexPath) -> UITableViewCell {
        let cell = inTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: forIndexPath)
        
        cell.selectionStyle = .None
        cell.textLabel?.textColor = UIColor.grayColor()
        
        cell.imageView?.image = UIImage(named: "small.jpg")
        
        if let tcs = self.taxonCounts {
            let tc = tcs[forIndexPath.item]
            
            var scientificName: String?
            if tc.taxon.rankLevel >= 20 {
                scientificName = "\(tc.taxon.rank.capitalizedString) \(tc.taxon.scientificName)"
            } else {
                scientificName = tc.taxon.scientificName
            }
            
            if let commonName = tc.taxon.commonName {
                cell.textLabel?.text = commonName
            } else {
                cell.textLabel?.text = scientificName
                if tc.taxon.rankLevel < 30 {
                    if let pointSize = cell.textLabel?.font.pointSize {
                        cell.textLabel?.font = UIFont.italicSystemFontOfSize(pointSize)
                    }
                }
            }
            
            cell.imageView?.clipsToBounds = true
            cell.imageView?.contentMode = .ScaleAspectFill
            
        }
        
        return cell
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.taxonCell(tableView, forIndexPath: indexPath)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.containedScrollViewDelegate?.scrollViewDidScroll(scrollView)
        
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.containedScrollViewDelegate?.scrollViewDidEndScrolling(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.containedScrollViewDelegate?.scrollViewDidEndScrolling(scrollView)
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .min
    }
    
}
