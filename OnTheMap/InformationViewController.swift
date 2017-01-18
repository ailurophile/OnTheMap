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
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet var linkView: UIView!
    @IBOutlet var locationView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var location: String = ""
    var link: String = ""
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
        linkTextView.delegate = self
        self.activityIndicator.stopAnimating()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
//        locationTextView.text = ""
        textView.text = ""
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView == locationTextView{
            location = locationTextView.text
        }
        else {
            link = linkTextView.text
        }
    }
    //MARK Map functions
    @IBAction func urlEntered(_ sender: UIButton) {
        print("url: \(link)")
        ParseClient.sharedInstance().user.link = link
        
        let url = URL(string: link)
        
        //Check if pin already exists for user
        ParseClient.sharedInstance().findLocation( _with: {(result,error) in
            guard error == nil else{
                notifyUser(self, message: "Error encountered while searching for existing pin")
                return
            }
            if let result = result{
                print(result)
                print("ask user whether to update here")
            }
                
                /*                if false{
                 return
                 }
                 */
            else {
                //post location to Parse
                //                        ParseClient.sharedInstance().postLocation(pin: ParseClient.sharedInstance().user, with:
                ParseClient.sharedInstance().postLocation( with:{ (result, error) in
                    guard error == nil else{
                        notifyUser(self, message: "Error posting pin to map")
                        print("Posting error: ",error?.localizedDescription)
                        return
                    }
                    // use result
                    print(result)
                    
                })
            }

        })
    }
    
    
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
                guard let mapItem = response?.mapItems[0] else{
                    print("no location found!")
                    self.activityIndicator.stopAnimating()
                    return
                }

                ParseClient.sharedInstance().user.longitude = Float(mapItem.placemark.coordinate.longitude)
                ParseClient.sharedInstance().user.latitude = Float(mapItem.placemark.coordinate.latitude)
                print("mapItem = \(mapItem)")
                self.activityIndicator.stopAnimating()
                if (error != nil){
                    print("error: \(error)")
                    return
                }
                UIView.transition(from: self.locationView, to: self.linkView, duration: 2, options: .layoutSubviews, completion:{(finished) in
                    while(finished != true) {
                        continue
                    }
                    let annotation = MapViewController.getAnnotation(student: ParseClient.sharedInstance().user)
                    self.mapView.addAnnotation(annotation )})

                //show pin on map and get link
//                self.mapView.addAnnotation(annotation as! MKAnnotation)
/*                let url = URL(string: self.link)
                
                annotation.url = url
                
                ParseClient.sharedInstance().user.link = UdacityClient.Constants.ApiHost
                //Check if pin already exists for user
                ParseClient.sharedInstance().findLocation( _with: {(result,error) in
                    guard error == nil else{
                        notifyUser(self, message: "Error encountered while searching for existing pin")
                        return
                    }
                    if let result = result{
                        print(result)
                        print("ask user whether to update here")
                    }
 
/*                if false{
                    return
                }
 */
                    else {
                        //post location to Parse
//                        ParseClient.sharedInstance().postLocation(pin: ParseClient.sharedInstance().user, with:
                        ParseClient.sharedInstance().postLocation( with:{ (result, error) in
                            guard error == nil else{
                                notifyUser(self, message: "Error posting pin to map")
                                print("Posting error: ",error?.localizedDescription)
                                return
                            }
                            // use result
                            print(result)
                            
                        })
                        
                    }
                    
                    })
                */

                
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
