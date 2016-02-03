//
//  ProjectObservationsViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/2/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Argo



class ProjectObservationsViewController: UICollectionViewController, ObservedScrollView, ProjectObservationVisualizer, UICollectionViewDelegateFlowLayout {
    
    var observations: [Observation]?
    var observationTotal: Int = 0
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
        api.fetchObservations(slug) { (json, error) -> Void in
            if let j = json {
                if let count = j["total_results"] as? Int {
                    self.observationTotal = count
                }
                let array: [Observation]? = decodeWithRootKey("results", j)
                self.observations = array
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView?.reloadData()
                })
            }
        }
    }
    
    // MARK: - ProjectObservationVisualizer
    
    func reload() {
        self.collectionView?.reloadData()
    }
    
    func choseProjectSlug(slug: String) {
        if slug == self.slug {
            return
        }
        
        self.observations?.removeAll()
        self.observationTotal = 0
        self.collectionView?.reloadData()
        
        self.fetchProjectSlug(slug)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let obs = self.observations {
            return obs.count
        } else {
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("observation", forIndexPath: indexPath) as! ObsCell
        
        if let obs = self.observations {
            let o = obs[indexPath.item]
            
            if let taxon = o.taxon {
                if let commonName = taxon.commonName {
                    cell.label?.text = commonName
                } else {
                    if taxon.rankLevel < 30 {
                        if let pointSize = cell.label?.font.pointSize {
                            cell.label?.font = UIFont.italicSystemFontOfSize(pointSize)
                        }
                    }
                    
                    var scientificName: String?
                    if taxon.rankLevel >= 20 {
                        scientificName = "\(taxon.rank.capitalizedString) \(taxon.scientificName)"
                    } else {
                        scientificName = taxon.scientificName
                    }
                    cell.label?.text = scientificName
                }
            } else {
                cell.label?.text = o.speciesGuess
            }
            
            if let photos = o.photos {
                if photos.count > 0 {
                    if let photo = photos.first,
                        let url = NSURL(string: photo.urlString) {
                            // chain loading first a crappy square thumb, then a medium size image
                            cell.imageView?.hnk_setImageFromURL(url, placeholder: nil, format: nil, failure: nil, success: { (image: UIImage) -> () in
                                let medUrlString = photo.urlString.stringByReplacingOccurrencesOfString("square", withString: "medium")
                                if let medUrl = NSURL(string: medUrlString) {
                                    cell.imageView?.hnk_setImageFromURL(medUrl)
                                }
                            })
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // nothing for now
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let side = (collectionView.bounds.size.width / 3) - 1.0
        return CGSize(width: side, height: side)
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
