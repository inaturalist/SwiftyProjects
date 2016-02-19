//
//  RootViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/18/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Haneke

let offset_HeaderStop:CGFloat = 200 // At this offset the Header stops its transformations

class RootViewController: UIViewController {
    @IBOutlet var header: UIView?
    @IBOutlet var label: UILabel?
    @IBOutlet var projectImageView: UIImageView?
    @IBOutlet var blurredProjectImageView: UIImageView?
    
    @IBOutlet var container: UIView?
    
    @IBOutlet var joinButton: UIButton?
    @IBOutlet var newsButton: UIButton?
    @IBOutlet var aboutButton: UIButton?
    
    override func viewDidLoad() {
        self.label?.text = "iNat Observation of the Day"
        
        self.projectImageView?.layer.cornerRadius = 2.0
        self.projectImageView?.layer.borderColor = UIColor.whiteColor().CGColor
        self.projectImageView?.layer.borderWidth = 1.0
        
        if let blurredImage = self.blurredProjectImageView {
            let blurEffect = UIBlurEffect(style: .Dark)
            let effectView = UIVisualEffectView(effect: blurEffect)
            effectView.frame = blurredImage.bounds
            blurredImage.addSubview(effectView)
        }
        
        if let url = NSURL(string: "http://www.inaturalist.org/attachments/projects/icons/5358/span2/logo_ootd_icon.png?1454027048") {
            self.projectImageView?.hnk_setImageFromURL(url)
            self.blurredProjectImageView?.hnk_setImageFromURL(url)
        }
        
        if let join = self.joinButton {
            join.layer.cornerRadius = join.bounds.size.height / 2.0
            join.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            join.tintColor = UIColor.whiteColor()
            join.setTitle("JOIN", forState: .Normal)
        }
        
        if let news = self.newsButton {
            news.layer.cornerRadius = news.bounds.size.height / 2.0
            news.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            news.tintColor = UIColor.whiteColor()
            news.setTitle("NEWS", forState: .Normal)
        }

        if let about = self.aboutButton {
            about.layer.cornerRadius = about.bounds.size.height / 2.0
            about.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            about.tintColor = UIColor.whiteColor()
            about.setTitle("ABOUT", forState: .Normal)
        }
    }
    
    func adjustHeaderTransformForOffset(offset: CGFloat) {
        UIView.animateWithDuration(0.3) { () -> Void in
            if let header = self.header {
                header.layer.transform = CATransform3DIdentity
            }
            
            for constraint in self.view.constraints {
                if constraint.identifier == "containerToTop" {
                    constraint.constant = 200
                    self.view.layoutIfNeeded()
                }
            }
        }

        return
        
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if let header = self.header {
            if offset < 0 {
                
                header.layer.transform = headerTransform
                /*
                let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
                let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
                headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
                
                header.layer.transform = headerTransform
                */
            }
                
                // SCROLL UP/DOWN ------------
                
            else {
                
                // Header -----------
                
                headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
                
                // Apply Transformations
                
                header.layer.transform = headerTransform
                
                for constraint in self.view.constraints {
                    if constraint.identifier == "containerToTop" {
                        let previousConstant = constraint.constant
                        
                        let headerTy = max(-offset_HeaderStop, -offset)
                        let newConstant = 200 + headerTy
                        
                        //let newConstant = min(max(previousConstant + max(-offset_HeaderStop, -offset), 0), 200)
                        if (previousConstant != newConstant) {
                            constraint.constant = newConstant
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndScrolling(scrollView: UIScrollView) {

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if let header = self.header {
            if offset < 0 {
                
                header.layer.transform = headerTransform
                /*
                let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
                let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
                headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
                
                header.layer.transform = headerTransform
                */
            }
                
                // SCROLL UP/DOWN ------------
                
            else {
                
                // Header -----------
                
                headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
                
                // Apply Transformations
                
                header.layer.transform = headerTransform
                
                for constraint in self.view.constraints {
                    if constraint.identifier == "containerToTop" {
                        let previousConstant = constraint.constant
                        
                        let headerTy = max(-offset_HeaderStop, -offset)
                        let newConstant = 200 + headerTy
                        
                        //let newConstant = min(max(previousConstant + max(-offset_HeaderStop, -offset), 0), 200)
                        if (previousConstant != newConstant) {
                            constraint.constant = newConstant
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
            
        }
    }
}
