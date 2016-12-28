//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import Foundation

struct  StudentInformation {
    
    //MARK: Properties
    
    let firstName : String?
    let lastName : String?
    var longitude : Float?
    var latitude : Float?
    let location : String?
    var link : String?
    let objectID : String?
    let uniqueKey : String?
    
    //Mark Construction
    
    init(_ dictionary: [String:AnyObject]){
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String ?? ParseClient.Constants.UNKNOWN
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String ?? ParseClient.Constants.UNKNOWN
        longitude = (dictionary[ParseClient.JSONResponseKeys.Longitude] as? Float)
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Float
        location = dictionary[ParseClient.JSONResponseKeys.Location] as? String ?? ParseClient.Constants.UNKNOWN
        link = dictionary[ParseClient.JSONResponseKeys.Link] as? String ?? ParseClient.Constants.UNKNOWN
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as? String ?? ParseClient.Constants.UNKNOWN
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String ?? ParseClient.Constants.UNKNOWN
    }
}

//MARK StudentLocation Equatable

extension StudentInformation {}
func == (lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return (lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude)
}
