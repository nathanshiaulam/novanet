//
//  SystemSettingsTableViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class SystemSettingsTableViewController: UITableViewController {
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        if (isValidEmail(emailField.text)) {
            self.dismissViewControllerAnimated(true, completion: nil);
        } else {
            var alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid e-mail.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "GOT IT", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    @IBOutlet weak var availableSwich: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var greetingTemplate: UITextView!
    // Set up local datastore
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    // Logout user and reset datastore
    @IBAction func userLogOut(sender: UIButton) {
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                // Notes that the user is online
                profile["Online"] = false;
                profile.saveInBackground();
            }
        }
        PFUser.logOut();
        
        var dict = defaults.dictionaryRepresentation();
        for key in dict.keys {
            defaults.removeObjectForKey(key.description);
        }
        defaults.synchronize();
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        emailField.backgroundColor = UIColor.clearColor();
        var emailFieldPlaceholder = NSAttributedString(string: "E-Mail", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.blackColor();
        emailField.borderStyle = UITextBorderStyle.None;
        self.emailField.text = PFUser.currentUser()?.email;
        
        if let available: AnyObject = defaults.objectForKey(Constants.UserKeys.availableKey) {
            if (available as! NSObject == true) {
                availableSwich.on = true;
            } else {
                availableSwich.on = false;
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        var query:PFQuery = PFQuery(className: "Profile");
        query.whereKey("ID", equalTo: PFUser.currentUser()!.objectId!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if (error != nil || profile == nil) {
                println(error);
            } else if let profile = profile {
                if self.availableSwich.on == true {
                    self.defaults.setObject(true, forKey: Constants.UserKeys.availableKey);
                    profile["Available"] = true
                } else {
                    self.defaults.setObject(false, forKey: Constants.UserKeys.availableKey);
                    profile["Available"] = false;
                }
                profile["Email"] = self.emailField.text;
                profile.saveInBackground();
            }
        }
        super.viewWillDisappear(true);

    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Converts to RGB from Hex
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}
