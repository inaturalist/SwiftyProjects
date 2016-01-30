//
//  Taxon.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry

struct Taxon {
    let id: Int
    let scientificName: String
    let commonName: String?
    let rank: String
    let rankLevel: Int
    let taxonPhotoUrlString: String?
}

extension Taxon: Decodable {
    static func decode(j: JSON) -> Decoded<Taxon> {
        return curry(Taxon.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <|? "preferred_common_name"
            <*> j <| "rank"
            <*> j <| "rank_level"
            <*> j <|? ["default_photo", "square_url"]
    }
}
