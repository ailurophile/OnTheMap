//
//  notifyUser.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/15/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//  This method is used from within completion handlers to present an alert to the user
//  on the Main queue.

import Foundation
import UIKit

func notifyUser(_ viewController: UIViewController, message:String){
    DispatchQueue.main.sync {
        let controller = UIAlertController()
        controller.message = message
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default){ action in
            viewController.dismiss(animated: true, completion: nil)
        }
        controller.addAction(dismissAction)
        viewController.present(controller, animated: true, completion: nil)
    }
}
