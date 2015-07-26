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


class OnboardingViewController: UIViewController {
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var goalsField: UITextField!
    @IBOutlet weak var interestsField: UITextField!
    @IBOutlet weak var backgroundField: UITextField!
    
    @IBAction func continueButtonPressed(sender: UIButton) {
         if (count(nameField.text) > 0 && count(backgroundField.text) > 0 && count(goalsField.text) > 0 && count(interestsField.text) > 0) {
            defaults.setObject(nameField.text, forKey: Constants.UserKeys.nameKey);
            defaults.setObject(backgroundField.text, forKey: Constants.UserKeys.backgroundKey);
            defaults.setObject(interestsField.text, forKey: Constants.UserKeys.interestsKey);
            defaults.setObject(goalsField.text, forKey: Constants.UserKeys.goalsKey);
            defaults.setBool(true, forKey: Constants.UserKeys.availableKey);
            var newProfile = PFObject(className: "Profile");
            newProfile["ID"] = PFUser.currentUser()!.objectId;
            newProfile["Name"] = nameField.text;
            newProfile["Interests"] = interestsField.text;
            newProfile["Background"] = backgroundField.text;
            newProfile["Goals"] = goalsField.text;
            newProfile["Distance"] = 5;
            newProfile["Available"] = true;
            newProfile.saveInBackground();
        } else {
            var alert = UIAlertController(title: "Empty Field", message: "Please enter all essential fields.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    
    override func viewDidLayoutSubviews() {
        let border = CALayer();
        let width = CGFloat(2.0);
        border.borderColor = UIColor.darkGrayColor().CGColor;
        border.frame = CGRect(x: 0, y: nameField.frame.size.height - width, width:  nameField.frame.size.width, height: nameField.frame.size.height);
        
        border.borderWidth = width
        
        let borderName = CALayer();
        let widthName = CGFloat(2.0);
        borderName.borderColor = UIColor.darkGrayColor().CGColor;
        borderName.frame = CGRect(x: 0, y: nameField.frame.size.height - width, width:  nameField.frame.size.width, height: nameField.frame.size.height);
        
        borderName.borderWidth = widthName
        
        let borderInterests = CALayer();
        let widthInterests = CGFloat(2.0);
        borderInterests.borderColor = UIColor.darkGrayColor().CGColor;
        borderInterests.frame = CGRect(x: 0, y: nameField.frame.size.height - width, width:  nameField.frame.size.width, height: nameField.frame.size.height);
        
        borderInterests.borderWidth = widthInterests
        
        let borderGoals = CALayer();
        let widthGoals = CGFloat(2.0);
        borderGoals.borderColor = UIColor.darkGrayColor().CGColor;
        borderGoals.frame = CGRect(x: 0, y: nameField.frame.size.height - width, width:  nameField.frame.size.width, height: nameField.frame.size.height);
        
        borderGoals.borderWidth = widthGoals
        
        nameField.layer.addSublayer(borderName)
        nameField.layer.masksToBounds = true
        
        interestsField.layer.addSublayer(borderInterests)
        interestsField.layer.masksToBounds = true
        
        goalsField.layer.addSublayer(borderGoals)
        goalsField.layer.masksToBounds = true
        
        
        backgroundField.layer.addSublayer(border)
        backgroundField.layer.masksToBounds = true
    }
    
    func backToHomeView() {
        println("hi");
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil);
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > count(textField.text) )
        {
            return false;
        }
        
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 60
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backToHomeView", name: "backToHomeView", object: nil);
        
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.backgroundColor = UIColor.clearColor();
        var nameFieldPlaceholder = NSAttributedString(string: "name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.whiteColor();
        
        interestsField.borderStyle = UITextBorderStyle.None;
        interestsField.backgroundColor = UIColor.clearColor();
        var interestsFieldPlaceholder = NSAttributedString(string: "interests (please list three)", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        interestsField.attributedPlaceholder = interestsFieldPlaceholder;
        interestsField.textColor = UIColor.whiteColor();
        
        backgroundField.borderStyle = UITextBorderStyle.None;
        backgroundField.backgroundColor = UIColor.clearColor();
        var backgroundFieldPlaceholder = NSAttributedString(string: "a short history of you", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        backgroundField.attributedPlaceholder = backgroundFieldPlaceholder;
        backgroundField.textColor = UIColor.whiteColor();
        
        goalsField.borderStyle = UITextBorderStyle.None;
        goalsField.backgroundColor = UIColor.clearColor();
        var goalsFieldPlaceholder = NSAttributedString(string: "what are your main goals", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        goalsField.attributedPlaceholder = goalsFieldPlaceholder;
        goalsField.textColor = UIColor.whiteColor();
        
        
    }
}
