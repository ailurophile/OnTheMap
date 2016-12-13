//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//
import UIKit
import Foundation


 class UdacityClient: NSObject{
    /*
    func getValidData(_ data: NSData?)->NSData?{
        let range = Range(uncheckedBounds: (5, data!.count ))
        let newData = data?.subdata(in: range)
        return newData
    }
 */
    func login(_ loginViewController:UIViewController, email: String, password: String){
        // Build URL & configure request
        let url = UdacityURL()
        print(url)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = Methods.Login
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: String = "{\"" + Parameters.Dictionary + "\": {\""
        body += Parameters.UserName + "\":\""
        body += email + "\",\""
        body += Parameters.Password + "\":\""
        body += password + "\"}}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        print(body)
        udacityTask(with: request) {(result, error) in
            guard error == nil else {
                print ("received error: \(error)")
                // notify user
                return
            }
            guard let credentials =  result?[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject] else{
                //notify user
                print("key: Account not found")
                return
            }
            guard let enrolled = credentials[UdacityClient.JSONResponseKeys.ValidFlag] as? Bool else{
                //notify user
                print("Key: registered not found")
                return
            }
            if enrolled{
                print("//Login successful so logout & present map view controller")
                request.httpMethod = Methods.Logout
                request.httpBody = "".data(using: String.Encoding.utf8)
                //Logout of Udacity
                self.udacityTask(with: request, completionHandler: {(logoutResult,logoutError) in
                    guard logoutError == nil else{
                        print("Unsuccessful logout from Udacity")
                        return
                    }
                })
                //Present MapViewController on Main
                DispatchQueue.main.async(execute: {
                    let tabBarController = loginViewController.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
                    loginViewController.present((tabBarController)!, animated: true)
                    
                })
            }
            else{
               //notify user
                print("student not enrolled")
            }


            
            
        }
    
        //Make request
    }
    private func udacityTask(with request: NSMutableURLRequest, completionHandler: @escaping (_ results: AnyObject?, _ error: NSError?)->Void){
        let session = URLSession.shared
        var task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "makeRequest", code: 1, userInfo: userInfo))
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
            

            let range = Range(uncheckedBounds: (5, data.count ))
            let newData = data.subdata(in: range) // ignore first 5 characters returned
            //    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
//            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandler)
       
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
    



    private func UdacityURL()-> URL{
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
