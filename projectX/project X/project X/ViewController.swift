//
//  ViewController.swift
//  project X
//
//  Created by Trace Mateo 21 on 5/16/18.
//  Copyright © 2018 X. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation
import CoreLocation

class ViewController: UIViewController, MGLMapViewDelegate {
    
    var friendsSelected: [String: Array<Double>] = [:]
    
    var locationManager = CLLocationManager()
    
    var mapView: NavigationMapView!
    
    var annotationPoints: Array<MGLAnnotation> = []
    
    var userLocations: [String: Array<Double>] = [:]
    
    var userLocationAnnotations: Array<MGLAnnotation> = []
    
    let fb = FriendButton()
    
    lazy var buttonContainer = self.fb.getButton(friends: self.friendsSelected.count)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        //get map
        let url = URL(string: "mapbox://styles/mapbox/light-v9")
        
        mapView = NavigationMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Set the map’s center coordinate and zoom level.
        view.addSubview(mapView)
        // Set the delegate property of our map view to `self` after instantiating it.
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        
        mapView.userTrackingMode = .follow
        
        userLocations = [
            "user1": [40.712775, -74.005973],
            "user2": [40.785091, -73.968285]
        ]
        
        for (key, value) in userLocations {
            let point = MGLPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            point.title = key
            point.subtitle = "friend"
            userLocationAnnotations.append(point)
        }
        for i in userLocationAnnotations {
            mapView.addAnnotation(i)
        }
        

    }
    
    var directionsRoute: Route?
    
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        
        // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        
        // Specify that the route is intended for people walking
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
        
        // Generate the route object and draw it on the map
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            self.directionsRoute = routes?.first
            // Draw the route on the map after creating it
            self.drawRoute(route: self.directionsRoute!)
        }
    }
    // #-end-code-snippet: navigation calculate-route-swift
    
    // #-code-snippet: navigation draw-route-swift
    func drawRoute(route: Route) {
        guard route.coordinateCount > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 4)
            
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 7000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
        if(annotation.subtitle != nil) {
            if(annotation.subtitle! == "friend") {
                if (self.friendsSelected.index(forKey: annotation.title!!) == nil) {
                    self.friendsSelected[annotation.title as! String] = [annotation.coordinate.latitude, annotation.coordinate.longitude]
                } else {
                    self.friendsSelected.removeValue(forKey: annotation.title!!)
                }
                self.view.insertSubview(self.buttonContainer, aboveSubview: mapView)
                for subview in self.buttonContainer.subviews {
                    if let item = subview as? UIButton {
                        item.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
                    }
                    if let label = subview as? UILabel {
                        label.text = "Friends Selected: \(self.friendsSelected.count)"
                    }
                }
                
            } else {
                self.friendsSelected.removeAll()
                self.buttonContainer.removeFromSuperview()
            }
        }
        print("\n\n\n\n\n\nannotation selected and \(friendsSelected)\n\n\n\n\n\n\n\n")
        
    }
    
    @objc fileprivate func action(sender: Button) {
        var mid: [String: Array<Double>] = [:]
        self.friendsSelected["me"] = [(mapView.userLocation?.coordinate.latitude)!, (mapView.userLocation?.coordinate.longitude)!]
        for annotation in mapView.annotations as! [MGLAnnotation] {
            if annotation.subtitle != nil {
                if annotation.subtitle! != "friend" {
                    mapView.removeAnnotation(annotation)
                }
            }
        }
        self.buttonContainer.removeFromSuperview()
        placesFromMid().placesFromMid(midpointData: placesFromMid().findMid(usrLocations: self.friendsSelected)) { places in
            for point in places {
                mid[point.title!] = [point.coordinate.latitude, point.coordinate.longitude]
                self.mapView.addAnnotation(point)
            }
            self.friendsSelected.removeAll()
            self.annotationPoints = places
            var avlat: Double = 0
            var avlng: Double = 0
            for (_, value) in mid {
                avlat+=value[0]
                avlng+=value[1]
            }
            let camera = MGLMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: avlat/Double(mid.count), longitude: avlng/Double(mid.count)), fromDistance: 4000, pitch: 0, heading: 0)
            self.mapView.setCamera(camera, withDuration: 0.5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let navButton = UIButton(type: .detailDisclosure)
        navButton.setImage(UIImage(named: "navButton.png"), for: UIControlState.normal)
        return navButton
    }

    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // Hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
        
        print("calloutAcessory tapped")
        
        //make the navigation route
        self.calculateRoute(from: (mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
            if error != nil {
                print("Error calculating route")
            }
        }
        
        //move camera so that entire route is seen
        let r: Double = 6371e3
        var A = GetDistance()
        var a = A.getDistance(lat1: (mapView.userLocation?.coordinate.latitude)!, lng1: (mapView.userLocation?.coordinate.longitude)!, lat2: annotation.coordinate.latitude, lng2: annotation.coordinate.longitude)
        let cameraMid = CLLocationCoordinate2D(latitude: (annotation.coordinate.latitude + mapView.userLocation!.coordinate.latitude)/2, longitude: (annotation.coordinate.longitude + mapView.userLocation!.coordinate.longitude)/2)
        let Ep2 = r*sin((360*a)/(2*r*Double.pi)/2)
        let distanceFromMid = Ep2/7
        let camera = MGLMapCamera(lookingAtCenter: cameraMid, fromDistance: distanceFromMid, pitch: 0, heading: 0)
        print(distanceFromMid)
        print(a)
        print(Ep2)
        mapView.setCamera(camera, withDuration: 0.5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        for point in self.annotationPoints {
            if point.coordinate != annotation.coordinate {
                mapView.removeAnnotation(point)
            }
        }
        
    }
    //make custom annotations for userLocations
    func mapView(mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        print("\n\n\n\n\n\n\n\nannotation\n\n\n\n")
        return nil
    }
}
