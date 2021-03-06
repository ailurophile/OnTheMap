//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import Foundation
import MapKit

class ParseClient: NSObject{
//    var students: [StudentInformation]!
//    var user = StudentInformation()
    
    
    func findLocation(_with completionHandler: @escaping (_ location:[[String: AnyObject]]?,_ error:NSError?)->Void){

        queryParse(HTTPMethods.GetLocation, parameters: nil  , searchExisting: true, completionHandlerForQuery: { (result, error) in

            guard error == nil else{
                completionHandler(nil,error)
                return
            }
            guard let studentLocation = (result as AnyObject)[ParseClient.JSONResponseKeys.Results] as? [[String:AnyObject]] else{
                let userInfo = [NSLocalizedDescriptionKey : "Key: \(ParseClient.JSONResponseKeys.Results)' not found in results)"]
                completionHandler(nil, NSError(domain: "findLocation", code: 1, userInfo: userInfo))
                return
            }
//            print("student location: \(studentLocation)")
            completionHandler(studentLocation, nil)
            return
        })
        
    }
    
    func getLocations(with completionHandler: @escaping (_ locations:[[String:AnyObject]]?,_ error:NSError?)->Void){
        let parameters = [JSONParameterKeys.Limit: Constants.NumberOfPinsToLoad,
                          JSONParameterKeys.Order: "-" + JSONResponseKeys.UpdateStamp]
        queryParse(HTTPMethods.GetLocation, parameters: parameters as [String:AnyObject], searchExisting: false)  { (results, error) in

            guard error == nil else{
                completionHandler(nil,error)
                return
            }
 
            guard let locations = (results as? AnyObject)?[ParseClient.JSONResponseKeys.Results] as?  [[String:AnyObject]] else{
                let userInfo = [NSLocalizedDescriptionKey : "Key: '\(ParseClient.JSONResponseKeys.Results)' not found in results)"]
                completionHandler(nil,NSError(domain: "getLocations", code: 1, userInfo: userInfo ))
                return
            }
            completionHandler(locations,nil)
            
        }
        return
    }
    
    func postLocation(with completionHandler: @escaping (_ results:AnyObject?,_ error:NSError?)->Void){

        //build parameters array
        let parameterArray = buildParameters()

        queryParse(HTTPMethods.PostLocation, parameters: parameterArray ,searchExisting: false , completionHandlerForQuery: {(result, error) in
            guard error == nil else {
                completionHandler(nil,error)
                return
            }
            completionHandler(result as AnyObject?,nil)
        })
        
    }
    
    func updateLocation(with completionHandler: @escaping (_ results:AnyObject?,_ error:NSError?)->Void){
        
        //build parameters array
        let parameterArray = buildParameters()
        queryParse(HTTPMethods.UpdateLocation, parameters: parameterArray ,searchExisting: false , completionHandlerForQuery: {(result, error) in
            guard error == nil else {
                completionHandler(nil,error)
                return
            }
            completionHandler(result as AnyObject?,nil)
        })
        

        
    }
    
    private func queryParse(_ method:String, parameters:[String:AnyObject]?, searchExisting: Bool, completionHandlerForQuery: @escaping ( _ results: Any?, _ error: NSError?) -> Void){
        let headers = [HTTPHeaderFields.ContentType: Constants.Encoding,
                       HTTPHeaderFields.AppID: Constants.ParseAppID,
                       HTTPHeaderFields.ApiKey: Constants.RestAPIKey]
        var components = URLComponents()
        var httpBody:Data?
        var request : NSMutableURLRequest!
        components.host = Constants.ApiHost
        components.scheme = Constants.ApiScheme
        components.path = Constants.ApiPath
        
        if method == HTTPMethods.PostLocation || method == HTTPMethods.UpdateLocation {
            if method == HTTPMethods.UpdateLocation{
                components.path.append("/" + StudentInformation.user.objectID!)
            }
            guard let parameters = parameters else{
                let userInfo = [NSLocalizedDescriptionKey : "No parameters to post!"]
                completionHandlerForQuery(nil,NSError(domain: "queryParse", code: 1, userInfo: userInfo))

                return
            }
            do {
                let postData = try JSONSerialization.data(withJSONObject: parameters as [String: AnyObject])
                httpBody = postData
//                print(NSString(data: httpBody!, encoding: String.Encoding.utf8.rawValue)!)
                
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Unable to parse student info as JSON"]
                completionHandlerForQuery(nil,NSError(domain: "queryParse", code: 1, userInfo: userInfo))
            }
            
             request = NSMutableURLRequest(url: components.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
            
        }

        else if method == HTTPMethods.GetLocation{

            if searchExisting == true {
                var urlString = (components.url?.absoluteString)! + "?where="
                let prefix = "{\"uniqueKey\":\"".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
                urlString.append(prefix!)
                urlString.append(StudentInformation.user.uniqueKey! as String)
                let suffix = "\"}".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
                urlString.append(suffix!)
                let newUrl = URL(string: urlString)
                request = NSMutableURLRequest(url: newUrl!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
                
            }
            else{
                if let parameters = parameters{
                    components.queryItems = [URLQueryItem]()
                    for (key, value) in parameters {
                        let queryItem = URLQueryItem(name: key, value: "\(value)")
                        components.queryItems!.append(queryItem)
                        request = NSMutableURLRequest(url: components.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
                    }
                    
                }
            }
            
        }

        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = httpBody
        
        let session = URLSession.shared
        var task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForQuery(nil, NSError(domain: "makeRequest", code: 1, userInfo: userInfo))
            }
            if error != nil { // Handle error…
                //                print(error?.localizedDescription)
                sendError("There was an error with your request: \(error)")
                return
            }
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            guard  statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned status code: \(HTTPURLResponse.localizedString(forStatusCode:statusCode))")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
//            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)

   
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForQuery)
            
        }
        task.resume()
    }
    
    
    
    
    
    // MARK: Helpers
    
    func buildParameters()->[String:AnyObject]{
        let parameterArray = [JSONResponseKeys.FirstName: StudentInformation.user.firstName as AnyObject,
                              JSONResponseKeys.LastName: StudentInformation.user.lastName as AnyObject,
                              JSONResponseKeys.UniqueKey: StudentInformation.user.uniqueKey as AnyObject,
                              JSONResponseKeys.Link: StudentInformation.user.link as AnyObject,
                              JSONResponseKeys.Location: StudentInformation.user.location as AnyObject,
                              JSONResponseKeys.Latitude: StudentInformation.user.latitude as AnyObject,
                              JSONResponseKeys.Longitude: StudentInformation.user.longitude as AnyObject]
        return parameterArray

    }
    
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    

    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
