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
    
//dismiss both link posting and information posting view controllers to return to tabbed view
    @IBAction func dismiss(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {self.presenter.dismiss(animated: false, completion: nil)})
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextView.delegate = self
        let annotation = MapViewController.getAnnotation(student: StudentInformation.user)
        self.mapView.addAnnotation(annotation )
        mapView.centerCoordinate = annotation.coordinate

    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        //        locationTextView.text = ""
        textView.text = ""
    }
    func textViewDidChange(_ textView: UITextView) {
        
        link = linkTextView.text
       
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirstResponder()
        view.endEditing(true)
    }
    //MARK Map functions
    @IBAction func urlEntered(_ sender: UIButton) {
        //update link in model
        StudentInformation.user.link = link
        //Check if pin already exists for user
        ParseClient.sharedInstance().findLocation( _with: {(result,error) in
            guard error == nil else{
                notifyUser(self, message: "Error encountered while searching for existing pin")
                return
            }
            if let results = result {
                if results.count == 0{
        //post location to Parse
                    ParseClient.sharedInstance().postLocation( with:{ (result, error) in
                        guard error == nil else{
                            notifyUser(self, message: "Error posting pin to map")
                            return
                        }
        // update model and send notification
//                        ParseClient.sharedInstance().students.insert(ParseClient.sharedInstance().user, at: 0)
                        StudentInformation.array.insert(StudentInformation.user, at: 0)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: self)
                        DispatchQueue.main.sync {
                            self.dismiss(self)
                        }
                    })
                    
                }
                else{
                    DispatchQueue.main.sync {
                        let controller = UIAlertController(title: "Alert", message: "A pin exists for this user.  Do you want to overwrite it?", preferredStyle: .alert)
//                        controller.message = "A pin exists for this user.  Do you want to overwrite it?"
                        
                        
                        let overwriteAction = UIAlertAction(title: "OVERWRITE", style: .destructive) { action in
                            for object in results {
                                let id = object[ParseClient.JSONResponseKeys.ObjectID]
                                StudentInformation.user.objectID = id as! String?
                            }


                            ParseClient.sharedInstance().updateLocation(){(results,error) in
                                guard error == nil else {
                                    notifyUser(self, message: "Overwrite unsuccessful")
                                    return
                                }
                                
                                // update model
//                                for (index, student) in ParseClient.sharedInstance().students.enumerated(){
                                for (index, student) in StudentInformation.array.enumerated(){

                                    if student == StudentInformation.user{
                                        StudentInformation.array.remove(at: index)
                                        break
                                    }
                                }
                                StudentInformation.array.insert(StudentInformation.user, at: 0)
                                NotificationCenter.default.post(name: Notification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: self)
                                DispatchQueue.main.sync {
                                    self.dismiss(self)
                                }
                            }
                        }
//                        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: {action in self.dismiss(animated: true, completion: nil)})
                        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: {action in self.dismiss(self)})
                        controller.addAction(overwriteAction)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                }
                
            }
            else {
            //post location to Parse

                ParseClient.sharedInstance().postLocation( with:{ (result, error) in
                    guard error == nil else{
                        notifyUser(self, message: "Received error: \(error?.localizedDescription)")
                        return
                    }
            // update model and send notification
                    StudentInformation.array.insert(StudentInformation.user, at: 0)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: self)
                    
                    
                    
                })
            }
            
        })
    }
}
