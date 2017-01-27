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
    var presenter: UIViewController!
    
    @IBAction func dismiss(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {self.presenter.dismiss(animated: false, completion: nil)})
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
                        for object in results {
                            let id = object[ParseClient.JSONResponseKeys.ObjectID]
                            print(object)
                            print("objectID = \(id)")
                            ParseClient.sharedInstance().user.objectID = id as! String?
                        }


                        ParseClient.sharedInstance().updateLocation(){(results,error) in
                            guard error == nil else {
                                notifyUser(self, message: "Overwrite unsuccessful")
                                return
                            }
                            
                            // update model
                            for (index, student) in ParseClient.sharedInstance().students.enumerated(){
                                if student == ParseClient.sharedInstance().user{
                                    ParseClient.sharedInstance().students.remove(at: index)
                                    break
                                }
                            }
                            ParseClient.sharedInstance().students.insert(ParseClient.sharedInstance().user, at: 0)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: self)
                            DispatchQueue.main.sync {
                                self.dismiss(self)
                            }
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
