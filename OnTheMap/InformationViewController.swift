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
            let controller = UIAlertController()
            controller.message = "Please enter location i.e. Cupertino, CA"
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default){ action in
                self.dismiss(animated: true, completion: nil)
            }
            controller.addAction(dismissAction)
            present(controller, animated: true, completion: nil)

        }
        else{
            //Forward geocode location
            activityIndicator.startAnimating()
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = location
            StudentInformation.user.location = location
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: {(response, error) in
//                print(response as Any)
                //Use first location returned, if any
                guard let mapItem = response?.mapItems[0] else{
                    self.activityIndicator.stopAnimating()
                    sendAlert(self, message: "Location not found!")
                    return
                }
                
                //Update user coordinates in data model

                StudentInformation.user.longitude = Float(mapItem.placemark.coordinate.longitude)
                StudentInformation.user.latitude = Float(mapItem.placemark.coordinate.latitude)
//                print("mapItem = \(mapItem)")
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

