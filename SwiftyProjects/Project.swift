//
//  Project.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/30/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry

struct Project {
    let id: Int
    let title: String
    let desc: String?
    let iconUrl: String?
}

extension Project: Decodable {
    static func decode(j: JSON) -> Decoded<Project> {
        return curry(Project.init)
            <^> j <| "id"
            <*> j <| "title"
            <*> j <|? "description"
            <*> j <|? "icon_url"
    }
}
