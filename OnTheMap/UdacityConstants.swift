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
        static let ApiPath = "/api/session"
    }
    
    //MARK: Methods
    
    struct Methods{
        static let Logout = "DELETE"
        static let GetSessionID = "POST"
    }
    
    struct Parameters{
        static let Dictionary = "udacity"
        static let UserName = "username"
        static let Password = "password"
    }

    
}
