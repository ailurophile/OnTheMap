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
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var linkTextView: UITextView!
//    @IBOutlet var linkView: UIView!
//    @IBOutlet var locationView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var location: String = ""
//    var link: String = ""
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
//        linkTextView.delegate = self
        self.activityIndicator.stopAnimating()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
//        locationTextView.text = ""
        textView.text = ""
    }
    func textViewDidChange(_ textView: UITextView) {
//        if textView == locationTextView{
            location = locationTextView.text
/*        }
        else {
            link = linkTextView.text
        }*/
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("I'm touched!")
        resignFirstResponder()
    }
    //MARK Map functions
/*    @IBAction func urlEntered(_ sender: UIButton) {
        print("url: \(link)")
        ParseClient.sharedInstance().user.link = link
        
        
        //Check if pin already exists for user
        ParseClient.sharedInstance().findLocation( _with: {(result,error) in
            guard error == nil else{
                notifyUser(self, message: "Error encountered while searching for existing pin")
                return
            }
            if let result = result{
                print(result)
                print("ask user whether to update here") // if updated update model
                let controller = UIAlertController()
                controller.message = "A pin exists for this user.  Do you want to overwrite it?"
                let overwriteAction = UIAlertAction(title: "OVERWRITE", style: .destructive) { action in
                    ParseClient.sharedInstance().updateLocation(){(results,error) in
                        guard error == nil else {
                            notifyUser(self, message: "Overwrite unsuccessful")
                            return
                        }
                    
                    // update model
                        NotificationCenter.default.post(name: Notification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: self)
                    }
                }
                let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: {action in self.dismiss(animated: true, completion: nil)})
                controller.addAction(overwriteAction)
                controller.addAction(cancelAction)
                self.present(controller, animated: true, completion: nil)

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
                    // update model and send notification
                    print(result)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: self)

                    
                    
                })
            }

        })
    }
    
 */
    
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
 /*               UIView.transition(from: self.locationView, to: self.linkView, duration: 2, options: .layoutSubviews, completion:{(finished) in
                    while(finished != true) {
                        continue
                    }
                    let annotation = MapViewController.getAnnotation(student: ParseClient.sharedInstance().user)
                    self.mapView.addAnnotation(annotation )})

 */
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LinkPostingViewController") as! LinkPostingViewController
                viewController.presenter = self
                self.present(viewController, animated: true, completion: nil)
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
