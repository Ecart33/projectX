//
//  Circumcenter.swift
//  project X
//
//  Created by Trace Mateo 21 on 6/11/18.
//  Copyright © 2018 X. All rights reserved.
//

import Foundation

class Circumcenter {
    func circumcenter(p1: [Double], p2: [Double], p3: [Double]) -> Array<Double> {
        //get perpendicular slopes to side slopes
        let nslope1: Double = -1*(p2[0]-p1[0])/(p2[1]-p1[1])
        let nslope2: Double = -1*(p3[0]-p2[0])/(p3[1]-p2[1])
        let nslope3: Double = -1*(p1[0]-p3[0])/(p1[1]-p3[1])

        //get midpoints
        let mp1: Array<Double> = [(p1[0] + p2[0])/2, (p1[1] + p2[1])/2]
        let mp2: Array<Double> = [(p2[0] + p3[0])/2, (p2[1] + p3[1])/2]
        let mp3: Array<Double> = [(p3[0] + p1[0])/2, (p3[1] + p1[1])/2]
        
        //equation for lines in standard form
        //line 1
        let a1 = -1 * nslope1
        let c1 = mp1[1] - nslope1*mp1[0]

        //line 2
        let a2 = -1 * nslope2
        let c2 = mp2[1] - nslope2*mp2[0]
        
        
        let determinant = a1-a2
        
        let px = (c1 - c2)/determinant
        let py = (a1*c2 - c1*a2)/determinant
        return [px, py]
    }
}
