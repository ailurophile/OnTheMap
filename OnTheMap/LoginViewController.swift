//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Lisa Litchfield on 12/6/16.
//  Copyright © 2016 Lisa Litchfield. All rights reserved.
//


import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var email: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        loginButton.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
//        if (emailTextField.text != "" && passwordTextField == textField) ||
//            (passwordTextField.text != "" && emailTextField == textField){
//            loginButton.isEnabled = true
//        }
    }
/*    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == emailTextField{
            email = emailTextField.text!
        }
        else{
            password = passwordTextField.text!
        }
    } 
 */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
/*       if textField == emailTextField{
            email = emailTextField.text!
        }
        else{
            password = passwordTextField.text!
        }
//        if emailTextField.text != "" && passwordTextField.text != ""{
//            loginButton.isEnabled = true
//        }*/
        textField.resignFirstResponder()
        return true
    }
/*    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField{
            email = emailTextField.text!
        }
        else{
            password = passwordTextField.text!
        }
        if email != "" && password != ""{
            loginButton.isEnabled = true
        }
        return true
    }
*/
    @IBAction func loginPressed(){
        if emailTextField.text! != emailTextField.placeholder{
            print("email text field = \(emailTextField.text) placeholder = \(emailTextField.placeholder)")
            email = emailTextField.text!
        }

        if passwordTextField.text! != passwordTextField.placeholder{
            password = passwordTextField.text!
        }
        print("Login pressed with email: \(email) and password: \(password)")
        if(verifyFields() == true){
            //login to Udacity
            UdacityClient.sharedInstance().login(self, email:email, password: password)
        }
    }
    //MARK: Helper functions
    // Thank you to Jordi Bruin for the validateEmail function from Stack Overflow
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    func verifyFields()->Bool{
        var errorString = ""
        if validateEmail(candidate: email) != true {
            errorString = "Invalid email adress entered"
        }
        if email == "" || password == ""{
            errorString = "Empty user name or password"
        }

        if errorString != "" {
            let controller = UIAlertController()
            controller.message = errorString
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default){ action in
                self.dismiss(animated: true, completion: nil)
                }
            controller.addAction(dismissAction)
            present(controller, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
}
