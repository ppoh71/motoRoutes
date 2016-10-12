//
//  geoCoding.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 26.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

/*
import MapboxGeocoder


let geocoder = Geocoder.sharedGeocoder


final class GeocodeUtils {
    
    /* get adress from location */
    static func getAdressFromCoord(_ coorddinate2D: CLLocationCoordinate2D, field: String ) {
        
        var locationAdress = "EOF"
        
        let options = ReverseGeocodeOptions(coordinate: coorddinate2D)
        _ = geocoder.geocode(options: options) { (placemarks, attribution, error) in
            
            if let error = error {
                NSLog("%@", error)
            } else if let placemarks = placemarks, !placemarks.isEmpty {
                
                // let formatter = CNPostalAddressFormatter()
                // print(formatter.stringFromPostalAddress(placemarks[0].postalAddress!))
                locationAdress = placemarks[0].qualifiedName
            }
            
            let locationReturn = [locationAdress, field]
            
            //get main queue and send notification
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(getLocationSetNotificationKey, object: locationReturn)
                
            }
        }
    }
}
*/
