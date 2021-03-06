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
        mapView.reloadInputViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadModel), name: NSNotification.Name(rawValue: ParseClient.Constants.ModelUpdatedNotificationKey), object: nil)
       
        //Load student information if not already available
        if StudentInformation.array.count == 0 {
            ParseClient.sharedInstance().getLocations(with: { (results,error) in
                guard error == nil else{
                    notifyUser(self, message: (error!.localizedDescription))
                    return
                }
                StudentInformation.array = [StudentInformation]()
                guard results != nil else{
                    notifyUser(self, message: "No locations found")
                    return
                }
                for item in results!{
                    let student = StudentInformation(item)
                    StudentInformation.array.append(student)
                }

                //Create annotations array if it does not yet exist
                if self.annotations.count == 0{

                    
                    DispatchQueue.main.sync {
                        self.addAnnotationsToMap()
                        self.mapView.reloadInputViews()
                    }
                }
            })
        }
        else {
            addAnnotationsToMap()
            mapView.reloadInputViews()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.reloadInputViews()
    }
    // MARK: - MKMapViewDelegate
    
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
            if var toOpen = view.annotation?.subtitle! {
                toOpen = toOpen.replacingOccurrences(of: "\n", with: "")  //remove unwanted carriage returns
                guard let url = URL(string: toOpen) else{

                    sendAlert(self, message: "Invalid URL string")
                    return
                }
                app.open(url, options: [:], completionHandler:{(success) in
                    if success == false{
                        sendAlert(self, message: "Unable to open URL")
                    }
                })
                
            }
        }
    }
    
    private func addAnnotationsToMap(){

        annotations.removeAll()
        for student in StudentInformation.array{
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
        DispatchQueue.main.sync {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addAnnotationsToMap()
            self.mapView.reloadInputViews()
        }
    }

    @IBAction func logout(_ sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().logout()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

