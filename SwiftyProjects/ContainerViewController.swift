//
//  ContainerViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/1/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Argo
import Haneke

protocol ContainedScrollViewDelegate: class {
    func scrollViewDidScroll(scrollView: UIScrollView)
    func scrollViewDidEndScrolling(scrollView: UIScrollView)
}

protocol ObservedScrollView: UIScrollViewDelegate {
    weak var containedScrollViewDelegate: ContainedScrollViewDelegate? { get set }
}

protocol ProjectObservationVisualizer: class {
    func reload()
    func choseProjectSlug(slug: String)
}

class ContainerViewController: UIViewController, ContainedScrollViewDelegate {
    
    let maxHeight: CGFloat = 200
    let minHeight: CGFloat = 66

    var containedViewController: ContainedViewController?
    var distanceToTop: NSLayoutConstraint?
    var headerToTop: NSLayoutConstraint?
    
    @IBOutlet var observationsButton: UIButton?
    @IBOutlet var speciesButton: UIButton?
    @IBOutlet var observersButton: UIButton?
    @IBOutlet var projectsImageView: UIImageView?
    @IBOutlet var projectsExcerpt: UILabel?
    
    @IBOutlet var joinButton: UIButton?
    
    @IBOutlet var speciesContainerView: UIView?
    @IBOutlet var observationsContainerView: UIView?
    @IBOutlet var observersContainerView: UIView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.observationsButton?.setTitleColor(UIColor.greenColor(), forState: .Disabled)
        self.speciesButton?.setTitleColor(UIColor.greenColor(), forState: .Disabled)
        self.observersButton?.setTitleColor(UIColor.greenColor(), forState: .Disabled)
        
        self.observationsButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.speciesButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.observersButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)

        self.observationsButton?.enabled = false

        if let join = self.joinButton {
            join.layer.cornerRadius = join.bounds.size.height / 2.0
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchProject")
        self.choseProject("inat-observation-of-the-day")
    }
    
    // MARK: - UIEvent targets
    
    func searchProject() {
        let alert = UIAlertController(title: "choose new project", message: "enter a project slug or id. despite the icon, exact match is required. this ain't search.", preferredStyle: .Alert)
        var projectSlugField: UITextField?
        alert.addTextFieldWithConfigurationHandler { (tf: UITextField) -> Void in
            projectSlugField = tf
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
            print("text value is \(projectSlugField!.text)")
            if let field = projectSlugField,
                let slug = field.text {
                    
                    if slug != "" {
                        self.choseProject(slug)
                    }
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Project reset
    
    func choseProject(slug: String) {
        self.containedViewController?.choseProjectSlug(slug)
        
        // fetch the project and update some local UI
        let urlPath: String = "http://inaturalist.org/projects/\(slug).json"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if let d = data {
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(d, options: [])
                if let j = json, let project: Project = decode(j) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.title = project.title
                        self.projectsExcerpt?.text = project.desc
                        if let imageUrlString = project.iconUrl,
                            let imageUrl = NSURL(string: imageUrlString) {
                                self.projectsImageView?.hnk_setImageFromURL(imageUrl)
                        }                        
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: "JSON decode error", message: "Are you sure that's a valid project slug?", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            } else if let e = error {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "error", message: e.localizedDescription, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contained = segue.destinationViewController as? ContainedViewController {
            self.containedViewController = contained
            contained.containedScrollViewDelegate = self
        }
    }
    
    @IBAction private func choseObservations(sender: UIButton) {
        self.containedViewController?.choseObservations()
        
        self.observationsButton?.enabled = false
        self.speciesButton?.enabled = true
        self.observersButton?.enabled = true
    }
    
    @IBAction private func choseSpecies(sender: UIButton) {
        self.containedViewController?.choseSpecies()
        
        self.observationsButton?.enabled = true
        self.speciesButton?.enabled = false
        self.observersButton?.enabled = true
    }

    @IBAction private func choseObservers(sender: UIButton) {
        self.containedViewController?.choseObservers()
    
        self.observationsButton?.enabled = true
        self.speciesButton?.enabled = true
        self.observersButton?.enabled = false
    }

    
    // MARK: - ContainedScrollViewDelegate
    func scrollViewDidEndScrolling(scrollView: UIScrollView) {
        switch scrollView.contentOffset.y {
        case _ where scrollView.contentOffset.y > maxHeight - minHeight:
            return
        case _ where scrollView.contentOffset.y <= 0:
            return
            /*
        case _ where scrollView.contentOffset.y >= (maxHeight - minHeight) / 2:
            // scroll up to show only the header excerpt
            scrollView.setContentOffset(CGPoint(x: 0, y: maxHeight - minHeight), animated: true)
        case _ where scrollView.contentOffset.y < (maxHeight - minHeight) / 2:
            // scroll down to show the whole header
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            */
        default:
            // scroll down to show the whole header
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)

            print("ACK SHOULD NOT GET HERE")
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // should only need to do this once
        if distanceToTop == nil {
            for constraint in self.view.constraints {
                if constraint.identifier == "containerFromTop" {
                    self.distanceToTop = constraint
                }
            }
        }
        
        if headerToTop == nil {
            for constraint in self.view.constraints {
                if constraint.identifier == "headerToTop" {
                    self.headerToTop = constraint
                }
            }
        }
        
        // as the user scrolls down in the contained view, the size of the
        // contained view grows (within the container view) to a maximum
        if let distToTop = self.distanceToTop,
            let headToTop = self.headerToTop {
            let oldConstant = distToTop.constant
            
             if scrollView.contentOffset.y > maxHeight - minHeight {
                distToTop.constant = minHeight
            } else {
                distToTop.constant = maxHeight - scrollView.contentOffset.y
            }
            headToTop.constant = distToTop.constant
                
            if oldConstant != distToTop.constant {
                self.view.setNeedsLayout()
            }
        }
    }
}
