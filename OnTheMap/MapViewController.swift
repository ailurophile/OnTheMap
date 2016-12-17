//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/5/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("INSIDE VIEW WILL LOAD")
        if ParseClient.sharedInstance().students == nil{
            // Do any additional setup after loading the view, typically from a nib.
            ParseClient.sharedInstance().getLocations(with: { (results,error) in
                guard error == nil else{
                    notifyUser(self, message: (error!.localizedDescription))
                    return
                }
                ParseClient.sharedInstance().students = [StudentInformation]()
                guard results != nil else{
                    notifyUser(self, message: "No locations found")
                    return
                }
                for item in results!{
                    let student = StudentInformation(item)
                    ParseClient.sharedInstance().students.append(student)
                }
                
                
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if ParseClient.sharedInstance().students == nil{
        // Do any additional setup after loading the view, typically from a nib.
            ParseClient.sharedInstance().getLocations(with: { (results,error) in
                guard error == nil else{
                    notifyUser(self, message: (error!.localizedDescription))
                    return
                }
                ParseClient.sharedInstance().students = [StudentInformation]()
                guard results != nil else{
                    notifyUser(self, message: "No locations found")
                    return
                }
                for item in results!{
                    let student = StudentInformation(item)
                    ParseClient.sharedInstance().students.append(student)
                }
            
            
        })
        }
 */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

