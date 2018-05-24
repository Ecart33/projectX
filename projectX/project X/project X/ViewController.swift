//
//  ViewController.swift
//  project X
//
//  Created by Trace Mateo 21 on 5/16/18.
//  Copyright © 2018 X. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var annotationPointsInfo: Array<AnnotatedPoints.annotatedPoints> = []
        
        var annotationPoints: Array<MGLAnnotation> = []
        
        var placeSearchResults: PlaceSearcher.Root? = nil
        //get map
        let url = URL(string: "mapbox://styles/mapbox/light-v9")
        
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //get user location
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            
            currentLocation = locManager.location
            
        }

        PlaceSearcher().searchPlace(key: "AIzaSyDxsj4p01EaidOig0dQVcjp0Rp1YlWG6JQ", location: "\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)", radius: "1000") { result in
            placeSearchResults = result
            MapboxAddPlace().addPlace(places: placeSearchResults!)
            for locations in (placeSearchResults?.results)! {
                annotationPointsInfo.append(AnnotatedPoints.annotatedPoints(lat: locations.geometry.location.lat, lng: locations.geometry.location.lng, name: locations.name, open_now: (locations.opening_hours?.open_now)))
            }
            for annotatedPoints in annotationPointsInfo {
                if (annotatedPoints.open_now == nil || annotatedPoints.open_now == true) {
                    let point = MGLPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: annotatedPoints.lat, longitude: annotatedPoints.lng)
                    point.title = annotatedPoints.name
                    annotationPoints.append(point)
                }
            }
            for points in annotationPoints {
                mapView.addAnnotation(points)
            }
        }
        
        // Set the map’s center coordinate and zoom level.
        view.addSubview(mapView)
        
        // Set the delegate property of our map view to `self` after instantiating it.
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        
        mapView.userTrackingMode = .follow
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

