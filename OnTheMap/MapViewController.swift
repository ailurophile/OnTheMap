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
    var annotations = [MKPointAnnotation]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("INSIDE VIEW WILL LOAD")
        mapView.reloadInputViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("INSIDE VIEW DID LOAD")
        
        // Register for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadModel), name: NSNotification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: nil)
       
        //Load student information if not already available
        if ParseClient.sharedInstance().students == nil{
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

                //Create annotations array if it does not yet exist
                if self.annotations.count == 0{

                    self.addAnnotationsToMap()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    private func addAnnotationsToMap(){
//        var annotations = [MKPointAnnotation]()
        for student in ParseClient.sharedInstance().students{
            let annotation = MapViewController.getAnnotation(student: student)
            annotations.append(annotation)
            
        }
        self.mapView.addAnnotations(annotations)
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
    
    @objc private func reloadModel(){
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addAnnotationsToMap()
        }
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

