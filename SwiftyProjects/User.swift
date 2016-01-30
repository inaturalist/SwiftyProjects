//
//  User.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/30/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry

struct User {
    let id: Int
    let login: String
    let iconUrl: String?
}

extension User: Decodable {
    static func decode(j: JSON) -> Decoded<User> {
        return curry(User.init)
            <^> j <| "id"
            <*> j <| "login"
            <*> j <|? "icon_url"

    }
}
