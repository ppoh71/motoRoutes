//
//  GoogleData.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 28.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON


class GoogleData {
    
    static let dataService = GoogleData()
    
    func getGoogleImages(_ latitude: Double, longitude: Double, heading: Double, id: String, key: Int){
        
        let url = "https://maps.googleapis.com/maps/api/streetview?size=400x300&location=" + String(latitude) + "," + String(longitude) +  "&heading=" + String(heading) +  "&fov=120&&pitch=-0.76&key=" + GOOGLE_API_KEY
        
        Alamofire.request(url).responseImage { (response) -> Void in
            
            print(response)
            guard let image = response.result.value else { return }
            
            print("alamo \(url) ")
            let returnObj = [image]
            
            ImageUtils.saveGoogleImageToFile(image , key: key, id: id)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: googleGetImagesNotificationKey), object: returnObj)
        }
    }
    
    func getGoogleGeoCode(_ latitude: Double, longitude: Double, field: String){
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="+String(latitude)+","+String(longitude)+"&sensor=true"
        Alamofire.request(url).responseJSON { response in
            print(response.request ?? "no request")  // original URL request
            print(response.response ?? "no response") // HTTP URL response
            print(response.data ?? "no data")     // server data
            //print(response.result)   // result of response serialization
            if let data = response.data {
                let json = JSON(data: data)
                
                if let addrObj = json["results"][1]["address_components"].array {
                    var address = "..."
                    var cnt = 0;
                    for item in addrObj {
                        print(item)
                        if let addressType = item["types"].array {
                            //check geo cities, more than you thought
                            var isCity = false;
                           
                            if (addressType[0] == "locality") {
                                isCity=true;
                                cnt=1
                            }else if (addressType[0] == "administrative_area_level_5") { //overrode all
                                isCity=true;
                                cnt=5
                            }
                            if (addressType[0] == "administrative_area_level_4") { //override 5
                                isCity=true;
                                cnt=4
                            }
                            if (addressType[0] == "administrative_area_level_3" && cnt==0) {
                                isCity=true;
                                cnt=3
                            }
                            if(isCity==true){
                                if let city = item["short_name"].string {
                                    address = city
                                }
                            }
                            
                            //check country
                            if (addressType[0] == "country") {
                                if let country = item["long_name"].string {
                                    //print("###country \(country)")
                                    address = address + ", " + country
                                }
                            }
                        }
                    }
                    print(address)
                    let returnObj = [address, field]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: getLocationSetNotificationKey), object: returnObj)
                    
                } //addrObj
            }// if data
        } //end alamo
    } //end func
    
}
