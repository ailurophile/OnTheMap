//
//  InformationViewController.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/28/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class InformationViewController: UIViewController, UITextViewDelegate{
    @IBOutlet weak var locationTextView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var location: String = ""
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
        self.activityIndicator.stopAnimating()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        locationTextView.text = ""
    }
    func textViewDidChange(_ textView: UITextView) {
        location = locationTextView.text
    }
    //MARK Map functions
    
    @IBAction func findOnMapPressed(_ sender: UIButton) {
        print("location: \(location)")
        if location == "" {
            print("no location string entered")
/*            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            notifyUser((window?.visibleViewController)!, message: "Please enter location i.e. Cupertino, CA")
 */
//            notifyUser(self, message: "Please enter location i.e. Cupertino, CA")

        }
        else{
            activityIndicator.startAnimating()
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = location
            ParseClient.sharedInstance().user.location = location
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: {(response, error) in
                print(response as Any)
                guard let annotation = response?.mapItems[0] else{
                    print("no location found!")
                    return
                }
                let url = URL(string: UdacityClient.Constants.ApiHost)
                
                annotation.url = url
                ParseClient.sharedInstance().user.longitude = Float(annotation.placemark.coordinate.longitude)
                ParseClient.sharedInstance().user.latitude = Float(annotation.placemark.coordinate.latitude)
                print("annotation = \(annotation)")
                self.activityIndicator.stopAnimating()
                if (error != nil){
                    print("error: \(error)")
                    return
                }
//                UIView.transition(from: locationView, to: linkView, duration: <#T##TimeInterval#>, options: <#T##UIViewAnimationOptions#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
                //show pin on map and get link
                
                ParseClient.sharedInstance().user.link = UdacityClient.Constants.ApiHost
                //post location to Parse
                ParseClient.sharedInstance().postLocation(pin: ParseClient.sharedInstance().user, with:{ (result, error) in
                    guard error == nil else{
                        notifyUser(self, message: "Error posting pin to map")
                        print("Posting error: ",error?.localizedDescription)
                        return
                    }
                    // use result
                    print(result)
                    
                })
                
            })
        }
    }
}
/*
// thanks to zirinisp from stackoverflow
public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(vc: self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(vc: nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(vc: tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: pvc)
            } else {
                return vc
            }
        }
    }
}
 */
