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
    var keyboardPresent = false
    var viewShift: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        loginButton.isEnabled = false
        // Register for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillMove), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillMove), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: text field functions
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
    //MARK: Login functions
    @IBAction func loginPressed(){
        if emailTextField.text! != emailTextField.placeholder{
//            print("email text field = \(emailTextField.text) placeholder = \(emailTextField.placeholder)")
            email = emailTextField.text!
        }

        if passwordTextField.text! != passwordTextField.placeholder{
            password = passwordTextField.text!
        }
//        print("Login pressed with email: \(email) and password: \(password)")
        if(verifyFields() == true){
            //login to Udacity
            UdacityClient.sharedInstance().login(self, email:email, password: password)
        }
    }
    @IBAction func signUpForAccount(_ sender: Any) {
        let app = UIApplication.shared
        app.open(URL(string: UdacityClient.Constants.GetUserAccount)!, options: [:], completionHandler: nil)
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
    //MARK: Keyboard functions
    func keyboardWillHide(_ notification: Notification){
        if keyboardPresent{
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
//        keyboardPresent = false
        
    }
    func keyboardWillShow(_ notification: Notification){
        if !keyboardPresent{
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            
        }
//        keyboardPresent = true
        
    }
    func keyboardDidHide(_ notification: Notification){
        keyboardPresent = false
    
    }
    func keyboardDidShow(_ notification: Notification){
        keyboardPresent = true
    }
    func keyboardWillMove(_ notification: Notification){
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            
            viewShift = 0.0
            view.frame.origin.y = viewShift
            
        }
        else {
            
            let height = getKeyboardHeight(notification)
            if height != viewShift{
                viewShift = height
                view.frame.origin.y = viewShift*(-1.0)
                
            }
        }
    }

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
}
