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
// allow carriage return to dismiss keyboard so user can access "Find on Map" button
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        else {
            return true
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    func textViewDidChange(_ textView: UITextView) {
            location = locationTextView.text
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirstResponder()
        view.endEditing(true)
    }
    @IBAction func findOnMapPressed(_ sender: UIButton) {
        // Verify user entered location string
        if location == "" {

            sendAlert(self, message: "Please enter location i.e. Cupertino, CA")

        }
        else{
        //Forward geocode location
            activityIndicator.startAnimating()
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = location
            StudentInformation.user.location = location
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: {(response, error) in
                //Use first location returned, if any
                guard let mapItem = response?.mapItems[0] else{
                    self.activityIndicator.stopAnimating()
                    sendAlert(self, message: "Location not found!")
                    return
                }
                
        //Update user coordinates in data model

                StudentInformation.user.longitude = Float(mapItem.placemark.coordinate.longitude)
                StudentInformation.user.latitude = Float(mapItem.placemark.coordinate.latitude)
                self.activityIndicator.stopAnimating()
                if (error != nil){
                    notifyUser(self, message: "There was an error with your request.")
                    return
                }
        //Present second view controller to show location and request url

                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LinkPostingViewController") as! LinkPostingViewController
                viewController.presenter = self
                self.present(viewController, animated: true, completion: nil)
            })
        }
    }
}

