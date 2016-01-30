//
//  TaxonCount.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import Argo
import Curry

struct TaxonCount {
    let taxon: Taxon
    let count: Int
}

extension TaxonCount: Decodable {
    static func decode(j: JSON) -> Decoded<TaxonCount> {
        return curry(TaxonCount.init)
            <^> j <| "taxon"
            <*> j <| "count"
    }
}
