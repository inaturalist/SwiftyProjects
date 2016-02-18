//
//  ViewController.swift
//  ProjectsViewPager
//
//  Created by Alex Shepard on 2/17/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import ICViewPager

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

protocol ProjectObservationDelegate: class {
    func reload()
}

class ViewController: ViewPagerController {
    
    var observationsVC: ProjectObservationsViewController?
    var speciesVC: ProjectSpeciesViewController?
    var observersVC: ProjectObserversViewController?
    var identifiersVC: ProjectIdentifiersViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.observationsVC = self.storyboard?.instantiateViewControllerWithIdentifier("observations") as? ProjectObservationsViewController
        self.speciesVC = self.storyboard?.instantiateViewControllerWithIdentifier("species") as? ProjectSpeciesViewController
        self.observersVC = self.storyboard?.instantiateViewControllerWithIdentifier("observers") as? ProjectObserversViewController
        self.identifiersVC = self.storyboard?.instantiateViewControllerWithIdentifier("identifiers") as? ProjectIdentifiersViewController
        
        self.dataSource = self
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: ViewPagerDelegate {
    func viewPager(viewPager: ViewPagerController!, valueForOption option: ViewPagerOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .CenterCurrentTab:
            return 1.0
        case .TabHeight:
            return 60
        case .TabWidth:
            return viewPager.view.bounds.size.width / 3.5
        default:
            return value
        }
    }
}

extension ViewController: ViewPagerDataSource {

    func numberOfTabsForViewPager(viewPager: ViewPagerController!) -> UInt {
        return 4
    }
    
    func viewPager(viewPager: ViewPagerController!, viewForTabAtIndex index: UInt) -> UIView! {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: viewPager.view.bounds.size.width / 4, height: 80))
        
        let slug = "inat-observation-of-the-day"
        let api = INatAPI()

        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(14)
        
        switch index {
        case 0:
            label.text = "Observations"
            api.fetchObservations(slug) { (json, error) -> Void in
                if let j = json {
                    if let count = j["total_results"] as? Int where count > 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            label.text = "\(count)\nObservations"
                        })
                    }
                }
            }
        case 1:
            label.text = "Species"
            api.fetchSpecies(slug) { (json, error) -> Void in
                if let j = json {
                    if let count = j["total_results"] as? Int where count > 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            label.text = "\(count)\nSpecies"
                        })
                    }
                }
            }
        case 2:
            label.text = "Observers"
            api.fetchObservers(slug) { (json, error) -> Void in
                if let j = json {
                    if let count = j["total_results"] as? Int where count > 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            label.text = "\(count)\nObservers"
                        })
                    }
                }
            }
        case 3:
            label.text = "Identifiers"
            api.fetchIdentifiers(slug) { (json, error) -> Void in
                if let j = json {
                    if let count = j["total_results"] as? Int where count > 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            label.text = "\(count)\nIdentifiers"
                        })
                    }
                }
            }
        default:
            label.text = ""
        }
        
        view.addSubview(label)
        
        let views = ["label": label]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

        return view
    }
    
    func viewPager(viewPager: ViewPagerController!, contentViewControllerForTabAtIndex index: UInt) -> UIViewController! {
        switch index {
        case 0:
            if let dvc = self.observationsVC {
                return dvc
            } else {
                return UIViewController(nibName: nil, bundle: nil)
            }
        case 1:
            if let dvc = self.speciesVC {
                return dvc
            } else {
                return UIViewController(nibName: nil, bundle: nil)
            }
        case 2:
            if let dvc = self.observersVC {
                return dvc
            } else {
                return UIViewController(nibName: nil, bundle: nil)
            }
        case 3:
            if let dvc = self.identifiersVC {
                return dvc
            } else {
                return UIViewController(nibName: nil, bundle: nil)
            }
        default:
            return UIViewController(nibName: nil, bundle: nil)
        }
    }
}


