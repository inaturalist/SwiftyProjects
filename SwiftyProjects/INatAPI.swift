//
//  INatAPI.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 2/2/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry
import Foundation

class INatAPI {

    func fetch(path: String, callback: (json: AnyObject?, error: NSError?) -> Void) {
        let url: NSURL = NSURL(string: path)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if let err = error {
                callback(json: nil, error: err)
                return
            }
            
            if let d = data {
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(d, options: [])
                if let j = json {
                    callback(json: j, error: nil)
                    return
                }
            }
            
            callback(json: nil, error: NSError(domain: "json error?", code: 999, userInfo: nil))
        }
    }
    
    func fetchObservations(projectSlug: String, callback:(json: AnyObject?, error: NSError?) -> Void) {
        self.fetch("https://api.inaturalist.org/observations?project_id=\(projectSlug)&per_page=200") { (json, error) -> Void in
            if let e = error {
                callback(json: nil, error: e)
            } else if let j = json {
                callback(json: j, error: nil)
            }
        }
    }
    
    func fetchIdentifiers(projectSlug: String, callback:(json: AnyObject?, error: NSError?) -> Void) {
        self.fetch("http://api.inaturalist.org/observations/identifiers?project_id=\(projectSlug)") { (json, error) -> Void in
            if let e = error {
                callback(json: nil, error: e)
            } else if let j = json {
                callback(json: j, error: nil)
            }
        }
    }

    func fetchObservers(projectSlug: String, callback:(json: AnyObject?, error: NSError?) -> Void) {
        self.fetch("http://api.inaturalist.org/observations/observers?project_id=\(projectSlug)") { (json, error) -> Void in
            if let e = error {
                callback(json: nil, error: e)
            } else if let j = json {
                callback(json: j, error: nil)
            }
        }
    }
    
    func fetchSpecies(projectSlug: String, callback:(json: AnyObject?, error: NSError?) -> Void) {
        self.fetch("http://api.inaturalist.org/observations/species_counts?project_id=\(projectSlug)") { (json, error) -> Void in
            if let e = error {
                callback(json: nil, error: e)
            } else if let j = json {
                callback(json: j, error: nil)
            }
        }
    }

}
