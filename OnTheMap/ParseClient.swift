//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import Foundation

class ParseClient: NSObject{
    var students: [StudentInformation]!
    
    
    func getLocation(with completionHandler: (_ locations:AnyObject?,_ error:NSError?)->Void){
        
    }
    
    func getLocations(with completionHandler: @escaping (_ locations:[[String:AnyObject]]?,_ error:NSError?)->Void){
        queryParse(HTTPMethods.GetLocation, parameters: [JSONParameterKeys.Limit: "100" as AnyObject])  { (results, error) in
            guard error == nil else{
                completionHandler(nil,error)
                return
            }
 
            guard let locations = (results as? AnyObject)?[ParseClient.JSONResponseKeys.Results] as?  [[String:AnyObject]] else{
                let userInfo = [NSLocalizedDescriptionKey : "Key: '\(ParseClient.JSONResponseKeys.Results)' not found in results)"]
                completionHandler(nil,NSError(domain: "getLocations", code: 1, userInfo: userInfo ))
                return
            }
            print(locations)
            completionHandler(locations,nil)
            
        }
        return
    }
    
    func postLocation(){
        
    }
    
    func updateLocation(){
        
    }
    
    private func queryParse(_ method:String, parameters:[String:AnyObject]?, completionHandlerForQuery: @escaping ( _ results: Any?, _ error: NSError?) -> Void){
        let headers = [HTTPHeaderFields.ContentType: Constants.Encoding,
                       HTTPHeaderFields.AppID: Constants.ParseAppID,
                       HTTPHeaderFields.ApiKey: Constants.RestAPIKey]
        var components = URLComponents()
        components.host = Constants.ApiHost
        components.scheme = Constants.ApiScheme
        components.path = Constants.ApiPath
//        components.queryItems = [URLQueryItem]()

        if let parameters = parameters{
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
//            var httpBody =
            if method == HTTPMethods.GetLocation{
                print(components.url)
            }
            
        }
        var request = NSMutableURLRequest(url: components.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
/*        let postData = try JSONSerialization.data(withJSONObject: parameters as Any)
        catch{
            notifyUser(
        }
        
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.themoviedb.org/3/account/6438892/watchlist?session_id=6d4a20b3e8daaef975fbfc2e02e323ec8464db65&api_key=ea986b024c22a35a7df206b6e4d13192")!,
                                          cachePolicy: .UseProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.HTTPMethod = method
        request.allHTTPHeaderFields = headers
        request.HTTPBody = "where+" + postData
 */

    
        let session = URLSession.shared
        var task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                print(error)
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
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)

            
//            let range = Range(uncheckedBounds: (5, data.count ))
//            let newData = data.subdata(in: range) // ignore first 5 characters returned
            //    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            //            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForQuery)
            
        }
        task.resume()
    }
    
    
    
    
    
    // MARK: Helpers
    
    
    
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
