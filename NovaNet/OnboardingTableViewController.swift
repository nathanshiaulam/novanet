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
    
    @IBOutlet weak var nameCheck: UIImageView!
    @IBOutlet weak var aboutCheck: UIImageView!
    @IBOutlet weak var professionCheck: UIImageView!
    @IBOutlet weak var interestCheck: UIImageView!
    @IBOutlet weak var seekingCheck: UIImageView!
    
    
    @IBOutlet weak var continueButton: UIButton!
    
    /* TEXTFIELDS */
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var experienceField: UITextField!
    @IBOutlet weak var lookingForField: UITextField!
    @IBOutlet weak var aboutField: UITextView!
    var activeField:UITextField = UITextField();
    
    @IBOutlet weak var interestFieldOne: UITextField!
    @IBOutlet weak var interestFieldTwo: UITextField!
    @IBOutlet weak var interestFieldThree: UITextField!

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
    
    private let firstInterestPlaceholder = "Nova"
    private let secondInterestPlaceholder = "Reading"
    private let thirdInterestPlaceholder = "Sports"
    
    private let seekingPlaceholder = "Novas."
    
    @IBAction func skipTutorial(sender: UIButton) {
        if (nameField.text?.characters.count > 0 && experienceField.text?.characters.count > 0) {
            
            if interestFieldOne.text?.characters.count == 0 {
                interestFieldOne.text = firstInterestPlaceholder
            }
            if interestFieldTwo.text?.characters.count == 0 {
                interestFieldTwo.text = secondInterestPlaceholder
            }
            if interestFieldThree.text?.characters.count == 0 {
                interestFieldThree.text = thirdInterestPlaceholder
            }
            if lookingForField.text?.characters.count == 0 {
                lookingForField.text = seekingPlaceholder
            }
            
            
            saveTempImage()
            prepareDataStore()
            saveProfile()
            
            NSNotificationCenter.defaultCenter().postNotificationName("selectProfileVC", object: nil)
            NetworkManager().onboardingComplete()
            
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)

        } else {
            let alert = UIAlertController(title: "Empty Field", message: "In order to skip, please tell us your name and profession.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    // Prepares local datastore for profile information and saves profile;
    @IBAction func continueButtonPressed(sender: UIButton) {
        if (nameField.text?.characters.count > 0 && experienceField.text?.characters.count > 0 && lookingForField.text!.characters.count > 0 && aboutField.text.characters.count > 0
            && (interestFieldOne.text!.characters.count > 0 && interestFieldTwo.text!.characters.count > 0
            && interestFieldThree.text!.characters.count > 0)) {
            
            // Capitalize first letter of string
            capitalizeTextFieldLetter(nameField)
            capitalizeTextFieldLetter(experienceField)
            capitalizeTextFieldLetter(lookingForField)
            capitalizeTextFieldLetter(interestFieldOne)
            capitalizeTextFieldLetter(interestFieldTwo)
            capitalizeTextFieldLetter(interestFieldThree)
            capitalizeTextViewLetter(aboutField)

            prepareDataStore()
            saveProfile()
        } else {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter all essential fields.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    
    private func saveTempImage() {
        let tempImage = UIImageView(image: UIImage(named: "selectImage"))
        Utilities().saveImage(tempImage.image!)
    }
    
    // Takes user back to homeview after coming from uploadProfilePictureVC
    func backToHomeView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    private func capitalizeTextFieldLetter(textField: UITextField) {
        textField.text!.replaceRange(textField.text!.startIndex...textField.text!.startIndex, with: String(textField.text![textField.text!.startIndex]).capitalizedString)
    }
    private func capitalizeTextViewLetter(textView: UITextView) {
        textView.text!.replaceRange(textView.text!.startIndex...textView.text!.startIndex, with: String(textView.text![textView.text!.startIndex]).capitalizedString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "1 of 2";
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OnboardingTableViewController.backToHomeView), name: "backToHomeView", object: nil);
        
        continueButton.layer.cornerRadius = 5
        nameCheck.hidden = true
        professionCheck.hidden = true
        aboutCheck.hidden = true
        interestCheck.hidden = true
        seekingCheck.hidden = true
        self.tableView.tableHeaderView = nil
        tableView.allowsSelection = false
        manageiOSModelType()
        prepareTextFields()
        self.tableView.reloadData()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
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
            aboutCheck.hidden = true
        } else {
            aboutCheck.hidden = false
        }
    }
    func textViewShouldReturn(textView: UITextView!) -> Bool {
        self.view.endEditing(true)
        interestFieldOne.becomeFirstResponder()
        return true;
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
            experienceField.becomeFirstResponder();
        }
        else if (textField == experienceField) {
            textField.resignFirstResponder()
            aboutField.becomeFirstResponder();
        }
        if (textField == interestFieldOne) {
            textField.resignFirstResponder()
            interestFieldTwo.becomeFirstResponder()
        } else if (textField == interestFieldTwo) {
            textField.resignFirstResponder()
            interestFieldThree.becomeFirstResponder()
        } else if (textField == interestFieldThree) {
            textField.resignFirstResponder()
            lookingForField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false;
    }
    
    // checks active field
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField;

    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text!.characters.count == 0 {
            setChecks(textField, hidden: true)
        } else {
            setChecks(textField, hidden: false)
        }
    }
    
    private func setChecks(textField: UITextField, hidden: Bool) {
        if textField == nameField {
            nameCheck.hidden = hidden
        } else if textField == experienceField {
            professionCheck.hidden = hidden
        } else if (textField == interestFieldOne ||
            textField == interestFieldTwo ||
            textField == interestFieldThree)
        {
            interestCheck.hidden = hidden
        } else if textField == lookingForField {
            seekingCheck.hidden = hidden
        }
    }
    
    // Sets the character limit of each text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == nameField) {
            return textField.text?.characters.count <= 29
        } else if (textField == experienceField) {
            return textField.text?.characters.count <= 30
        } else if (textField == interestFieldOne ||
            textField == interestFieldTwo ||
            textField == interestFieldThree) {
            return textField.text?.characters.count <= 9
        } else {
            return textField.text?.characters.count <= 80
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
        let interestsArr:[String] = [interestFieldOne.text!, interestFieldTwo.text!, interestFieldThree.text!]

        let profileFields:Dictionary<String, AnyObject> = [
            "Name" : nameField.text! as AnyObject,
            "About" : aboutField.text! as AnyObject,
            "InterestsList" : interestsArr as AnyObject,
            "Experience" : experienceField.text! as AnyObject,
            "Looking" : lookingForField.text! as AnyObject,
            "Distance" : Constants.DISCOVERY_RADIUS as AnyObject,
            "Available" : true as AnyObject,
            "Online" : true as AnyObject
        ];
        
        let dataStoreFields:Dictionary<String, Any> = [
            Constants.UserKeys.nameKey : nameField.text,
            Constants.UserKeys.aboutKey : aboutField.text,
            Constants.UserKeys.interestsKey : interestsArr,
            Constants.UserKeys.experienceKey : experienceField.text,
            Constants.UserKeys.lookingForKey : lookingForField.text,
            Constants.UserKeys.distanceKey : Constants.DISCOVERY_RADIUS,
            Constants.UserKeys.availableKey : true
        ];
        
        NetworkManager().updateObjectWithName("Profile", profileFields: profileFields, dataStoreFields: dataStoreFields, segueType: "NONE", sender: self);
        
    }
    
    // Sets up the user's local datastore for profile information. Online is already set at create
    func prepareDataStore() {
        let interestsArr = [interestFieldOne.text!, interestFieldTwo.text!, interestFieldThree.text!]
        defaults.setObject(nameField.text, forKey: Constants.UserKeys.nameKey);
        defaults.setObject(aboutField.text, forKey: Constants.UserKeys.aboutKey);
        defaults.setObject(experienceField.text, forKey: Constants.UserKeys.experienceKey);
        defaults.setObject(interestsArr, forKey: Constants.UserKeys.interestsKey);
        defaults.setObject(lookingForField.text, forKey: Constants.UserKeys.lookingForKey);
        defaults.setBool(true, forKey: Constants.UserKeys.availableKey);
        defaults.setBool(false, forKey: Constants.TempKeys.fromNew);
    }
    
    func prepareTextFields() {
        
        nameField.backgroundColor = UIColor.clearColor();
        let nameFieldPlaceholder = NSAttributedString(string: "What's your name?", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.blackColor();
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.font = UIFont(name: "OpenSans", size: 16);
        
        aboutField.backgroundColor = UIColor.clearColor();
        aboutField.text = Constants.ConstantStrings.aboutText;
        aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0);
        aboutField.font = UIFont(name: "OpenSans", size: 16);
        
        interestFieldOne.backgroundColor = UIColor.clearColor();
        let interestsFieldOnePlaceholder = NSAttributedString(string: firstInterestPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestFieldOne.attributedPlaceholder = interestsFieldOnePlaceholder;
        interestFieldOne.textColor = UIColor.blackColor();
        interestFieldOne.borderStyle = UITextBorderStyle.None
        interestFieldOne.font = UIFont(name: "OpenSans", size: 16);
        
        let dotOneImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotOneImage.frame = CGRect(x: 0, y: 0, width: dotOneImage.frame.width + 15, height: dotOneImage.frame.height)
        dotOneImage.contentMode = UIViewContentMode.Center
        interestFieldOne.leftView = dotOneImage
        interestFieldOne.leftViewMode = UITextFieldViewMode.Always
        
        interestFieldTwo.backgroundColor = UIColor.clearColor();
        let interestsFieldTwoPlaceholder = NSAttributedString(string: secondInterestPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestFieldTwo.attributedPlaceholder = interestsFieldTwoPlaceholder;
        interestFieldTwo.textColor = UIColor.blackColor();
        interestFieldTwo.borderStyle = UITextBorderStyle.None
        interestFieldTwo.font = UIFont(name: "OpenSans", size: 16);
        
        let dotTwoImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotTwoImage.frame = CGRect(x: 0, y: 0, width: dotTwoImage.frame.width + 15, height: dotTwoImage.frame.height)
        dotTwoImage.contentMode = UIViewContentMode.Center
        interestFieldTwo.leftView = dotTwoImage
        interestFieldTwo.leftViewMode = UITextFieldViewMode.Always
        
        interestFieldThree.backgroundColor = UIColor.clearColor();
        let interestsFieldThreePlaceholder = NSAttributedString(string: thirdInterestPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestFieldThree.attributedPlaceholder = interestsFieldThreePlaceholder;
        interestFieldThree.textColor = UIColor.blackColor();
        interestFieldThree.borderStyle = UITextBorderStyle.None
        interestFieldThree.font = UIFont(name: "OpenSans", size: 16)
        
        let dotThreeImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThreeImage.frame = CGRect(x: 0, y: 0, width: dotThreeImage.frame.width + 15, height: dotThreeImage.frame.height)
        dotThreeImage.contentMode = UIViewContentMode.Center
        interestFieldThree.leftView = dotThreeImage
        interestFieldThree.leftViewMode = UITextFieldViewMode.Always
        
        experienceField.backgroundColor = UIColor.clearColor();
        let backgroundFieldPlaceholder = NSAttributedString(string: "e.g. systems engineer", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder;
        experienceField.textColor = UIColor.blackColor();
        experienceField.borderStyle = UITextBorderStyle.None
        experienceField.font = UIFont(name: "OpenSans", size: 16);
        
        lookingForField.backgroundColor = UIColor.clearColor();
        let goalsFieldPlaceholder = NSAttributedString(string: seekingPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder;
        lookingForField.textColor = UIColor.blackColor();
        lookingForField.borderStyle = UITextBorderStyle.None
        lookingForField.font = UIFont(name: "OpenSans", size: 16);
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
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
