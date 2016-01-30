//
//  ObservationPhoto.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit


import Argo
import Curry

struct Photo {
    let id: Int
    let urlString: String
}

extension Photo: Decodable {
    static func decode(j: JSON) -> Decoded<Photo> {
        return curry(Photo.init)
            <^> j <| "id"
            <*> j <| "url"        
    }
}


