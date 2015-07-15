//
//  SettingsMenuTableViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse

class SettingsMenuTableViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var backgroundField: UITextField!
    @IBOutlet weak var interestsField: UITextField!
    
    @IBAction func saveFunction(sender: UIBarButtonItem) {
        
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults(); // Create local datastore to change profile values
        let name = defaults.stringForKey(Constants.UserKeys.nameKey); // Checks if we should update or create new profile
        
        if (count(nameField.text) > 0 && count(backgroundField.text) > 0 && count(interestsField.text) > 0) {
            if (name == nil) { // Save new profile
                var newProfile = PFObject(className:"Profile");
                newProfile["ID"] = PFUser.currentUser()!.objectId;
                newProfile["Name"] = nameField.text;
                newProfile["Interests"] = interestsField.text;
                newProfile["Background"] = backgroundField.text;
                newProfile["Website"] = websiteField.text;
                
                newProfile.save();
            } else { // Update current profile
                var query = PFQuery(className:"Profile");
                var currentID = PFUser.currentUser()!.objectId;
                query.whereKey("ID", equalTo:currentID!);
                
                query.getFirstObjectInBackgroundWithBlock {
                    (profile: PFObject?, error: NSError?) -> Void in
                    if error != nil || profile == nil {
                        println(error);
                    } else if let profile = profile {
                        profile["Name"] = self.nameField.text;
                        profile["Interests"] = self.interestsField.text;
                        profile["Background"] = self.backgroundField.text;
                        profile["Website"] = self.websiteField.text;
                        profile.saveInBackground();
                    }
                }
            }
            
            defaults.setObject(nameField.text, forKey: Constants.UserKeys.nameKey);
            defaults.setObject(backgroundField.text, forKey: Constants.UserKeys.backgroundKey);
            defaults.setObject(interestsField.text, forKey: Constants.UserKeys.interestsKey);
            if (count(websiteField.text) > 0) {
                defaults.setObject(websiteField.text, forKey: Constants.UserKeys.websiteKey);
            }
            self.dismissViewControllerAnimated(true, completion: nil);
            
        } else {
            var alert = UIAlertController(title: "Empty Field", message: "Please enter all essential fields.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults(); // Sets up local datastore to access profile values
        
        // Sets all of the placeholder texts/removes borders for text fields
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.backgroundColor = UIColor.clearColor();
        var nameFieldPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        
        websiteField.borderStyle = UITextBorderStyle.None;
        websiteField.backgroundColor = UIColor.clearColor();
        var websiteFieldPlaceholder = NSAttributedString(string: "Website (Optional)", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()]);
        websiteField.attributedPlaceholder = websiteFieldPlaceholder;
        
        backgroundField.borderStyle = UITextBorderStyle.None;
        backgroundField.backgroundColor = UIColor.clearColor();
        var backgroundPlaceholder = NSAttributedString(string: "About", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()]);
        backgroundField.attributedPlaceholder = backgroundPlaceholder;
        
        interestsField.borderStyle = UITextBorderStyle.None;
        interestsField.backgroundColor = UIColor.clearColor();
        var interestsPlaceholder = NSAttributedString(string: "Interests (Please enter three)", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()]);
        interestsField.attributedPlaceholder = interestsPlaceholder;
        
        // If profile is in existence, sets value for each field
        if let name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameField.text = name;
        }
        if let website = defaults.stringForKey(Constants.UserKeys.websiteKey) {
            websiteField.text = website;
        }
        if let interests = defaults.stringForKey(Constants.UserKeys.interestsKey) {
            interestsField.text = interests;
        }
        if let background = defaults.stringForKey(Constants.UserKeys.backgroundKey) {
            backgroundField.text = background;
        }
    }
}
