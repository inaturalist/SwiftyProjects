//
//  ViewController.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Argo

class ViewController: UIViewController, ProjectsViewModelDelegate {
    
    var _section: ProjectDetailSection
    
    var viewModel: ProjectsViewModel
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var collectionView: UICollectionView?
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = ProjectsViewModel()
        self._section = .Observations
        
        super.init(coder: aDecoder)
        
        self.viewModel.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchProject")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView?.dataSource = self.viewModel
        self.tableView?.delegate = self.viewModel
        self.collectionView?.dataSource = self.viewModel
        self.collectionView?.delegate = self.viewModel
        self.collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.tableView?.backgroundColor = UIColor.whiteColor()
        
        self.tableView?.scrollsToTop = true
        self.choseProject("inat-observation-of-the-day")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                        self.viewModel.project = project
                        self.reloadData()
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

        // notify the viewmodel that we've got a new project and it's time to update the UI its responsible for
        self.viewModel.projectSlug = slug
        self.viewModel.fetch()
    }
    
    // MARK: - ProjectViewModelDelegate
    
    func activeSection() -> ProjectDetailSection {
        return _section
    }
    
    func selectedSection(section: ProjectDetailSection) {
        _section = section
        
        switch section {
        case .Observations:
            self.tableView?.hidden = true
            self.collectionView?.hidden = false
            self.tableView?.reloadData()
            self.collectionView?.reloadData()
        case .Species:
            self.collectionView?.hidden = true
            self.tableView?.hidden = false
            self.tableView?.reloadData()
            self.collectionView?.reloadData()
        case .Observers:
            self.collectionView?.hidden = true
            self.tableView?.hidden = false
            self.tableView?.reloadData()
            self.collectionView?.reloadData()
        }
    }
    
    func reloadData() {
        self.collectionView?.reloadData()
        self.tableView?.reloadData()
    }
}

