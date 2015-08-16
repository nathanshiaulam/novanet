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
    
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
        
    }
  
    /*-------------------------------- HELPER METHODS ------------------------------------*/
   
    // Sets up installation so that the current user receives push notifications
    func setUpInstallations() {
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
    }
    
    // Prepares username, distance, and fromNew in datastore and puts the user online
    func prepareDataStore() {
        self.defaults.setObject(self.usernameField.text, forKey: Constants.UserKeys.usernameKey);
        self.defaults.setObject(PFUser.currentUser()?.email, forKey: Constants.UserKeys.emailKey);
        self.defaults.setObject(25, forKey: Constants.UserKeys.distanceKey);
        self.defaults.setObject(true, forKey: Constants.TempKeys.fromNew);
    }
    
    // Creates user with information
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
        
        defaults.setObject(email, forKey: Constants.UserKeys.emailKey);
        
        newUser.signUpInBackgroundWithBlock {
            (succeeded, error) -> Void in
            if (error == nil) {
                
                // Sets up basic properites for user
                self.setUpInstallations();
                self.prepareDataStore()
                
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("dismissToHomePage", object: nil);
                })
                self.dismissViewControllerAnimated(true, completion: nil);
            } else {
                // Show the errorString somewhere and let the user try again.
                let errorString = error!.userInfo!["error"] as! NSString;
                var alert = UIAlertController(title: "Submission Failure", message: errorString as String, preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: nil));
                self.presentViewController(alert, animated: true, completion: nil);
            }
        }
    }
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(textField: UITextField)-> Bool {
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        if (textField == usernameField) {
            emailField.becomeFirstResponder();
        }
        else if (textField == emailField) {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder();
        }
        else {
            self.createUser(usernameField.text, password: passwordField.text, email:emailField.text);
            textField.resignFirstResponder();
        }
        return false;
    }
    
    // Converts RGB values to hex
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    // Basically style and format all of the textfields
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);
        
        passwordField.secureTextEntry = true;
        
        var userFrameRect = usernameField.frame;
        var passwordFrameRect = passwordField.frame;
        var emailFrameRect = emailField.frame;

        userFrameRect.size.height = 200;
        passwordFrameRect.size.height = 200;
        emailFrameRect.size.height = 200;
        
        
        usernameField.frame = userFrameRect;
        passwordField.frame = passwordFrameRect;
        emailField.frame = emailFrameRect;
        
        usernameField.layer.cornerRadius = 15;
        passwordField.layer.cornerRadius = 15;
        emailField.layer.cornerRadius = 15;
        
//        usernameField.leftViewMode = UITextFieldViewMode.Always;
//        usernameField.leftView = UIImageView(image: UIImage(named: "fika"));
//        
//        passwordField.leftViewMode = UITextFieldViewMode.Always;
//        passwordField.leftView =  UIImageView(image: UIImage(named: "fika"));
//        
//        emailField.leftViewMode = UITextFieldViewMode.Always;
//        emailField.leftView =  UIImageView(image: UIImage(named: "fika"));
//
//        
        var usernameFieldPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        usernameField.attributedPlaceholder = usernameFieldPlaceholder;
        usernameField.textColor = UIColor.whiteColor();
        
        var passwordFieldPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.whiteColor();
        
        var emailFieldPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.whiteColor();
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
