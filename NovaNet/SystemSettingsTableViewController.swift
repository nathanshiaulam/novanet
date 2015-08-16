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
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    @IBOutlet weak var availableSwich: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    
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
        defaults.stringForKey(Constants.UserKeys.emailKey);
        super.viewDidLoad();
        
        if let email = defaults.stringForKey(Constants.UserKeys.emailKey) {
            self.emailField.text = email;
        }
        if let available: AnyObject = defaults.objectForKey(Constants.UserKeys.availableKey) {
            if (available as! NSObject == true) {
                availableSwich.on = true;
            } else {
                availableSwich.on = false;
            }
        }
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        var availableVal = false;
//        
//        var query:PFQuery = PFQuery(className: "Profile");
//        query.whereKey("ID", equalTo: PFUser.currentUser()!.objectId!);
//        query.getFirstObjectInBackgroundWithBlock {
//            (profile: PFObject?, error: NSError?) -> Void in
//            if (error == nil) {
//                if self.availableSwich.on == true {
//                    profile["Available"] = (true as? AnyObject?)!;
//                } else {
//                     profile["Available"] = (false as? AnyObject?)!
//                    ;
//                }
//                profile["Email"] = self.defaults.objectForKey(Constants.UserKeys.emailKey);
//                profile?.saveInBackground();
//            }
//        }
//        super.viewWillDisappear(true);

//    }
//    
//}
}
