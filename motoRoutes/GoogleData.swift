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


    
    func getGoogleImages(latitude: Double, longitude: Double, heading: Double, id: String, key: Int){

        let url = "https://maps.googleapis.com/maps/api/streetview?size=400x300&location=" + String(latitude) + "," + String(longitude) +  "&heading=" + String(heading) +  "&fov=120&&pitch=-0.76&key=" + GOOGLE_API_KEY
        
        
        var fileName: String?
        var finalPath: NSURL?
        
        
        Alamofire.request(.GET, url).responseImage { (response) -> Void in
            guard let image = response.result.value else { return }
          
            print("amlamooooo \(url) ")
            let returnObj = [image]
            
            let filename = "\(key).jpeg"
            imageUtils.saveGoogleImageToFile(image, key: key, id: id)
            
            NSNotificationCenter.defaultCenter().postNotificationName(googleGetImagesNotificationKey, object: returnObj)
        }
//        
//        var localPath: NSURL?
//        Alamofire.request(.GET,
//            url,
//            destination: { (temporaryURL, response) in
//                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
//                let pathComponent = response.suggestedFilename
//                
//                localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
//                return localPath!
//        })
//            .response { (request, response, _, error) in
//                print(response)
//                print("Downloaded file to \(localPath!)")
//                
//                let returnObj = [String(localPath!)]
//                NSNotificationCenter.defaultCenter().postNotificationName(googleGetImagesNotificationKey, object: returnObj)
//                
//        }
        
        
        
    }
    
    

}