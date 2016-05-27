//
//  geoCoding.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 26.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//


import MapboxGeocoder

let geocoder = Geocoder.sharedGeocoder


class geocodeUtils {


    /* get adress from location
     
     *  - parameter latitude: Double
     *  - parameter longitude: Double
     *  - parameter format: String -> "short", "long" optional default is short
 
    */
    static func setAdress2Label(coorddinate2D: CLLocationCoordinate2D, format: String?, label: UILabel) {
    
        var locationAdress = "def"
        
        
        let options = ReverseGeocodeOptions(coordinate: coorddinate2D)
        let task = geocoder.geocode(options: options) { (placemarks, attribution, error) in
            if let error = error {
                NSLog("%@", error)
            } else if let placemarks = placemarks where !placemarks.isEmpty {
                

                if(format=="long"){
                    locationAdress = placemarks[0].qualifiedName
                    label.text = locationAdress
                } else {
                    //check if optionals exist
                    if let city = placemarks[0].postalAddress?.city, let country = placemarks[0].postalAddress?.country{
                        
                        locationAdress = "\(city)\n\(country)"
                        label.text = locationAdress
                        
                    } else {
                        print("not postal adress from geocoding")
                    }
                }
                
            } else {
                print("No results")
            }
        }

    }





}