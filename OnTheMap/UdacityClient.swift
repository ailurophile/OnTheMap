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
    
    func login(_ loginViewController:UIViewController, email: String, password: String, completionHandler: @escaping (Bool)->()){
        // Build URL & configure request
        var url = UdacityURL(path: UdacityClient.Constants.SessionPath)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = Methods.Login
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let login: [String:String] = [Parameters.UserName:email, Parameters.Password:password]
        let dictionary = [Parameters.Dictionary: login]
        do {
            let postData = try JSONSerialization.data(withJSONObject: dictionary as [String: AnyObject])
            request.httpBody = postData
//            print(NSString(data: postData, encoding: String.Encoding.utf8.rawValue)!)
            
        } catch {

            sendAlert(loginViewController, message: "Unable to parse data as JSON")
            return
        }
        
        udacityTask(with: request) {(result, error) in
            guard error == nil else {
                notifyUser(loginViewController, message: "received error: \(error!.localizedDescription)")
                return
            }
            guard let credentials =  result?[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject] else{
                //notify user
                notifyUser(loginViewController, message: "Account not found")
                return
            }
            guard let enrolled = credentials[UdacityClient.JSONResponseKeys.ValidFlag] as? Bool else{
                notifyUser(loginViewController, message:"Student not registered")
                return
            }
            guard let id = credentials[UdacityClient.JSONResponseKeys.Key] as? String else {
                notifyUser(loginViewController, message: "key not found")
                return
            }
            if enrolled{
                //Login successful so get user info
                url = self.UdacityURL(path: UdacityClient.Constants.UserInfoPath+id)
                StudentInformation.user.uniqueKey = id
                self.getUserInfo(id: id , viewController: loginViewController)

            }
            
            completionHandler(enrolled)
        
        }
    }
    
    func logout(){
    // Build URL & configure request
        let url = UdacityURL(path: UdacityClient.Constants.SessionPath)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = Methods.Logout
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //Logout of Udacity
        self.udacityTask(with: request, completionHandler: {(logoutResult,logoutError) in
            guard logoutError == nil else{
                print("Unsuccessful logout from Udacity")
                return
            }
            print("logged out of Udacity")
        })
        
    }
    
    func getUserInfo(id: String, viewController: UIViewController){
        let url = UdacityURL(path: UdacityClient.Constants.UserInfoPath+id)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = Methods.UserInfo
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")


        self.udacityTask(with: request, completionHandler: {(result, error) in
            guard error == nil else {
            // retry one time rather than notifying user as they are unable to take useful action
                self.udacityTask(with: request, completionHandler: {(result, error) in
                    guard error == nil else {
                        return
                    }
                    guard let userInfo = result?[JSONResponseKeys.User] as? [String: Any] else{
                        return
                    }
                    let firstName = userInfo[JSONResponseKeys.FirstName] as? String
                    let lastName = userInfo[JSONResponseKeys.LastName] as? String
                    
                // assign student info to struct for posting pin
                    StudentInformation.user.firstName = firstName
                    StudentInformation.user.lastName = lastName
                    return
                })

                return
            }

            guard let userInfo = result?[JSONResponseKeys.User] as? [String: Any] else{
                notifyUser(viewController, message: "Key: user not found in results")
                return
            }
            let firstName = userInfo[JSONResponseKeys.FirstName] as? String
            let lastName = userInfo[JSONResponseKeys.LastName] as? String
            
    // assign student info to struct for posting pin
            StudentInformation.user.firstName = firstName
            StudentInformation.user.lastName = lastName
            
        })

    
    }
    // MARK: Helpers    
    private func udacityTask(with request: NSMutableURLRequest, completionHandler: @escaping (_ results: AnyObject?, _ error: NSError?)->Void){
        let session = URLSession.shared
        var task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "makeRequest", code: 1, userInfo: userInfo))
            }
            if error != nil { // Handle error…
                sendError(" \(error!.localizedDescription)")
                return
            }
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            guard  statusCode >= 200 && statusCode <= 299 else {
                if statusCode == 403{
                    sendError("Invalid username or password")   //Reviewer didn't like "forbidden" message shown to user
                }
                else{
                    sendError(" \(HTTPURLResponse.localizedString(forStatusCode:statusCode))")
                }
                return
            }
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            let newData = self.getValidData(data)            
//            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertData: completionHandler)
       
        }
        task.resume()
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
    
    //ignore first 5 charcaters returned from Udacity
    func getValidData(_ data: Data?)->Data?{
        let range = Range(uncheckedBounds: (5, data!.count ))
        let newData = data?.subdata(in: range)
        return newData
    }
    
    //build Udacity URL
    private func UdacityURL(path: String)-> URL{
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = path
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
