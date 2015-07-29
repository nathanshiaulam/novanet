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
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
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
                let installation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
                defaults.setObject(self.usernameField.text, forKey: Constants.UserKeys.usernameKey);
                defaults.setObject(25, forKey: Constants.UserKeys.distanceKey);
                defaults.setObject(true, forKey: Constants.TempKeys.fromNew);
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("dismissToHomePage", object: nil);
                })
                self.dismissViewControllerAnimated(true, completion: nil);
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
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults(); // Sets up local datastore to access profile values
        
        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);
        
        passwordField.secureTextEntry = true;
        
        usernameField.borderStyle = UITextBorderStyle.None;
        usernameField.backgroundColor = UIColor.clearColor();
        var usernameFieldPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        usernameField.attributedPlaceholder = usernameFieldPlaceholder;
        usernameField.textColor = UIColor.whiteColor();
        
        passwordField.borderStyle = UITextBorderStyle.None;
        passwordField.backgroundColor = UIColor.clearColor();
        var passwordFieldPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.whiteColor();
        
        emailField.borderStyle = UITextBorderStyle.None;
        emailField.backgroundColor = UIColor.clearColor();
        var emailFieldPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.whiteColor();
    }
    
    
    override func viewDidLayoutSubviews() {
        let borderName = CALayer();
        let widthName = CGFloat(2.0);
        borderName.borderColor = UIColor.darkGrayColor().CGColor;
        borderName.frame = CGRect(x: 0, y: usernameField.frame.size.height - widthName, width:  usernameField.frame.size.width, height: usernameField.frame.size.height);
        
        borderName.borderWidth = widthName;
        
        let borderPass = CALayer();
        let widthPass = CGFloat(2.0);
        borderPass.borderColor = UIColor.darkGrayColor().CGColor;
        borderPass.frame = CGRect(x: 0, y: usernameField.frame.size.height - widthPass, width:  usernameField.frame.size.width, height: usernameField.frame.size.height);
        
        borderPass.borderWidth = widthPass;
        
        let borderEmail = CALayer();
        let widthEmail = CGFloat(2.0);
        borderEmail.borderColor = UIColor.darkGrayColor().CGColor;
        borderEmail.frame = CGRect(x: 0, y: usernameField.frame.size.height - widthEmail, width:  usernameField.frame.size.width, height: usernameField.frame.size.height);
        
        borderEmail.borderWidth = widthEmail;
        
        usernameField.layer.addSublayer(borderName)
        usernameField.layer.masksToBounds = true
        
        passwordField.layer.addSublayer(borderPass);
        passwordField.layer.masksToBounds = true
        
        emailField.layer.addSublayer(borderEmail);
        emailField.layer.masksToBounds = true

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
