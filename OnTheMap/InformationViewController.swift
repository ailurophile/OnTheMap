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
    
    var location: String = ""
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
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
            
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = location
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: {(response, error) in
                print(response as Any)
                if (error != nil){
                    print("error: \(error)")
                }
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
