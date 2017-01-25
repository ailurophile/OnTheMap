//
//  LinkPostingViewController.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 1/20/17.
//  Copyright © 2017 Lisa Litchfield. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class LinkPostingViewController: UIViewController, UITextViewDelegate{
  
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextView: UITextView!



    var link: String = ""
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextView.delegate = self
        let annotation = MapViewController.getAnnotation(student: ParseClient.sharedInstance().user)
        self.mapView.addAnnotation(annotation )
        mapView.centerCoordinate = annotation.coordinate
//        let rect = MKMapRect(annotation.coordinate)
//        mapView.mapRectThatFits(<#T##mapRect: MKMapRect##MKMapRect#>)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        //        locationTextView.text = ""
        textView.text = ""
    }
    func textViewDidChange(_ textView: UITextView) {
        
        link = linkTextView.text
       
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("I'm touched!")
        resignFirstResponder()
    }
    //MARK Map functions
    @IBAction func urlEntered(_ sender: UIButton) {
        print("url: \(link)")
        ParseClient.sharedInstance().user.link = link
        
        
        //Check if pin already exists for user
        ParseClient.sharedInstance().findLocation( _with: {(result,error) in
            guard error == nil else{
                notifyUser(self, message: "Error encountered while searching for existing pin")
                return
            }
            if let results = result {
                print(results)
                print("ask user whether to update here") // if updated update model
                DispatchQueue.main.sync {
                let controller = UIAlertController()
                controller.message = "A pin exists for this user.  Do you want to overwrite it?"
                let overwriteAction = UIAlertAction(title: "OVERWRITE", style: .destructive) { action in
                    let locationInfo = (result as? AnyObject)?[ParseClient.JSONResponseKeys.Results] as? [[String:AnyObject]]
//                    guard let objectInfo = locationInfo
//                    let id = locationInfo?[ParseClient.JSONResponseKeys.ObjectID] as? String
//                    ParseClient.sharedInstance().user.objectID = id
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
}
