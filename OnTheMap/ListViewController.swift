//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/5/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().logout()
        self.dismiss(animated: true, completion: nil)
    }
    //MARK Table delegate functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().students.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pinLocation") as UITableViewCell!
        if cell == nil {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "pinLocation")
        }
        
        let student = ParseClient.sharedInstance().students[indexPath.row]
        cell?.textLabel?.text = student.firstName! + " " + (student.lastName)!
        cell?.imageView?.image = #imageLiteral(resourceName: "pin")
        return cell!
    }

}

