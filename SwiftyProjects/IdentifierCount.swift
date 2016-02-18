//
//  IdentifierCount.swift
//  ProjectsViewPager
//
//  Created by Alex Shepard on 2/18/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry

struct IdentifierCount {
    let user: User
    let identificationCount: Int
}

extension IdentifierCount: Decodable {
    static func decode(j: JSON) -> Decoded<IdentifierCount> {
        return curry(IdentifierCount.init)
            <^> j <| "user"
            <*> j <| "count"        
    }
}
