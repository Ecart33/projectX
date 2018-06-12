//
//  Navigator.swift
//  project X
//
//  Created by Trace Mateo 21 on 5/31/18.
//  Copyright © 2018 X. All rights reserved.
//

import Foundation



class GetDistance {
    func getDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        var R = 6371e3
        var a = lat1*Double.pi/180
        var b = lat2*Double.pi/180
        var c = (lat2 - lat1)*Double.pi/180
        var d = (lng2 - lng1)*Double.pi/180
        var e = sin(c/2)*sin(c/2) + cos(a)*cos(b)*sin(d/2)*sin(d/2)
        var f = 2 * atan2(sqrt(e), sqrt(1-e))
        var g = R * f
        return g
    }
}
