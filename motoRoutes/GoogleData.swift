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
    
    func getGoogleGeoCode(_ latitude: Double, longitude: Double){
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="+String(latitude)+","+String(longitude)+"&sensor=true"
        Alamofire.request(url).responseJSON { response in
            print(response.request ?? "no request")  // original URL request
            print(response.response ?? "no response") // HTTP URL response
            print(response.data ?? "no data")     // server data
            print(response.result)   // result of response serialization
            if let data = response.data {
                //print("JSON: \(data)")
                
                let json = JSON(data: data )
                print(json)
                for (key,subJson):(String, JSON) in json {
                    print(key)
                }
                
                if let userName = json[0]["formatted_address"].string {
                    //Now you got your value
                    print(userName)
                }
                
            }
        }
    }
    
}
