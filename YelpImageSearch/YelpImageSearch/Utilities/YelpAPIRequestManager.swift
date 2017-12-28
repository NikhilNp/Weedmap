//
//  YelpAPIRequestManager.swift
//  YelpImageSearch
//
//  Created by Nikhil Patil on 12/22/17.
//  Copyright © 2017 Nikhil Patil . All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class YelpAPIRequestManager: NSObject {
    
    let baseRequestURL: String = "https://api.yelp.com/v3"
    let searchEndpoint: String = "/businesses/search"
    let authURL: String = "https://api.yelp.com/oauth2/token"
    
    // Over line 15,16,17  stored the Url, Endpoints and token into the constants
    
    static let sharedInstance = YelpAPIRequestManager()
    private override init() {
        super.init()
    }
    // Used Singleton so that it as  only one instance exists for a given class and that there’s a global access point to that instance. 1. the shared static constant approach gives other objects access to the singleton object API.
  
    
    func getAuthorization(completion: @escaping (String)->()) {
        if let token = KeychainWrapper.standard.string(forKey: "YelpImageSearch_Token") {
            completion(token)
            return
        } else if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist"), let plistDict = NSDictionary(contentsOfFile: plistPath),
            let clientID = plistDict["YelpClientID"] as? String, let clientSecret = plistDict["YelpClientSecret"] as? String {
            
            //The information of the client credentials is  retrieved from Info.plist, pass them to auth token request
            let parameterDict: [String:String] = [
                "grant_type" : "client_credentials",
                "client_id" : clientID,
                "client_secret" : clientSecret
            ]
            
            Alamofire.request(authURL, method: .post, parameters: parameterDict).responseJSON { response in
                if let responseDict = response.result.value as? NSDictionary, let token = responseDict["access_token"] as? String {
                    //successful response, store token in keychain for later use
                    //Yelp docs: "All tokens are set to expire on January 18, 2038"
                    KeychainWrapper.standard.set(token, forKey: "YelpImageSearch_Token")
                    completion(token)
                } else if let error = response.result.error {
                    //an error occurred, print its details
                    print(error.localizedDescription)
                    completion("")
                } else {
                    print("Unable to retrieve Yelp auth token at this time")
                    completion("")
                }
            }
        }
    }
    
    //search businesses using the passed-in keyword and page number
    func searchBusinessImages(keyword: String, page: Int, completion: @escaping ([String])->()) {
        getAuthorization { [unowned self] token in
            
            //header dictionary with retrieved auth token
            let headerDict: [String:String] = [
                "Authorization" : "Bearer \(token)"
            ]
            
            //dictionary of search parameters with keyword and user location
            let parameterDict: [String:Any] = [
                "term" : keyword,
                "latitude" : UserDefaults.standard.double(forKey: "latitude"),
                "longitude" : UserDefaults.standard.double(forKey: "longitude"),
                "radius" : 40000, //max search radius allowed (25 miles)
                "limit" : 50, //max results allowed per page
                "offset" : page * 50
            ]

            Alamofire.request(self.baseRequestURL + self.searchEndpoint, method: .get, parameters: parameterDict, headers: headerDict).responseJSON { response in
                if let responseDict = response.result.value as? NSDictionary, let businessDicts = responseDict["businesses"] as? [NSDictionary] {
                    //build array of business image urls from response
                    var imageURLs: [String] = []
                    for business in businessDicts {
                        if let url = business["image_url"] as? String {
                            imageURLs.append(url)
                        }
                    }
                    completion(imageURLs)
                } else if let error = response.result.error {
                    //an error occurred, print its details
                    print(error.localizedDescription)
                    completion([])
                } else {
                    print("Unable to search Yelp businesses at this time")
                    completion([])
                }
            }
        }
    }

}
