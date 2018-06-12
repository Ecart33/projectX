//
//  placesFromMid.swift
//  project X
//
//  Created by Trace Mateo 21 on 5/30/18.
//  Copyright © 2018 X. All rights reserved.
//

import Foundation
import CoreGraphics
import Mapbox

class placesFromMid {
    func findMid(usrLocations: Dictionary<String, Array<Double>>) -> Array<Double> {
        //create set of all points
        var allPointsArray: [[Double]] = []
        for (_, p) in usrLocations {
            allPointsArray.append(p)
        }
        
        //randomly order set
        var pointSet: [[Double]] = []
        for i in allPointsArray {
            let rand = Int(arc4random_uniform(UInt32(allPointsArray.count)))
            pointSet.append(allPointsArray[rand])
            allPointsArray.remove(at: rand)
        }
        
        //for debug
        print(pointSet)
        
        //get center of minumum enclosed circled (MEC) composed of first 2 points
        var mecCenter: [Double] = [(pointSet[0][0] + pointSet[1][0])/2, (pointSet[0][1] + pointSet[1][1])/2]
        var mecRad: Double = sqrt(pow(pointSet[0][0] - mecCenter[0], 2) + pow(pointSet[0][1] - mecCenter[1], 2))
        
        //create set for points that are on the boundry of the circle
        var bPoints: [[Double]] = [pointSet[0], pointSet[1]]
        
        //create set for points that are in MEC
        var mecPoints: [[Double]] = [pointSet[0], pointSet[1]]
        
        //create final MEC
        for point in pointSet {
            //ignore points that already make up MEC
            if point != pointSet[0] && point != pointSet[1] {
                //add point to existing MEC
                //check if point enclosed by current MEC
                if sqrt(pow(point[0] - mecCenter[0], 2) + pow(point[1] - mecCenter[1], 2)) <= mecRad {
                    //Add the point into the MEC
                    mecPoints.append(point)
                } else {
                    //Update MEC if point is outside current circle
                    //Create 3 circles: circle(p1, p2), circle(p1, p2, pl), circle(p1, p2, pr) where pl is the farthest point from the center of circle(p1, p2) that is on one side of like p1p2 and pr is the point farthest from the circle on the other side
                    //add point to the MEC
                    mecPoints.append(point)
                    
                    //set the boundry points to at least the outside point and the point farthest away from it
                    var distanceFromPoint: [[Double]] = []
                    for i in mecPoints {
                        distanceFromPoint.append([i[0], i[1], sqrt(pow(i[0] - point[0], 2) + pow(i[1] - point[1], 2))])
                    }
                    distanceFromPoint.sort{$0[2]>$1[2]}
                    bPoints = [point, [distanceFromPoint[0][0], distanceFromPoint[0][1]]]
                    
                    //create set of all circles
                    var circles: [[Double]] = []
                    //create circle(p1, p2)
                    let c1Center = [(bPoints[0][0] + bPoints[1][0])/2, (bPoints[0][1] + bPoints[1][1])/2]
                    let c1Rad = sqrt(pow(bPoints[0][0] - c1Center[0], 2) + pow(bPoints[0][1] - c1Center[1], 2))
                    circles.append([c1Center[0], c1Center[1], c1Rad])
                    print(circles)
                    //create circle(p1, p2, pl)
                    //find circumcenter of triangle with vertices p1, p2, and pl
                    var mecPointsDist: [[Double]] = []
                    for i in mecPoints {
                        let l = i
                        for i in bPoints {
                            if l != i {
                                let m = (bPoints[0][1] - bPoints[1][1])/(bPoints[0][0] - bPoints[1][0])
                                let b = bPoints[0][1] + m*bPoints[0][0]
                                if i[0] - m*i[1] < b {
                                    mecPointsDist.append([i[0], i[1], sqrt(pow(i[0] - c1Center[0], 2) + pow(i[1] - c1Center[1], 2))])
                                }
                            }
                        }
                    }
                    print(mecPointsDist)
                    if mecPointsDist.count > 0 {
                        mecPointsDist.sort{$0[2] > $1[2
                            ]}
                        let pl = [mecPointsDist[0][0], mecPointsDist[0][1]]
                        print("pl: \(pl)")
                        print("p1: \(bPoints[0])\np2: \(bPoints[1])")
                        let c2Center = Circumcenter().circumcenter(p1: bPoints[0], p2: bPoints[1], p3: pl)
                        let c2Rad = sqrt(pow(pl[0] - c2Center[0], 2) + pow(pl[1] - c2Center[1], 2))
                        
                        circles.append([c2Center[0], c2Center[1], c2Rad])
                        print("c2circle: \(c2Center, c2Rad)")
                    }
                    //find circumcenter of triangle with vertices p1, p2, and pr
                    mecPointsDist = []
                    for i in mecPoints {
                        print("i: \(i)\nboundryPoints:\(bPoints[0])")
                        let m = (bPoints[0][1] - bPoints[1][1])/(bPoints[0][0] - bPoints[1][0])
                        let b = bPoints[0][1] + m*bPoints[0][0]
                        if i[0] - m*i[1] > b {
                            mecPointsDist.append([i[0], i[1], sqrt(pow(i[0] - c1Center[0], 2) + pow(i[1] - c1Center[1], 2))])
                        }
                    }
                    if mecPointsDist.count > 0 {
                        mecPointsDist.sort{$0[2] > $1[2]}
                        let pr = [mecPointsDist[0][0], mecPointsDist[0][1]]
                        print("pr: \(pr)")
                        print("p1: \(bPoints[0])\np2: \(bPoints[1])")
                        let c3Center = Circumcenter().circumcenter(p1: bPoints[0], p2: bPoints[1], p3: point)
                        let c3Rad = sqrt(pow(pr[0] - c3Center[0], 2) + pow(pr[1] - c3Center[1], 2))
                        
                        circles.append([c3Center[0], c3Center[1], c3Rad])
                        print("c3circle: \(c3Center, c3Rad)")
                        print("CIRCLES: \(circles)")
                    }
                    
                    for i in circles {
                        let l = i
                        for i in mecPoints {
                            if sqrt(pow(i[0] - l[0], 2) + pow(i[1] - l[1], 2)) > l[2] {
                                let index = circles.index(where: {$0 == l})
                                print("distance from i to l center: ", sqrt(pow(i[0] - l[0], 2) + pow(i[1] - l[1], 2)))
                                print("l: ", l)
                                print("circles: ", circles)
                                print("index: ", index)
                                circles.remove(at: index!)
                            }
                        }
                    }
                    circles.sort{$0[2]<$1[2]}
                    bPoints.append(point)
                    bPoints.remove(at: 0)
                    mecCenter = [circles[0][0], circles[0][1]]
                    mecRad = circles[0][2]
                }
            }
        }
        var mecCircle = [mecCenter[0], mecCenter[1], GetDistance().getDistance(lat1: mecCenter[0], lng1: mecCenter[1], lat2: bPoints[0][0], lng2: bPoints[0][1])/4]
        
        print(mecCircle)
        return mecCircle
    }
    
    func placesFromMid(midpointData: Array<Any>, completionHandler: @escaping (_ places: Array<MGLPointAnnotation>) -> ()){
        
        var annotationPointsInfo: Array<AnnotatedPoints.annotatedPoints> = []
        
        var annotationPoints: Array<MGLAnnotation> = []
        
        var placeSearchResults: PlaceSearcher.Root? = nil
        
        print(midpointData)
        
        PlaceSearcher().searchPlace(key: "AIzaSyDxsj4p01EaidOig0dQVcjp0Rp1YlWG6JQ", location: "\(midpointData[0]),\(midpointData[1])", radius: String(describing: midpointData[2]), type: "cafe") { result in
            
            MapboxAddPlace().addPlace(places: result)
            
            placeSearchResults = result
            
            for locations in (placeSearchResults?.results)! {
                annotationPointsInfo.append(AnnotatedPoints.annotatedPoints(lat: locations.geometry.location.lat, lng: locations.geometry.location.lng, name: locations.name, open_now: (locations.opening_hours?.open_now)))
            }
            for annotatedPoints in annotationPointsInfo {
                let point = MGLPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: annotatedPoints.lat, longitude: annotatedPoints.lng)
                point.title = annotatedPoints.name
                annotationPoints.append(point)
            }
            completionHandler(annotationPoints as! Array<MGLPointAnnotation>)
        }
    }
}
