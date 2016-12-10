//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import Foundation

extension ParseClient {
    
    //MARK: Constants
    
    struct Constants{
        //MARK: API Keys
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.udacity"
        static let ApiPath = "/parse/classes"
        
        static let UNKNOWN = "Unknown"
    }
    
    //MARK: Methods
    
    struct Methods{
        static let UpdateLocation = "PUT"
        static let GetLocation = "GET"
        static let PostLocation = "POST"
    }
    
    //MARK: URL Keys
    
    
    //MARK: Parameter Keys
    struct JSONParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
        static let Skip = "skip"
    }
    
    //MARK: JSON Body Keys
    
    //MARK: JSON Response Keys
    
    struct  JSONResponseKeys {
        static let CreationStamp = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let Location = "mapString"
        static let Link = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdateStamp = "updatedAt"
        static let AccessControlList = "ACL"
    }
    
}
