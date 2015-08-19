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


class OnboardingViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    var distFromTop:CGFloat!;
    var bot:CGFloat!;
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lookingForField: UITextField!
    @IBOutlet weak var experienceField: UITextField!
    
    @IBOutlet weak var overallHeaderLabel: UILabel!
    @IBOutlet weak var firstInterestField: UITextField!
    @IBOutlet weak var secondInterestField: UITextField!
    @IBOutlet weak var thirdInterestField: UITextField!

    @IBOutlet weak var aboutField: UITextView!
    
    @IBOutlet weak var continueDistFromBot: NSLayoutConstraint!
    @IBOutlet weak var continueHeight: NSLayoutConstraint!
    var activeField:UITextField = UITextField();
    
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    @IBOutlet weak var aboutHeaderLabel: UILabel!
    @IBOutlet weak var nameHeaderLabel: UILabel!
    /*-------------------------------- CONSTRAINTS ------------------------------------*/
    
    
    @IBOutlet weak var distFromNameToTop: NSLayoutConstraint!
    @IBOutlet weak var distanceFromAboutToTextView: NSLayoutConstraint!
    @IBOutlet weak var distanceFromAboutToName: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
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
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "2 of 4";
        
        self.automaticallyAdjustsScrollViewInsets = false;
        distFromTop = self.distFromNameToTop.constant - 15;
        bot = self.continueDistFromBot.constant - 35;
        //Looks for single or multiple taps to remove keyboard
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        registerForKeyBoardNotifications()
        prepareTextFields();
    }
    
    override func viewDidLayoutSubviews() {
        manageiOSModelType();

    }
    
    /*-------------------------------- TextViewDel Methods ------------------------------------*/

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColorFromHex(0xA6AAA9, alpha: 1.0) {
            println("true");
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "A sentence or two illustrating what you're about. Who are you in a nutshell?";
            textView.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var maxtext = 80
        //If the text is larger than the maxtext, the return is false
        return count(textView.text) + (count(text) - range.length) <= maxtext
        
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
    
    // checks active field
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField;
    }
    func textFieldDidEndEditing(textField: UITextField) {
    }
    // Sets the character limit of each text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > count(textField.text) )
        {
            return false;
        }
        
        let newLength = count(textField.text) + count(string) - range.length
        if (textField == nameField) {
            return newLength <= 25
        } else {
            return newLength <= 25
        }
    }

    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Converts to RGB from Hex
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            self.textViewHeight.constant = 90
            self.continueHeight.constant = 45
            self.distFromNameToTop.constant = distFromTop
            self.continueDistFromBot.constant = bot
            // Header Labels
            self.professionHeaderLabel.font = self.professionHeaderLabel.font.fontWithSize(16.0);
            self.interestsHeaderLabel.font = self.interestsHeaderLabel.font.fontWithSize(16.0);
            self.aboutHeaderLabel.font = self.aboutHeaderLabel.font.fontWithSize(16.0);
            self.nameHeaderLabel.font = self.nameHeaderLabel.font.fontWithSize(16.0);
            self.seekingHeaderLabel.font = self.seekingHeaderLabel.font.fontWithSize(16.0);
            self.overallHeaderLabel.font = self.overallHeaderLabel.font.fontWithSize(18.0)
            
            // Text Fields
            nameField.font = UIFont(name: "Avenir", size: 15);
            aboutField.font = UIFont(name: "Avenir", size: 15);
            firstInterestField.font = UIFont(name: "Avenir", size: 15);
            secondInterestField.font = UIFont(name: "Avenir", size: 15);
            thirdInterestField.font = UIFont(name: "Avenir", size: 15);
            experienceField.font = UIFont(name: "Avenir", size: 15);
            lookingForField.font = UIFont(name: "Avenir", size: 15);
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            self.textViewHeight.constant = 120
            
            // Header Labels
            self.professionHeaderLabel.font = self.professionHeaderLabel.font.fontWithSize(16.0);
            self.interestsHeaderLabel.font = self.interestsHeaderLabel.font.fontWithSize(16.0);
            self.aboutHeaderLabel.font = self.aboutHeaderLabel.font.fontWithSize(16.0);
            self.nameHeaderLabel.font = self.nameHeaderLabel.font.fontWithSize(16.0);
            self.seekingHeaderLabel.font = self.seekingHeaderLabel.font.fontWithSize(16.0);
            self.overallHeaderLabel.font = self.overallHeaderLabel.font.fontWithSize(18.0)
            self.continueDistFromBot.constant = bot
            
            // Text Fields
            nameField.font = UIFont(name: "Avenir", size: 15);
            aboutField.font = UIFont(name: "Avenir", size: 15);
            firstInterestField.font = UIFont(name: "Avenir", size: 15);
            secondInterestField.font = UIFont(name: "Avenir", size: 15);
            thirdInterestField.font = UIFont(name: "Avenir", size: 15);
            experienceField.font = UIFont(name: "Avenir", size: 15);
            lookingForField.font = UIFont(name: "Avenir", size: 15);
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            
            self.textViewHeight.constant = 150
            
            self.professionHeaderLabel.font = self.professionHeaderLabel.font.fontWithSize(22.0);
            self.interestsHeaderLabel.font = self.interestsHeaderLabel.font.fontWithSize(22.0);
            self.aboutHeaderLabel.font = self.aboutHeaderLabel.font.fontWithSize(22.0);
            self.nameHeaderLabel.font = self.nameHeaderLabel.font.fontWithSize(22.0);
            self.seekingHeaderLabel.font = self.seekingHeaderLabel.font.fontWithSize(22.0);
            self.overallHeaderLabel.font = self.overallHeaderLabel.font.fontWithSize(22.0);
            
            nameField.font = UIFont(name: "Avenir", size: 17);
            aboutField.font = UIFont(name: "Avenir", size: 17);
            firstInterestField.font = UIFont(name: "Avenir", size: 17);
            secondInterestField.font = UIFont(name: "Avenir", size: 17);
            thirdInterestField.font = UIFont(name: "Avenir", size: 17);
            experienceField.font = UIFont(name: "Avenir", size: 17);
            lookingForField.font = UIFont(name: "Avenir", size: 17);
            return;
        }
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
    
    // Ensures that you can scroll when keyboard up
    func registerForKeyBoardNotifications() {
        println("thisHappened");
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWasShown:", name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil);
        
    }
    func keyBoardWasShown(notification: NSNotification) {
        println("happened");
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scrollView.contentInset = contentInsets;
            self.scrollView.scrollIndicatorInsets = contentInsets;
            
            var aRect = self.view.frame;
            aRect.size.height -= keyboardSize.height;
            if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
                var scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-keyboardSize.height);
                self.scrollView.setContentOffset(scrollPoint, animated: true);
            }
        }
    }
    func keyboardWillBeHidden(aNotification: NSNotification) {
        var contentInsets = UIEdgeInsetsZero;
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func prepareTextFields() {
        nameField.backgroundColor = UIColor.clearColor();
        var nameFieldPlaceholder = NSAttributedString(string: "What's your name?", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.blackColor();
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.font = UIFont(name: "Avenir", size: 16);
        
        aboutField.backgroundColor = UIColor.clearColor();
        aboutField.text = Constants.ConstantStrings.aboutText;
        aboutField.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0);
        aboutField.font = UIFont(name: "Avenir", size: 16);
        
        
        firstInterestField.backgroundColor = UIColor.clearColor();
        var firstInterestsFieldPlaceholder = NSAttributedString(string: "Interest 1", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        firstInterestField.attributedPlaceholder = firstInterestsFieldPlaceholder;
        firstInterestField.textColor = UIColor.blackColor();
        firstInterestField.borderStyle = UITextBorderStyle.None
        firstInterestField.font = UIFont(name: "Avenir", size: 16);
        
        
        secondInterestField.backgroundColor = UIColor.clearColor();
        var secondInterestFieldPlaceholder = NSAttributedString(string: "Interest 2", attributes: [NSForegroundColorAttributeName :UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        secondInterestField.attributedPlaceholder = secondInterestFieldPlaceholder;
        secondInterestField.textColor = UIColor.blackColor();
        secondInterestField.borderStyle = UITextBorderStyle.None
        secondInterestField.font = UIFont(name: "Avenir", size: 16);
        
        
        thirdInterestField.backgroundColor = UIColor.clearColor();
        var thirdInterestFieldPlaceholder = NSAttributedString(string: "Interest 3", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        thirdInterestField.attributedPlaceholder = thirdInterestFieldPlaceholder;
        thirdInterestField.textColor = UIColor.blackColor();
        thirdInterestField.borderStyle = UITextBorderStyle.None
        thirdInterestField.font = UIFont(name: "Avenir", size: 16);
        
        
        experienceField.backgroundColor = UIColor.clearColor();
        var backgroundFieldPlaceholder = NSAttributedString(string: "e.g. Systems Engineer", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder;
        experienceField.textColor = UIColor.blackColor();
        experienceField.borderStyle = UITextBorderStyle.None
        experienceField.font = UIFont(name: "Avenir", size: 16);
        
        
        lookingForField.backgroundColor = UIColor.clearColor();
        var goalsFieldPlaceholder = NSAttributedString(string: "What are you looking for?", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder;
        lookingForField.textColor = UIColor.blackColor();
        lookingForField.borderStyle = UITextBorderStyle.None
        lookingForField.font = UIFont(name: "Avenir", size: 16);
    }


}
