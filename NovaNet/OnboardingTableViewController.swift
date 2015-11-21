//
//  OnboardingTableViewController.swift
//  
//
//  Created by Nathan Lam on 10/11/15.
//
//

import UIKit
import Bolts
import Parse

class OnboardingTableViewController: TableViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    /* TEXTFIELDS */
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var experienceField: UITextField!
    @IBOutlet weak var interestsField: UITextField!
    @IBOutlet weak var lookingForField: UITextField!
    @IBOutlet weak var aboutField: UITextView!
    var activeField:UITextField = UITextField();

    /* LABELS */
    @IBOutlet weak var overallHeaderLabel: UILabel!
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    @IBOutlet weak var aboutHeaderLabel: UILabel!
    @IBOutlet weak var nameHeaderLabel: UILabel!
    
    /* CONSTRAINTS */
    
    @IBOutlet weak var nameFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var aboutFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var seekingFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var interestsFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var professionFieldWidth: NSLayoutConstraint!
    
    // Prepares local datastore for profile information and saves profile;
    @IBAction func continueButtonPressed(sender: UIButton) {
        if (nameField.text?.characters.count > 0 && experienceField.text?.characters.count > 0 && lookingForField.text!.characters.count > 0 && interestsField.text!.characters.count > 0 && aboutField.text.characters.count > 0) {
            
            // Capitalize first letter of string
            nameField.text!.replaceRange(nameField.text!.startIndex...nameField.text!.startIndex, with: String(nameField.text![nameField.text!.startIndex]).capitalizedString)
            
//            prepareDataStore();
            saveProfile();
        } else {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter all essential fields.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "2 of 4";
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        // Detect when the interest field is changed
        interestsField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        tableView.allowsSelection = false;
        manageiOSModelType();
        prepareTextFields();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
    }
    
    /* TEXTVIEW DELEGATE METHODS*/
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.ConstantStrings.placeHolderAbout;
            textView.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxtext = 80
        //If the text is larger than the maxtext, the return is false
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
        
    }
    
    /* TEXTFIELD DELEGATE METHODS*/
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(textField: UITextField)-> Bool {
        if (textField == nameField) {
            aboutField.becomeFirstResponder();
        }
        else if (textField == experienceField) {
            textField.resignFirstResponder()
            interestsField.becomeFirstResponder();
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
    
//    func textFieldDidEndEditing(textField: UITextField) {
//
//    }
    // Sets the character limit of each text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false;
        }
        
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        if (textField == interestsField) {
            let numEntries = interestsField.text!.characters.split {$0 == ","}
            return numEntries.count <= 3 && newLength <= 40; // Ensures that there are only three interest field entries
        } else {
            return newLength <= 40;
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        Utilities().commaLimiter(textField);
    }
    
    // Removes keyboard when tap out of screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
    }

    /* HELPER METHODS */
    
    // Manages iOS sizes
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480 || Constants.ScreenDimensions.screenHeight == 568) {
            overallHeaderLabel.font = overallHeaderLabel.font.fontWithSize(19.0);
            nameHeaderLabel.font = nameHeaderLabel.font.fontWithSize(19.0);
            aboutHeaderLabel.font = aboutHeaderLabel.font.fontWithSize(19.0);
            professionHeaderLabel.font = professionHeaderLabel.font.fontWithSize(19.0);
            interestsHeaderLabel.font = interestsHeaderLabel.font.fontWithSize(19.0);
            seekingHeaderLabel.font = seekingHeaderLabel.font.fontWithSize(19.0);
            
            nameFieldWidth.constant = 190;
            aboutFieldWidth.constant = 195;
            seekingFieldWidth.constant = 190;
            interestsFieldWidth.constant = 190;
            professionFieldWidth.constant = 190;
            buttonHeight.constant = 45;
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            nameFieldWidth.constant = 250;
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            overallHeaderLabel.font = overallHeaderLabel.font.fontWithSize(24.0);
            nameFieldWidth.constant = 250;
            return;
        }
    }
    
    // Saves all necessary fields of the profile
    func saveProfile() {
        var interestsArr = interestsField.text!.componentsSeparatedByString(",")
        for (var i = 0; i < interestsArr.count; i++) {
            interestsArr[i] = interestsArr[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        let profileFields:Dictionary<String, AnyObject> = [
            "Name" : nameField.text! as AnyObject,
            "About" : aboutField.text! as AnyObject,
            "InterestsList" : interestsArr as AnyObject,
            "Experience" : experienceField.text! as AnyObject,
            "Looking" : lookingForField.text! as AnyObject,
            "Distance" : 25 as AnyObject,
            "Available" : true as AnyObject,
            "Online" : true as AnyObject
        ];
        
        let dataStoreFields:Dictionary<String, Any> = [
            Constants.UserKeys.nameKey : nameField.text,
            Constants.UserKeys.aboutKey : aboutField.text,
            Constants.UserKeys.interestsKey : interestsArr,
            Constants.UserKeys.experienceKey : experienceField.text,
            Constants.UserKeys.lookingForKey : lookingForField.text,
            Constants.UserKeys.distanceKey : 25,
            Constants.UserKeys.availableKey : true
        ];
        
        NetworkManager().updateObjectWithName("Profile", profileFields: profileFields, dataStoreFields: dataStoreFields, segueType: "NONE", sender: self);
        
        
//        let query = PFQuery(className:"Profile");
//        let currentID = PFUser.currentUser()!.objectId;
//        query.whereKey("ID", equalTo:currentID!);
//
//        query.getFirstObjectInBackgroundWithBlock {
//            (profile: PFObject?, error: NSError?) -> Void in
//            if (error != nil || profile == nil) {
//                print(error);
//            } else if let profile = profile {
//                profile["Name"] = self.nameField.text;
//                profile["About"] = self.aboutField.text;
//                profile["InterestsList"] = interestsArr;
//                profile["Experience"] = self.experienceField.text;
//                profile["Looking"] = self.lookingForField.text;
//                profile["Distance"] = 25;
//                profile["Available"] = true;
//                profile["Online"] = true;
//                profile.saveInBackground();
//
//            }
//        }
        
    }
    
    // Sets up the user's local datastore for profile information. Online is already set at create
//    func prepareDataStore() {
//        let interestsArr = interestsField.text!.componentsSeparatedByString(",")
//        defaults.setObject(nameField.text, forKey: Constants.UserKeys.nameKey);
//        defaults.setObject(aboutField.text, forKey: Constants.UserKeys.aboutKey);
//        defaults.setObject(experienceField.text, forKey: Constants.UserKeys.experienceKey);
//        defaults.setObject(interestsArr, forKey: Constants.UserKeys.interestsKey);
//        defaults.setObject(lookingForField.text, forKey: Constants.UserKeys.lookingForKey);
//        defaults.setBool(true, forKey: Constants.UserKeys.availableKey);
//    }
    
    func prepareTextFields() {
        nameField.backgroundColor = UIColor.clearColor();
        let nameFieldPlaceholder = NSAttributedString(string: "What's your name?", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.blackColor();
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.font = UIFont(name: "Avenir", size: 16);
        
        aboutField.backgroundColor = UIColor.clearColor();
        aboutField.text = Constants.ConstantStrings.aboutText;
        aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0);
        aboutField.font = UIFont(name: "Avenir", size: 16);
        
        interestsField.backgroundColor = UIColor.clearColor();
        let interestsFieldPlaceholder = NSAttributedString(string: "CS, Travel, Entrepreneurship", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestsField.attributedPlaceholder = interestsFieldPlaceholder;
        interestsField.textColor = UIColor.blackColor();
        interestsField.borderStyle = UITextBorderStyle.None
        interestsField.font = UIFont(name: "Avenir", size: 16);
        
        experienceField.backgroundColor = UIColor.clearColor();
        let backgroundFieldPlaceholder = NSAttributedString(string: "e.g. Systems Engineer", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder;
        experienceField.textColor = UIColor.blackColor();
        experienceField.borderStyle = UITextBorderStyle.None
        experienceField.font = UIFont(name: "Avenir", size: 16);
        
        
        lookingForField.backgroundColor = UIColor.clearColor();
        let goalsFieldPlaceholder = NSAttributedString(string: "What are you looking for?", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder;
        lookingForField.textColor = UIColor.blackColor();
        lookingForField.borderStyle = UITextBorderStyle.None
        lookingForField.font = UIFont(name: "Avenir", size: 16);
    }

    
    
    /* TABLEVIEW DELEGATE METHODS */
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 7
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
