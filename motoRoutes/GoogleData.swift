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
}
