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

class SystemSettingsTableViewController: TableViewController {
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        if (isValidEmail(emailField.text!)) {
            self.dismissViewControllerAnimated(true, completion: nil);
        } else {
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid e-mail.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "GOT IT", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var greetingTemplate: UITextView!
    // Set up local datastore
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    // Logout user and reset datastore
    @IBAction func userLogOut(sender: UIButton) {
        let query = PFQuery(className:"Profile")
        let currentID = PFUser.currentUser()!.objectId
        query.whereKey("ID", equalTo:currentID!)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                print(error);
            } else if let profile = profile {
                // Notes that the user is online
                profile["Online"] = false
                profile["Available"] = false
                profile.saveInBackground()
            }
        }
        PFUser.logOut()
        
        let dict = defaults.dictionaryRepresentation();
        for key in dict.keys {
            defaults.removeObjectForKey(key.debugDescription);
        }
        defaults.synchronize();
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    func logoutUser(sender: UIButton) {
        let query = PFQuery(className:"Profile")
        let currentID = PFUser.currentUser()!.objectId
        query.whereKey("ID", equalTo:currentID!)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                print(error);
            } else if let profile = profile {
                // Notes that the user is online
                profile["Online"] = false
                profile["Available"] = false
                profile.saveInBackground()
                PFUser.logOut()
            }
        }
        
        
        let dict = defaults.dictionaryRepresentation();
        for key in dict.keys {
            defaults.removeObjectForKey(key.debugDescription);
        }
        defaults.synchronize();
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        
        logoutButton.layer.cornerRadius = 5
        emailField.backgroundColor = UIColor.clearColor();
        let emailFieldPlaceholder = NSAttributedString(string: "E-Mail", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.blackColor();
        emailField.borderStyle = UITextBorderStyle.None;
        self.emailField.text = PFUser.currentUser()?.email;
        tableView.allowsSelection = false;
        if let template = defaults.stringForKey(Constants.UserKeys.greetingKey) {
            greetingTemplate.text = template;
        } else {
            defaults.setObject(Constants.ConstantStrings.greetingMessage, forKey: Constants.UserKeys.greetingKey);
            greetingTemplate.text = Constants.ConstantStrings.greetingMessage;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make footerview so it fill up size of the screen
        // The button is aligned to bottom of the footerview
        // using autolayout constraints
        self.tableView.tableFooterView = nil
        var footerHeight = self.tableView.frame.size.height - self.tableView.contentSize.height - self.footerView.frame.size.height
        if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_4_HEIGHT) {
            footerHeight += 160
        }
        self.footerView.frame = CGRectMake(0, 0, self.view.frame.size.width, footerHeight)
        self.tableView.tableFooterView = self.footerView
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (self.userLoggedIn()) {
            let query:PFQuery = PFQuery(className: "Profile");
            query.whereKey("ID", equalTo: PFUser.currentUser()!.objectId!);
            
            query.getFirstObjectInBackgroundWithBlock {
                (profile: PFObject?, error: NSError?) -> Void in
                if (error != nil || profile == nil) {
                    print(error);
                } else if let profile = profile {
                    PFUser.currentUser()!.email = self.emailField.text;
                    profile["Greeting"] = self.greetingTemplate.text;
                    self.defaults.setObject(self.greetingTemplate.text, forKey: Constants.UserKeys.greetingKey);
                    profile.saveInBackground();
                }
            }
        }
        super.viewWillDisappear(true);

    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
    // Converts to RGB from Hex

    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}
