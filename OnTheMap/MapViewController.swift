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
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("INSIDE VIEW WILL LOAD")
        mapView.reloadInputViews()
/*        if ParseClient.sharedInstance().students == nil{
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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("INSIDE VIEW DID LOAD")
        var annotations = [MKPointAnnotation]()
        //Load student information if not already available
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
/*                print("accessin shared instance")
                for student in ParseClient.sharedInstance().students{
                    print(student.firstName as Any)
                }
 */
                //Create annotations array if it does not yet exist
                if annotations.count == 0{
                    for student in ParseClient.sharedInstance().students{
                        
 /*                       let lat = CLLocationDegrees(student.latitude  ?? ParseClient.Constants.DefaultLatitude)
                        let long = CLLocationDegrees(student.longitude ?? ParseClient.Constants.DefaultLongitude)
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        //create annotation
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(student.firstName!) \(student.lastName!)"
                        annotation.subtitle = student.link
                        //add annotaion to array
 
                        annotations.append(annotation)
 */
                        let annotation = MapViewController.getAnnotation(student: student)
                        annotations.append(annotation)
                        print(student.firstName)
                        
                    }
                               self.mapView.addAnnotations(annotations)
                }
                
                
            })
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.reloadInputViews()
    }
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    class func getAnnotation(student: StudentInformation)-> MKPointAnnotation{
        let lat = CLLocationDegrees(student.latitude  ?? ParseClient.Constants.DefaultLatitude)
        let long = CLLocationDegrees(student.longitude ?? ParseClient.Constants.DefaultLongitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        //create annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(student.firstName!) \(student.lastName!)"
        annotation.subtitle = student.link
        return annotation

        
    }

    @IBAction func logout(_ sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().logout()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

