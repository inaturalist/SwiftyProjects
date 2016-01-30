//
//  UserCount.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/30/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry

struct UserCount {
    let user: User
    let observationCount: Int
    let speciesCount: Int
}

extension UserCount: Decodable {
    static func decode(j: JSON) -> Decoded<UserCount> {
        return curry(UserCount.init)
            <^> j <| "user"
            <*> j <| "observation_count"
            <*> j <| "species_count"

    }
}
