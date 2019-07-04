//
//  OMDB.swift
//  movieFavs
//
//  Created by user152630 on 6/29/19.
//  Copyright © 2019 user152630. All rights reserved.
//

import Foundation

class TMDB {
    let networkHelper = Network()
    var classDataController : DataController? = nil
  
    func downloadOMDBMovie(_ dataController : DataController, _ searchString : String, _ completionHandlerForPhotoArray: @escaping (_ result: [String]) -> Void ){
        classDataController = dataController
        var photoArray = [String]()
        
        let parameter = [ "query" : searchString as AnyObject,
                          "api_key": Constants.OMDB.ApiKey] as [String : AnyObject]
        
        networkHelper.taskForGETMethod(Constants.OMDB.Host, Constants.OMDB.Api, Constants.OMDB.Path+Constants.OMDB.SearchMethod, parameter) { (data, urlResponse, error) in
            if let error = error
            {
                print(error)
            }
            
            photoArray = self.convertPhotoJSON(data!)
            completionHandlerForPhotoArray(photoArray)
        }
    }
    
    func convertPhotoJSON(_ result: Data) -> [String] {
        var parsedResult: AnyObject! = nil
        var photoStringArray = [String]()
        do {
            parsedResult = try JSONSerialization.jsonObject(with: result, options: .allowFragments) as AnyObject
            if let stuff = parsedResult as? [String: Any] {
                print("This is the results from the API Call \(stuff) ")
                if let photos =  stuff["photos"] as? [String: Any]{
              //      pages = photos["pages"] as! Int
              //      print("pages is \(pages)")
                    if let photo =  photos["photo"] as? [AnyObject]{
                        for info in photo{
                            if let infoDetails = info as? [String : AnyObject]{
                                let photoURL = infoDetails["url_q"] as! String
                                photoStringArray.append(photoURL)
                            }
                        }
                    }
                }
            }
        } catch {
            print("Could not parse the data as JSON: '\(String(data: result, encoding: .utf8) ?? "")'")
        }
        return photoStringArray
    }
}
