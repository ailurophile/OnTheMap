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
    
    var firstName : String?
    var lastName : String?
    var longitude : Float?
    var latitude : Float?
    var location : String?
    var link : String?
    var objectID : String?
    var uniqueKey : String?
    static var array =  [StudentInformation]()
    static var user = StudentInformation()
    
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
    init(){
        firstName = ParseClient.Constants.UNKNOWN
        lastName = ParseClient.Constants.UNKNOWN
        longitude = ParseClient.Constants.DefaultLongitude
        latitude = ParseClient.Constants.DefaultLatitude
        location = ParseClient.Constants.UNKNOWN
        link = ParseClient.Constants.UNKNOWN
        objectID = ParseClient.Constants.UNKNOWN
        uniqueKey = ParseClient.Constants.UNKNOWN
        
    }
}

//MARK StudentLocation Equatable

extension StudentInformation {}
func == (lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return (lhs.uniqueKey == rhs.uniqueKey)
}
