//
//  LogInViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit

import Parse
import Bolts

class LogInViewController: UIViewController {

    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginFunction(sender: UIButton) {
        userLogin(usernameField.text, password: passwordField.text);
    }
    
    func userLogin(username: String, password:String) {
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        var usernameLen = count(username);
        var passwordLen = count(password);
        
        if (usernameLen == 0 || passwordLen == 0) {
            var alert = UIAlertController(title: "Submission Failure", message: "Invalid username or password", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user, error) -> Void in
            if (user != nil) {
                defaults.setObject(self.usernameField.text, forKey: Constants.UserKeys.usernameKey);
                
                var query = PFQuery(className:"Profile");
                var currentID = PFUser.currentUser()!.objectId;
                query.whereKey("ID", equalTo:currentID!);
                
                query.getFirstObjectInBackgroundWithBlock {
                    (profile: PFObject?, error: NSError?) -> Void in
                    if error != nil || profile == nil {
                        println(error);
                    } else if let profile = profile {
                        defaults.setObject(profile["Name"], forKey: Constants.UserKeys.nameKey);
                        defaults.setObject(profile["Interests"], forKey: Constants.UserKeys.interestsKey);
                        defaults.setObject(profile["Background"], forKey: Constants.UserKeys.backgroundKey);
                        defaults.setObject(profile["Website"], forKey: Constants.UserKeys.websiteKey);
                        defaults.setObject(profile["Distance"], forKey: Constants.UserKeys.distanceKey);
                    }
                }

                
                self.dismissViewControllerAnimated(true, completion: nil);
            }
            else {
                var alert = UIAlertController(title: "Log-In Failed", message: "Username or password is incorrect", preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
                self.presentViewController(alert, animated: true, completion: nil);
            }
        }
    }
    
    func dismissToHomePage() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var usernamePlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        var passwordPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        
        usernameField.attributedPlaceholder = usernamePlaceholder;
        passwordField.attributedPlaceholder = passwordPlaceholder;
        
        usernameField.layer.cornerRadius = 0;
        passwordField.layer.cornerRadius = 0;
        passwordField.secureTextEntry = true;

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissToHomePage", name: "dismissToHomePage", object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameField) {
            passwordField.becomeFirstResponder();
        }
        else {
            self.userLogin(usernameField.text, password: passwordField.text);
            textField.resignFirstResponder();
        }
        return true;
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
