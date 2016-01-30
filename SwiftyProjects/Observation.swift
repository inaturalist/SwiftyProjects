//
//  Observation.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit

import Argo
import Curry

struct Observation {
    let id: Int
    let speciesGuess: String?
    let taxon: Taxon?
    let photos: [Photo]?
}

extension Observation: Decodable {
    static func decode(j: JSON) -> Decoded<Observation> {
        return curry(Observation.init)
            <^> j <| "id"
            <*> j <|? "species_guess"
            <*> j <|? "taxon"
            <*> j <||? "photos"

    }
}

