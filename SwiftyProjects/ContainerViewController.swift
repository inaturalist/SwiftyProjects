//
//  ContainerViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/1/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit

import Haneke

protocol ContainedScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView)
    func scrollViewDidEndScrolling(scrollView: UIScrollView)
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
    
    @IBOutlet var joinButton: UIButton?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tabBarItem.title = "varaible height container"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.observationsButton?.titleLabel?.numberOfLines = 2
        self.observationsButton?.setTitle("1320\nObservations", forState: .Normal)
        
        self.speciesButton?.titleLabel?.numberOfLines = 2
        self.speciesButton?.setTitle("1320\nSpecies", forState: .Normal)

        self.observersButton?.titleLabel?.numberOfLines = 2
        self.observersButton?.setTitle("1320\nObservers", forState: .Normal)
        
        
        if let join = self.joinButton {
            join.layer.cornerRadius = join.bounds.size.height / 2.0
        }
        
        if let url = NSURL(string: "http://www.inaturalist.org/attachments/projects/icons/1756/span2/Screen_Shot_2014-04-07_at_6.46.11_PM.png") {
            self.projectsImageView?.hnk_setImageFromURL(url)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contained = segue.destinationViewController as? ContainedViewController {
            self.containedViewController = contained
            contained.containedScrollViewDelegate = self
        }
    }
    
    func scrollViewDidEndScrolling(scrollView: UIScrollView) {
        switch scrollView.contentOffset.y {
        case _ where scrollView.contentOffset.y > maxHeight - minHeight:
            return
        case _ where scrollView.contentOffset.y <= 0:
            return
        case _ where scrollView.contentOffset.y >= (maxHeight - minHeight) / 2:
            scrollView.setContentOffset(CGPoint(x: 0, y: maxHeight - minHeight), animated: true)

        case _ where scrollView.contentOffset.y < (maxHeight - minHeight) / 2:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        default:
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
