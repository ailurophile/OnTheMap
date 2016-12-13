//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import Foundation


 class UdacityClient: NSObject{
    /*
    func getValidData(_ data: NSData?)->NSData?{
        let range = Range(uncheckedBounds: (5, data!.count ))
        let newData = data?.subdata(in: range)
        return newData
    }
 */
    func login(){
        
    }
    
    
    func loginPlayground(){
        var request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"lslitchfield@gmail.com\", \"password\": \"2learnPython\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        var task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                print(error?.localizedDescription)
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count ))
            let newData = data?.subdata(in: range) /* subset response data! */
            //    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            //    session = URLSession.shared
            let task2 = session.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                let range = Range(uncheckedBounds: (5, data!.count - 5))
                let newData = data?.subdata(in: range) /* subset response data! */
                print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            }
            task2.resume()
  
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
    
    // create a URL from parameters
    private func UdacityURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath
                
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }

    
}
