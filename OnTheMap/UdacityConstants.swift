//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import Foundation

extension UdacityClient {
    //MARK: Constants
    struct Constants{
        //MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let SessionPath = "/api/session"
        static let UserInfoPath = "/api/users/"
    }
    
    //MARK: Methods
    
    struct Methods{
        static let Logout = "DELETE"
        static let Login = "POST"
        static let UserInfo = "GET"
    }
    //MARK: Parameters
    
    struct Parameters{
        static let Dictionary = "udacity"
        static let UserName = "username"
        static let Password = "password"
    }
    
    //MARK: JSON Response Keys
    struct JSONResponseKeys{
        static let Account = "account"
        static let ValidFlag = "registered"
        static let Expiration = "expiration"
        static let Session = "session"
        static let ID = "id"
        static let Key = "key"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let User = "user"
    }

    
}
