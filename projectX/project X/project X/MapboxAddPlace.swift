//
//  MapboxAddPlace.swift
//  project X
//
//  Created by Trace Mateo 21 on 5/24/18.
//  Copyright © 2018 X. All rights reserved.
//

import Foundation
import Mapbox

class MapboxAddPlace {
    func addPlace(places: PlaceSearcher.Root) {
        for results in places.results {
            print("LOCATIONS: ", results.geometry.location)
        }
    }
}
