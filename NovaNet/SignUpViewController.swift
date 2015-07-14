//
//  SignUpViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit

import Parse
import Bolts

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBAction func cancelFunction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    @IBAction func signUpFunction(sender: UIButton) {
        self.createUser(usernameField.text, password:passwordField.text, email:emailField.text);
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
        
    }
    
    func createUser(username: String, password: String, email: String) {
        var newUser = PFUser();
        
        // Ensures that fields are not equal
        if (count(username) == 0 || count(password) == 0 || count(email) == 0) {
            var alert = UIAlertController(title: "Submission Failure", message: "Invalid username, password, or email", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        // Sets attributes of new users
        newUser.email = email;
        newUser.password = password;
        newUser.username = username;
        
        newUser.signUpInBackgroundWithBlock {
            (succeeded, error) -> Void in
            if (error == nil) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("showTutorial", object: nil);
                })
                self.dismissViewControllerAnimated(true, completion: nil);
                self.navigationController?.popToRootViewControllerAnimated(true);
            } else {
                let errorString = error!.userInfo!["error"] as! NSString;
                var alert = UIAlertController(title: "Submission Failure", message: errorString as String, preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: nil));
                self.presentViewController(alert, animated: true, completion: nil);
                // Show the errorString somewhere and let the user try again.
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField)-> Bool {
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        if (textField == usernameField) {
            passwordField.becomeFirstResponder();
        }
        else if (textField == passwordField) {
            textField.resignFirstResponder()
            emailField.becomeFirstResponder();
        }
        else {
            self.createUser(usernameField.text, password: passwordField.text, email:emailField.text);
            textField.resignFirstResponder();
        }
        return false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var usernamePlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        var passwordPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        var emailPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        usernameField.attributedPlaceholder = usernamePlaceholder;
        passwordField.attributedPlaceholder = passwordPlaceholder;
        emailField.attributedPlaceholder = emailPlaceholder;
        usernameField.layer.cornerRadius = 0;
        passwordField.layer.cornerRadius = 0;
        emailField.layer.cornerRadius = 0;
        passwordField.secureTextEntry = true;
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
