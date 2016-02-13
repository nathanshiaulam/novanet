//
//  SettingsMenuTableVC.swift
//  
//
//  Created by Nathan Lam on 10/15/15.
//
//

import UIKit
import Parse
import Bolts

class SettingsMenuTableVC: TableViewController, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UINavigationControllerDelegate, UITextViewDelegate  {
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    @IBOutlet weak var profileImage: UIImageView!

    /* TEXTFIELDS */
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var experienceField: UITextField!
    @IBOutlet weak var interestsField: UITextField!
    @IBOutlet weak var lookingForField: UITextField!
    @IBOutlet weak var aboutField: UITextView!
    var activeField:UITextField = UITextField();
    
    /* LABELS */
    @IBOutlet weak var photoHeaderLabel: UILabel!
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    @IBOutlet weak var aboutHeaderLabel: UILabel!
    @IBOutlet weak var nameHeaderLabel: UILabel!
    
    /* CONSTRAINTS */
    @IBOutlet weak var nameFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var aboutFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var seekingFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var interestsFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var professionFieldWidth: NSLayoutConstraint!
    
    /* IMAGE PICKER */
    let picker = UIImagePickerController();
    var popover:UIPopoverController? = nil;
    
//    @IBAction func saveInfo(sender: UIBarButtonItem) {
//        saveProfile();
//    }
    
    /* NIB LIFE CYCLE METHODS */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Removes gray lines
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;

        // Allows user to upload photo
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedImage");
        interestsField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        tapGestureRecognizer.delegate = self;
        self.profileImage.addGestureRecognizer(tapGestureRecognizer);
        self.profileImage.userInteractionEnabled = true;
        
        tableView.allowsSelection = false;
        
        manageiOSModelType();
        picker.delegate = self;
        
        prepareTextFields();
    }
    
    override func viewDidLayoutSubviews() {
        Utilities().formatImage(self.profileImage);
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveProfile();
        super.viewWillDisappear(true);
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
            textView.text = "A sentence or two illustrating what you're about. Who are you in a nutshell?";
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
    
    // Manages iOS sizes
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480 || Constants.ScreenDimensions.screenHeight == 568) {
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
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            
            return;
        }
    }

    // Sets the character limit of each text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false;
        }
        
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        if (textField == interestsField) {
            var numEntries = interestsField.text!.characters.split {$0 == ","}
            if numEntries.count > 3 {
                var fieldInfo = textField.text
                fieldInfo = fieldInfo?.substringWithRange(Range<String.Index>(start: fieldInfo!.startIndex, end: fieldInfo!.endIndex.advancedBy(-2)))
                interestsField.text = fieldInfo
            }
            numEntries = interestsField.text!.characters.split {$0 == ","}
            
            return numEntries.count <= 3 && newLength <= 40; // Ensures that there are only three interest field entries
        } else if (textField == lookingForField) {
            return newLength <= 30
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
    
    /* IMAGE PICKER METHODS */
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;

        Utilities().saveImage(profileImage.image!);
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        print("Picker cancel.");
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        profileImage.image = image
        self.dismissViewControllerAnimated(true, completion: { () -> Void in})
        
        let query = PFQuery(className:"Profile");
        let currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        Utilities().saveImage(profileImage.image!);
        let pickedImage:UIImage = self.profileImage.image!;
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5);
        let imageFile:PFFile = PFFile(data: imageData!)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                print(error);
            } else if let profile = profile {
                profile["Image"] = imageFile;
                profile.saveInBackground();
            }
        }
        
    }
    
    /* CAMERA METHODS */
    
    func tappedImage() {
        let alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet);
        
        let galleryAction = UIAlertAction(title: "Upload a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallery()
        }
        let cameraAction = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
        }
        // Add the actions
        alert.addAction(galleryAction);
        alert.addAction(cameraAction);
        alert.addAction(cancelAction);
        
        // Present the actionsheet
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func openGallery() {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: picker);
            popover?.presentPopoverFromRect(profileImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }

    /* HELPER METHODS */

    // Saves all necessary fields of the profile
    func saveProfile() {
        
        var oldInterestsArr = interestsField.text!.componentsSeparatedByString(",")
        var interestsArr:[String] = [String]()
        var numInterests = 0
        if oldInterestsArr.count > Constants.MAX_NUM_INTERESTS {
            numInterests = Constants.MAX_NUM_INTERESTS
        } else  {
            numInterests = oldInterestsArr.count
        }
        for (var i = 0; i < numInterests; i++) {
            let interest = oldInterestsArr[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if interest.characters.count > 0 {
                interestsArr.append(interest)
            }
        }
        
        defaults.setObject(nameField.text, forKey: Constants.UserKeys.nameKey)
        defaults.setObject(interestsArr, forKey: Constants.UserKeys.interestsKey)
        defaults.setObject(experienceField.text, forKey: Constants.UserKeys.experienceKey)
        defaults.setObject(lookingForField.text, forKey: Constants.UserKeys.lookingForKey)
        defaults.setObject(aboutField.text, forKey: Constants.UserKeys.aboutKey)
        
        let profileFields:Dictionary<String, AnyObject> = [
            "Name" : nameField.text! as AnyObject,
            "InterestsList" : interestsArr as AnyObject,
            "Experience" : experienceField.text! as AnyObject,
            "Looking" : lookingForField.text! as AnyObject,
            "About" : aboutField.text! as AnyObject
        ];
        
        let dataStoreFields:Dictionary<String, Any> = [
            Constants.UserKeys.nameKey : nameField.text! as AnyObject,
            Constants.UserKeys.interestsKey : interestsArr,
            Constants.UserKeys.experienceKey : experienceField.text! as AnyObject,
            Constants.UserKeys.lookingForKey : lookingForField.text! as AnyObject,
            Constants.UserKeys.aboutKey : aboutField.text
        ];
        
        NetworkManager().updateObjectWithName("Profile", profileFields: profileFields, dataStoreFields: dataStoreFields, segueType: "POP", sender: self);
        
    }
    
    // Prepares all text fields
    func prepareTextFields() {
        nameField.backgroundColor = UIColor.clearColor();
        let nameFieldPlaceholder = NSAttributedString(string: "What's your name?", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.blackColor();
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.font = UIFont(name: "Avenir", size: 16);
        
        aboutField.backgroundColor = UIColor.clearColor();
        aboutField.font = UIFont(name: "Avenir", size: 16);
        
        interestsField.backgroundColor = UIColor.clearColor();
        let interestsFieldPlaceholder = NSAttributedString(string: "Interest 1", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
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
        
        // Set texts if exists
        if let name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameField.text = name;
        }
        // Set About Field View Text
        if let about = defaults.stringForKey(Constants.UserKeys.aboutKey) {
            aboutField.text = about;
            if (about == Constants.ConstantStrings.aboutText) {
                aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0);
            }
        } else {
            aboutField.text = "A sentence or two illustrating what you're about. Who are you in a nutshell?";
            aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0);
        }
        
        if let interests = defaults.arrayForKey(Constants.UserKeys.interestsKey) {
            var interestsArr = interests;
            for (var i = 0; i < interestsArr.count; i++) {
                if (i < interestsArr.count - 1) {
                    interestsField.text = interestsField.text! + (interestsArr[i] as! String) + ", ";
                } else {
                    interestsField.text = interestsField.text! + (interestsArr[i] as! String);
                }
            }

        }
        if let experience = defaults.stringForKey(Constants.UserKeys.experienceKey) {
            experienceField.text = experience;
        }
        if let looking = defaults.stringForKey(Constants.UserKeys.lookingForKey) {
            lookingForField.text = looking;
        }
        self.profileImage.image = Utilities().readImage();
    }

    
    
}
