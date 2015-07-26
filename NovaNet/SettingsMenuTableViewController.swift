//
//  SettingsMenuTableViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts


class SettingsMenuTableViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var backgroundField: UITextField!
    @IBOutlet weak var interestsField: UITextField!
    @IBOutlet weak var goalsField: UITextField!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults(); // Create local datastore to change profile values
    
    // Changes label when slider value changes
    @IBAction func sliderValueChanged(sender: UISlider) {
        var floatDistance = floor(sender.value);
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if (floatDistance == 1) {
            self.distanceLabel.text = NSString(format:"%.0f", floatDistance) as String + " kilometer";
        } else {
            self.distanceLabel.text = NSString(format:"%.0f", floatDistance) as String + " kilometers";
        }
        defaults.setObject(Int(floatDistance), forKey: Constants.UserKeys.distanceKey);
    }

    @IBAction func userLogout(sender: UIButton) {
        PFUser.logOut();
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var dict = defaults.dictionaryRepresentation();
        for key in dict.keys {
            defaults.removeObjectForKey(key.description);
        }
        defaults.synchronize();
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    @IBAction func saveFunction(sender: UIBarButtonItem) {
        
        let distance = defaults.integerForKey(Constants.UserKeys.distanceKey);
        
        if (count(nameField.text) > 0 && count(backgroundField.text) > 0 && count(interestsField.text) > 0) {
            
            defaults.setObject(nameField.text, forKey: Constants.UserKeys.nameKey);
            defaults.setObject(backgroundField.text, forKey: Constants.UserKeys.backgroundKey);
            defaults.setObject(interestsField.text, forKey: Constants.UserKeys.interestsKey);
            defaults.setObject(goalsField.text, forKey: Constants.UserKeys.goalsKey);
            
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
                    profile["Goals"] = self.goalsField.text;
                    profile["Distance"] = distance;
                    profile.saveInBackground();
                }
            }
            self.navigationController?.popViewControllerAnimated(true);
            
        } else {
            var alert = UIAlertController(title: "Empty Field", message: "Please enter all essential fields.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == nameField) {
            backgroundField.becomeFirstResponder();
        }
        else if (textField == backgroundField) {
            textField.resignFirstResponder()
            interestsField.becomeFirstResponder();
        }
        else if (textField == interestsField){
            textField.resignFirstResponder();
            goalsField.becomeFirstResponder();
        }
        else {
            textField.resignFirstResponder();
        }
        return false;
    }
    
    override func viewDidAppear(animated: Bool) {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var distanceValue = defaults.integerForKey(Constants.UserKeys.distanceKey);
        if (distanceValue == 1) {
            self.distanceLabel.text = String(distanceValue) + " kilometer";
        } else {
            self.distanceLabel.text = String(distanceValue)  + " kilometers";
        }
        distanceSlider.setValue(Float(distanceValue), animated: true);
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0;
        }
        else {
            return 40;
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > count(textField.text) )
        {
            return false;
        }
        
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 60;
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var label = UILabel();
        if section == 0 {
        }
        label.backgroundColor = UIColorFromHex(0x555555, alpha: 1.0);
        return label;
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults(); // Sets up local datastore to access profile values
        
        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject];
        
        var view = UIView();
        view.backgroundColor = UIColorFromHex(0x555555, alpha: 1.0);
        
        self.tableView.tableFooterView = view;
        // Sets all of the placeholder texts/removes borders for text fields
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.backgroundColor = UIColor.clearColor();
        var nameFieldPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.whiteColor();

        backgroundField.borderStyle = UITextBorderStyle.None;
        backgroundField.backgroundColor = UIColor.clearColor();
        var backgroundPlaceholder = NSAttributedString(string: "About", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()]);
        backgroundField.attributedPlaceholder = backgroundPlaceholder;
        backgroundField.textColor = UIColor.whiteColor();
        
        interestsField.borderStyle = UITextBorderStyle.None;
        interestsField.backgroundColor = UIColor.clearColor();
        var interestsPlaceholder = NSAttributedString(string: "Interests (Please enter three)", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()]);
        interestsField.attributedPlaceholder = interestsPlaceholder;
        interestsField.textColor = UIColor.whiteColor();
        
        goalsField.borderStyle = UITextBorderStyle.None;
        goalsField.backgroundColor = UIColor.clearColor();
        var goalsPlaceholder = NSAttributedString(string: "Main Goals", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()]);
        goalsField.attributedPlaceholder = interestsPlaceholder;
        goalsField.textColor = UIColor.whiteColor();
        
        // If profile is in existence, sets value for each field
        if let name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameField.text = name;
        }
        if let interests = defaults.stringForKey(Constants.UserKeys.interestsKey) {
            interestsField.text = interests;
        }
        if let background = defaults.stringForKey(Constants.UserKeys.backgroundKey) {
            backgroundField.text = background;
        }
        if let goals = defaults.stringForKey(Constants.UserKeys.goalsKey) {
            goalsField.text = goals;
        }
        var distanceValue = defaults.integerForKey(Constants.UserKeys.distanceKey);
        if (distanceValue == 1) {
            self.distanceLabel.text = String(distanceValue) + " kilometer";
        } else {
            self.distanceLabel.text = String(distanceValue)  + " kilometers";
        }
        distanceSlider.setValue(Float(distanceValue), animated: true);
    }
}
