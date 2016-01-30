//
//  ProjectsViewModel.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Argo
import Haneke

enum ProjectDetailSection {
    case Observations
    case Species
    case Observers
}

protocol ProjectsViewModelDelegate {
    func selectedSection(section: ProjectDetailSection) -> Void
    func activeSection() -> ProjectDetailSection
    func reloadData() -> Void
}

class ProjectsViewModel: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var headerTableView: UITableView

    var delegate: ProjectsViewModelDelegate?
    
    var projectSlug: String?
    var project: Project?
    
    var observations: [Observation]?
    var taxonCounts: [TaxonCount]?
    var userCounts: [UserCount]?
    
    var observationsTotal: Int
    var speciesTotal: Int
    var observersTotal: Int
    
    override init() {
        headerTableView = UITableView(frame: CGRectZero, style: .Plain)
        
        observationsTotal = 0
        speciesTotal = 0
        observersTotal = 0
        
        super.init()
        
        headerTableView.backgroundColor = UIColor.orangeColor()
        headerTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        headerTableView.delegate = self
        headerTableView.dataSource = self
        headerTableView.scrollEnabled = false
        
        if self.projectSlug != nil && self.projectSlug != "" {
            self.fetch()
        }
    }
    
    // MARK: uibutton targets
    func speciesAction() {
        if let d = self.delegate {
            d.selectedSection(.Species)
        }
    }
    
    func observationsAction() {
        if let d = self.delegate {
            d.selectedSection(.Observations)
        }
    }
    
    func observersAction() {
        if let d = self.delegate {
            d.selectedSection(.Observers)
        }
    }

    
    // MARK: - UITableView data source / delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == headerTableView {
            if (indexPath.item == 0) {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
                
                cell.selectionStyle = .None

                cell.viewWithTag(99)?.removeFromSuperview()
                cell.viewWithTag(98)?.removeFromSuperview()
                cell.viewWithTag(97)?.removeFromSuperview()
                
                cell.backgroundColor = UIColor.whiteColor()
                
                let iv = UIImageView(frame: CGRectZero)
                iv.tag = 99
                iv.translatesAutoresizingMaskIntoConstraints = false
                iv.contentMode = .ScaleAspectFill
                cell.contentView.addSubview(iv)
                
                let field = UILabel(frame: CGRectZero)
                field.tag = 98
                field.translatesAutoresizingMaskIntoConstraints = false
                field.font = UIFont.systemFontOfSize(12)
                field.textColor = UIColor.grayColor()
                field.numberOfLines = 3
                cell.contentView.addSubview(field)
                
                let views = [
                    "iv": iv,
                    "field": field,
                ]
                
                cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-15-[iv(==50)]-12-[field]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
                cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[iv(==50)]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
                cell.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[field(==50)]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

                dispatch_after(1, dispatch_get_main_queue(), { () -> Void in
                    if let project = self.project {
                        if let imageUrlString = project.iconUrl,
                            let imageUrl = NSURL(string: imageUrlString) {
                                
                                iv.hnk_setImageFromURL(imageUrl)
                        }
                        
                        field.text = project.desc
                    }
                })

                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
                
                cell.selectionStyle = .None

                cell.viewWithTag(99)?.removeFromSuperview()
                cell.viewWithTag(98)?.removeFromSuperview()
                cell.viewWithTag(97)?.removeFromSuperview()

                cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                
                let speciesButton = UIButton(type: .System)
                speciesButton.tag = 99
                speciesButton.frame = CGRectZero
                speciesButton.translatesAutoresizingMaskIntoConstraints = false
                speciesButton.setTitle("\(self.speciesTotal)\nSpecies", forState: .Normal)
                speciesButton.titleLabel?.numberOfLines = 2
                speciesButton.addTarget(self, action: "speciesAction", forControlEvents: .TouchUpInside)
                speciesButton.backgroundColor = UIColor.whiteColor()
                cell.contentView.addSubview(speciesButton)
                
                let observationsButton = UIButton(type: .System)
                observationsButton.tag = 98
                observationsButton.frame = CGRectZero
                observationsButton.translatesAutoresizingMaskIntoConstraints = false
                observationsButton.setTitle("\(self.observationsTotal)\nObservations", forState: .Normal)
                observationsButton.titleLabel?.numberOfLines = 2
                observationsButton.addTarget(self, action: "observationsAction", forControlEvents: .TouchUpInside)
                observationsButton.backgroundColor = UIColor.whiteColor()
                cell.contentView.addSubview(observationsButton)
                
                let observersButton = UIButton(type: .System)
                observersButton.tag = 97
                observersButton.frame = CGRectZero
                observersButton.translatesAutoresizingMaskIntoConstraints = false
                observersButton.setTitle("\(self.observersTotal)\nObservers", forState: .Normal)
                observersButton.titleLabel?.numberOfLines = 2
                observersButton.addTarget(self, action: "observersAction", forControlEvents: .TouchUpInside)
                observersButton.backgroundColor = UIColor.whiteColor()
                cell.contentView.addSubview(observersButton)
                
                if let d = self.delegate {
                    switch d.activeSection() {
                    case .Observations:
                        speciesButton.enabled = true
                        observationsButton.enabled = false
                        observersButton.enabled = true
                    case .Species:
                        speciesButton.enabled = false
                        observationsButton.enabled = true
                        observersButton.enabled = true
                    case .Observers:
                        speciesButton.enabled = true
                        observationsButton.enabled = true
                        observersButton.enabled = false
                    }
                }
                
                let views = [
                    "species": speciesButton,
                    "observations": observationsButton,
                    "observers": observersButton,
                ]
                
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[observations]-0-[species(==observations)]-0-[observers(==species)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
                
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[observations]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[species]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[observers]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

                
                return cell
            }

        } else {
            
            if let d = self.delegate {
                if d.activeSection() == .Species {
                    return self.taxonCell(tableView, forIndexPath: indexPath)
                } else if d.activeSection() == .Observers {
                    return self.userCell(tableView, forIndexPath: indexPath)
                }
            }
        }
        
        // ugh this is ugly
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.viewWithTag(99)?.removeFromSuperview()
        cell.viewWithTag(98)?.removeFromSuperview()
        cell.viewWithTag(97)?.removeFromSuperview()
        
        return cell
    }
    
    func taxonCell(inTableView: UITableView, forIndexPath: NSIndexPath) -> TaxonCountCell {
        let cell = inTableView.dequeueReusableCellWithIdentifier("taxonCount", forIndexPath: forIndexPath) as! TaxonCountCell
        
        cell.selectionStyle = .None

        if let tcs = self.taxonCounts {
            let tc = tcs[forIndexPath.item]
            
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
    
    func userCell(inTableView: UITableView, forIndexPath: NSIndexPath) -> UserCountCell {
        let cell = inTableView.dequeueReusableCellWithIdentifier("userCount", forIndexPath: forIndexPath) as! UserCountCell
        
        cell.selectionStyle = .None
        
        if let ucs = self.userCounts {
            let uc = ucs[forIndexPath.item]
            
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == headerTableView {
            return 2
        } else {
            if let d = self.delegate {
                if d.activeSection() == .Species {
                    if let taxaCounts = self.taxonCounts {
                        return taxaCounts.count
                    }
                } else if d.activeSection() == .Observers {
                    if let userCounts = self.userCounts {
                        return userCounts.count
                    }
                }
            }
        }

        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView != headerTableView {
            return 120
        } else {
            return 0.0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == headerTableView {
            if indexPath.item == 0 {
                return 66
            } else {
                return 120 - 66
            }
        } else {
            return 60.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != headerTableView {
            if let d = self.delegate {
                if d.activeSection() == .Species || d.activeSection() == .Observers {
                    headerTableView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 100.0)
                    headerTableView.reloadData()
                    return headerTableView
                }
            }
        }
        return nil
    }
    
    // MARK: - UICollectionView data source / delegate
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ObsCell
        
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let obs = self.observations {
            return obs.count
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath)
        
        if let d = self.delegate {
            if d.activeSection() == .Observations {
                self.headerTableView.frame = view.bounds
                self.headerTableView.reloadData()
                view.addSubview(self.headerTableView)
            }
        }
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 120)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let side = (collectionView.bounds.size.width / 3) - 1.0
        return CGSize(width: side, height: side)
    }
    
    // MARK: - iNat API stuff
    
    func fetch() {
        // clear local content
        self.observations = nil
        self.taxonCounts = nil
        
        // reset UI to empty
        self.delegate?.reloadData()
        
        // fetch from iNat
        self.fetchObservations()
        self.fetchObservers()
        self.fetchSpecies()
    }
    
    func fetchObservations() {
        
        guard let slug = self.projectSlug else {
            return
        }
        
        let urlPath: String = "https://api.inaturalist.org/observations?project_id=\(slug)&per_page=200"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if let d = data {
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(d, options: [])
                if let j = json {
                    if let count = j["total_results"] as? Int {
                        self.observationsTotal = count
                    }
                    let array: [Observation]? = decodeWithRootKey("results", j)
                    self.observations = array
                    dispatch_async(dispatch_get_main_queue(), {
                        if let d = self.delegate {
                            d.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    func fetchObservers() {
        guard let slug = self.projectSlug else {
            return
        }

        let urlPath: String = "http://api.inaturalist.org/observations/observers?project_id=\(slug)"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if let d = data {
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(d, options: [])
                if let j = json {
                    if let count = j["total_results"] as? Int {
                        self.observersTotal = count
                    }
                    let array: [UserCount]? = decodeWithRootKey("results", j)
                    self.userCounts = array
                    dispatch_async(dispatch_get_main_queue(), {
                        if let d = self.delegate {
                            d.reloadData()
                        }
                    })
                }
            }
        }

    }
    
    func fetchSpecies() {
        guard let slug = self.projectSlug else {
            return
        }

        let urlPath: String = "http://api.inaturalist.org/observations/species_counts?project_id=\(slug)"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if let d = data {
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(d, options: [])
                if let j = json {
                    if let count = j["total_results"] as? Int {
                        self.speciesTotal = count
                    }
                    let array: [TaxonCount]? = decodeWithRootKey("results", j)
                    self.taxonCounts = array
                    dispatch_async(dispatch_get_main_queue(), {
                        if let d = self.delegate {
                            d.reloadData()
                        }
                    })
                }
            }
        }
    }
}

