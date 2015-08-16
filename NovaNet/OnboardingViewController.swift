//
//  OnboardingViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/22/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//


import UIKit
import Parse
import Bolts


class OnboardingViewController: UIViewController, UITextViewDelegate {
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lookingForField: UITextField!
    @IBOutlet weak var experienceField: UITextField!
    
    @IBOutlet weak var firstInterestField: UITextField!
    @IBOutlet weak var secondInterestField: UITextField!
    @IBOutlet weak var thirdInterestField: UITextField!

    @IBOutlet weak var aboutField: UITextView!
    
   
    // Prepares local datastore for profile information and saves profile;
    @IBAction func continueButtonPressed(sender: UIButton) {
         if (count(nameField.text) > 0 && count(experienceField.text) > 0 && count(lookingForField.text) > 0 && count(firstInterestField.text) > 0 && count(secondInterestField.text) > 0 &&
            count(thirdInterestField.text) > 0 && count(aboutField.text) > 0) {
            
            // Capitalize first letter of string
            nameField.text.replaceRange(nameField.text.startIndex...nameField.text.startIndex, with: String(nameField.text[nameField.text.startIndex]).capitalizedString)

            prepareDataStore();
            saveProfile();
        } else {
            var alert = UIAlertController(title: "Empty Field", message: "Please enter all essential fields.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    /*-------------------------------- TextViewDel Methods ------------------------------------*/

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColorFromHex(0xA6AAA9, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            println("truth");
            textView.text = "A sentence or two illustrating what you're about. Who are you in a nutshell?";
            textView.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
    }
    
    /*-------------------------------- TextFieldDel Methods ------------------------------------*/

    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(textField: UITextField)-> Bool {
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        if (textField == nameField) {
            aboutField.becomeFirstResponder();
        }
        else if (textField == experienceField) {
            textField.resignFirstResponder()
            firstInterestField.becomeFirstResponder();
        }
        else if (textField == firstInterestField) {
            textField.resignFirstResponder()
            secondInterestField.becomeFirstResponder();
        }
        else if (textField == secondInterestField) {
            textField.resignFirstResponder()
            thirdInterestField.becomeFirstResponder();
        }
        else {
            textField.resignFirstResponder();
        }
        return false;
    }
    
    // Sets the character limit of each text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > count(textField.text) )
        {
            return false;
        }
        
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 50
    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Converts to RGB from Hex
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    
    // Saves all necessary fields of the profile
    func saveProfile() {
        var newProfile = PFObject(className: "Profile");
        var interestsArr = [String]();
        interestsArr.append(firstInterestField.text);
        interestsArr.append(secondInterestField.text);
        interestsArr.append(thirdInterestField.text);
        newProfile["ID"] = PFUser.currentUser()!.objectId;
        newProfile["Name"] = nameField.text;
        newProfile["About"] = aboutField.text;
        newProfile["InterestsList"] = interestsArr;
        newProfile["Experience"] = experienceField.text;
        newProfile["Looking"] = lookingForField.text;
        newProfile["Distance"] = 25;
        newProfile["Available"] = true;
        newProfile["Online"] = true;
        newProfile.saveInBackground();
    }
    
    // Sets up the user's local datastore for profile information. Online is already set at create
    func prepareDataStore() {
        var interestsArr = [String]();
        interestsArr.append(firstInterestField.text);
        interestsArr.append(secondInterestField.text);
        interestsArr.append(thirdInterestField.text);

        defaults.setObject(nameField.text, forKey: Constants.UserKeys.nameKey);
        defaults.setObject(aboutField.text, forKey: Constants.UserKeys.aboutKey);
        defaults.setObject(experienceField.text, forKey: Constants.UserKeys.experienceKey);
        defaults.setObject(interestsArr, forKey: Constants.UserKeys.interestsKey);
        defaults.setObject(lookingForField.text, forKey: Constants.UserKeys.lookingForKey);
        defaults.setBool(true, forKey: Constants.UserKeys.availableKey);
    }
    
    // Removes keyboard when tap out of screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }

    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "2 of 4";
        nameField.backgroundColor = UIColor.clearColor();
        var nameFieldPlaceholder = NSAttributedString(string: "What's your name?", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.blackColor();
        nameField.borderStyle = UITextBorderStyle.None;
        
        aboutField.backgroundColor = UIColor.clearColor();
        aboutField.text = Constants.ConstantStrings.aboutText;
        aboutField.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0);
        
        firstInterestField.backgroundColor = UIColor.clearColor();
        var firstInterestsFieldPlaceholder = NSAttributedString(string: "Interest 1", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        firstInterestField.attributedPlaceholder = firstInterestsFieldPlaceholder;
        firstInterestField.textColor = UIColor.blackColor();
        firstInterestField.borderStyle = UITextBorderStyle.None
        
        secondInterestField.backgroundColor = UIColor.clearColor();
        var secondInterestFieldPlaceholder = NSAttributedString(string: "Interest 2", attributes: [NSForegroundColorAttributeName :UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        secondInterestField.attributedPlaceholder = secondInterestFieldPlaceholder;
        secondInterestField.textColor = UIColor.blackColor();
        secondInterestField.borderStyle = UITextBorderStyle.None
        
        thirdInterestField.backgroundColor = UIColor.clearColor();
        var thirdInterestFieldPlaceholder = NSAttributedString(string: "Interest 3", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        thirdInterestField.attributedPlaceholder = thirdInterestFieldPlaceholder;
        thirdInterestField.textColor = UIColor.blackColor();
        thirdInterestField.borderStyle = UITextBorderStyle.None

        experienceField.backgroundColor = UIColor.clearColor();
        var backgroundFieldPlaceholder = NSAttributedString(string: "e.g. Systems Engineer", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder;
        experienceField.textColor = UIColor.blackColor();
        experienceField.borderStyle = UITextBorderStyle.None

        lookingForField.backgroundColor = UIColor.clearColor();
        var goalsFieldPlaceholder = NSAttributedString(string: "What are you looking for?", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder;
        lookingForField.textColor = UIColor.blackColor();
        lookingForField.borderStyle = UITextBorderStyle.None

        
    }
}
