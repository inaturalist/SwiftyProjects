//
//  ContainedViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/1/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit

class ContainedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var containedScrollViewDelegate: ContainedScrollViewDelegate?
    
    override func viewDidLoad() {
        let tv = UITableView(frame: CGRectZero, style: .Plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        tv.backgroundColor = UIColor.clearColor()
        
        tv.delegate = self
        tv.dataSource = self
        tv.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tv)
        let views = ["tv": tv ]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[tv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[tv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.containedScrollViewDelegate?.scrollViewDidScroll(scrollView)
        
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .min
    }
    
}
