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

class ContainedViewController: UIViewController {
    
    let SegueIdentifierObservations = "embedObservations"
    let SegueIdentifierSpecies = "embedSpecies"
    let SegueIdentifierObservers = "embedObservers"
    
    var currentSegueIdentifier: String?
    
    weak var containedScrollViewDelegate: ContainedScrollViewDelegate?
    
    var children = [UIViewController]()
    
    // MARK: - pass messages from the containing observation down to the children
    
    func reloadChildren() {
        for child in children {
            if let visualizer = child as? ProjectObservationVisualizer {
                visualizer.reload()
            }
        }
    }
    
    func choseProjectSlug(slug: String) {
        for child in children {
            if let visualizer = child as? ProjectObservationVisualizer {
                visualizer.choseProjectSlug(slug)
            }
        }
    }
    
    // MARK: - switching among child containers
    
    func choseObservations() {
        self.performSegueWithIdentifier(SegueIdentifierObservations, sender: nil)
    }
    
    func choseObservers() {
        self.performSegueWithIdentifier(SegueIdentifierObservers, sender: nil)
    }
    
    func choseSpecies() {
        self.performSegueWithIdentifier(SegueIdentifierSpecies, sender: nil)
    }
    
    
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier(SegueIdentifierObservations, sender: nil)
    }
    
    // MARK: - the container stuff is all handled via this prepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.currentSegueIdentifier == segue.identifier {
            return
        }
        
        self.currentSegueIdentifier = segue.identifier
        
        var destinationVC = segue.destinationViewController
        // if we already have a child of this class, use that instead
        for child in children {
            if child.dynamicType === destinationVC.dynamicType {
                destinationVC = child
            }
        }
        
        if !children.contains(destinationVC) {
            self.children.append(destinationVC)
        }

        if let observedVC = destinationVC as? ObservedScrollView {
            observedVC.containedScrollViewDelegate = self.containedScrollViewDelegate
        }
        
        if let id = segue.identifier where id == SegueIdentifierObservations {
            if let first = self.childViewControllers.first {
                self.swapFromViewController(first, toViewController: destinationVC)
            } else {
                // setup first child VC
                self.addChildViewController(destinationVC)
                destinationVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.view.addSubview(destinationVC.view)
                destinationVC.didMoveToParentViewController(self)
            }
        } else {
            // swap from top VC to segue destination
            if let first = self.childViewControllers.first {
                self.swapFromViewController(first, toViewController: destinationVC)
            }
        }
    }
    
    func swapFromViewController(fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.33, options: .TransitionCrossDissolve, animations: nil) { (finished) -> Void in
            fromViewController.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
        }
    }
}
