//
//  ContainerViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/1/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit

protocol ContainedScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView)
}

class ContainerViewController: UIViewController, ContainedScrollViewDelegate {
    
    var containedViewController: ContainedViewController?
    var distanceToTop: NSLayoutConstraint?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tabBarItem.title = "varaible height container"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let contained = segue.destinationViewController as? ContainedViewController {
            self.containedViewController = contained
            contained.containedScrollViewDelegate = self
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
        
        // as the user scrolls down in the contained view, the size of the
        // contained view grows (within the container view) to a maximum
        if let constraint = self.distanceToTop {
            let oldConstant = constraint.constant
            
            let maxHeight: CGFloat = 200
            let minHeight: CGFloat = 44
            
             if scrollView.contentOffset.y > maxHeight - minHeight {
                constraint.constant = minHeight
            } else {
                constraint.constant = maxHeight - scrollView.contentOffset.y
            }
            
            if oldConstant != constraint.constant {
                self.view.setNeedsLayout()
            }
            
        }
        
    }
}
