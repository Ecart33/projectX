//
//  File.swift
//  project X
//
//  Created by Trace Mateo 21 on 5/18/18.
//  Copyright © 2018 X. All rights reserved.
//
import Foundation
import Alamofire


class PlaceSearcher {
    func searchPlace(key: String, location: String, radius: String? = "nil", keyword: String? = "nil", type: String? = "nil", minprice: String? = "nil", maxprice: String? = "nil", opennow: String? = "nil", rankby: String? = "nil", completionHandler: @escaping (_ result: Root) -> ()) {
        
        //print(location)
        //create dictionary from arguments so that it can be switched over
        
        var parameters = [
            "key": key,
            "location": location,
            "radius": radius,
            "keyword": keyword,
            "type": type,
            "minprice": minprice,
            "maxprice": maxprice,
            "opennow": opennow,
            "rankby": rankby
            ]
        
        //initialize url with json return data and location
        var urlString: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)"
        
        //print (urlString)
        
        //override radius if rankby = distance to avoid errors
        //if (parameters["rankby"] == "distance" && parameters["radius"] != nil) {
          //  parameters["radius"] = nil
        //}
        
        //create url based off of arguments
        let sortedParameters = parameters.sorted {$0.key < $1.key}
        
        for element in sortedParameters {
            //print(element.key, element.value)
            if (element.value != "nil" && element.key != "key" && element.key != "location") {
                urlString = urlString + "&\(element.key)=\(element.value!)"
            }
        }
        
        
        //add api authentication key to url
        urlString = urlString + "&key=\(key)"
        
        //send request to api
        Alamofire.request(urlString).responseJSON { response in
            if let data = response.data {
                let places = try! JSONDecoder().decode(Root.self, from: data)
                completionHandler(places)
                }
        }
    }
    
    
    struct Root: Decodable {
        enum CodingKeys: String, CodingKey {
            case results = "results"
        }
        let results : [results]
    }
    
    struct results: Decodable {
        enum CodingKeys: String, CodingKey {
            case geometry = "geometry"
            case name = "name"
            case opening_hours = "opening_hours"
        }
        let geometry : geometry
        let name : String
        let opening_hours : opening_hours?
        
    }
    
    struct opening_hours: Decodable {
        enum CodingKeys: String, CodingKey {
            case open_now = "open_now"
        }
        let open_now: Bool
    }
    
    struct geometry: Decodable {
        enum CodingKeys: String, CodingKey {
            case location = "location"
        }
        let location: location
    }
    
    struct location: Decodable {
        enum CodingKeys: String, CodingKey {
            case lat = "lat"
            case lng = "lng"
        }
        let lat: Double
        let lng: Double
    }
}
