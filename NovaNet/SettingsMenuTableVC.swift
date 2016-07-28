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
    @IBOutlet weak var lookingForField: UITextField!
    @IBOutlet weak var aboutField: UITextView!
    var activeField:UITextField = UITextField();
    @IBOutlet weak var interestFieldOne: UITextField!
    @IBOutlet weak var interestFieldTwo: UITextField!
    @IBOutlet weak var interestFieldThree: UITextField!
    
    /* LABELS */
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    @IBOutlet weak var aboutHeaderLabel: UILabel!
    @IBOutlet weak var nameHeaderLabel: UILabel!

    @IBOutlet weak var updateButton: UIButton!
    /* IMAGE PICKER */
    let picker = UIImagePickerController();
    var popover:UIPopoverController? = nil;
    
    @IBAction func updateValues(sender: UIButton) {
        saveProfile()
        NSNotificationCenter.defaultCenter().postNotificationName("setValues", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private let firstInterestPlaceholder = "Nova"
    private let secondInterestPlaceholder = "Reading"
    private let thirdInterestPlaceholder = "Sports"
    private let seekingPlaceholder = "Novas."
    private let profileImageHeight = Constants.ScreenDimensions.screenHeight / 4.0 - 14.0
    
    /* NIB LIFE CYCLE METHODS */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.layer.cornerRadius = 5

        // Allows user to upload photo
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsMenuTableVC.tappedImage));
        tapGestureRecognizer.delegate = self;
        
        self.profileImage.addGestureRecognizer(tapGestureRecognizer);
        self.profileImage.userInteractionEnabled = true;
        self.profileImage.frame = CGRectMake(0, 0, profileImageHeight, profileImageHeight)
        
        Utilities.formatImageWithWidth(profileImage, width: profileImageHeight)
        
        
        tableView.allowsSelection = false;
        picker.delegate = self;
        
        prepareTextFields();
    }
    
    override func viewWillLayoutSubviews() {
        let fontDict:[CGFloat : [UILabel]] = getChangeLabelDict()
        Utilities().formatImage(profileImage)
        Utilities.manageFontSizes(fontDict)
        super.viewWillLayoutSubviews()
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
    func textViewShouldReturn(textView: UITextView!) -> Bool {
        self.view.endEditing(true)
        interestFieldOne.becomeFirstResponder()
        return true;
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
        
        let interestsArr:[String] = [interestFieldOne.text!, interestFieldTwo.text!, interestFieldThree.text!]
        
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
        nameField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        aboutField.backgroundColor = UIColor.clearColor();
        aboutField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        interestFieldOne.backgroundColor = UIColor.clearColor();
        let interestsFieldOnePlaceholder = NSAttributedString(string: firstInterestPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestFieldOne.attributedPlaceholder = interestsFieldOnePlaceholder;
        interestFieldOne.textColor = UIColor.blackColor();
        interestFieldOne.borderStyle = UITextBorderStyle.None
        interestFieldOne.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
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
        interestFieldTwo.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
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
        interestFieldThree.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        let dotThreeImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThreeImage.frame = CGRect(x: 0, y: 0, width: dotThreeImage.frame.width + 15, height: dotThreeImage.frame.height)
        dotThreeImage.contentMode = UIViewContentMode.Center
        interestFieldThree.leftView = dotThreeImage
        interestFieldThree.leftViewMode = UITextFieldViewMode.Always

        experienceField.backgroundColor = UIColor.clearColor();
        let backgroundFieldPlaceholder = NSAttributedString(string: "e.g. Systems Engineer", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder;
        experienceField.textColor = UIColor.blackColor();
        experienceField.borderStyle = UITextBorderStyle.None
        experienceField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        lookingForField.backgroundColor = UIColor.clearColor();
        let goalsFieldPlaceholder = NSAttributedString(string: "What are you looking for?", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder;
        lookingForField.textColor = UIColor.blackColor();
        lookingForField.borderStyle = UITextBorderStyle.None
        lookingForField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
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
            for i in 0..<interestsArr.count {
                if i == 0 {
                    interestFieldOne.text = interestsArr[i] as? String
                } else if i == 1 {
                    interestFieldTwo.text = interestsArr[i] as? String
                } else {
                    interestFieldThree.text = interestsArr[i] as? String
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
    
    
//    @IBOutlet weak var nameField: UITextField!
//    @IBOutlet weak var experienceField: UITextField!
//    @IBOutlet weak var lookingForField: UITextField!
//    @IBOutlet weak var aboutField: UITextView!
//    var activeField:UITextField = UITextField();
//    @IBOutlet weak var interestFieldOne: UITextField!
//    @IBOutlet weak var interestFieldTwo: UITextField!
//    @IBOutlet weak var interestFieldThree: UITextField!
    private func getChangeLabelDict() -> [CGFloat : [UILabel]]{
        var fontDict:[CGFloat : [UILabel]] = [CGFloat : [UILabel]]()
        
        var extraSmallLabels:[UILabel] = [UILabel]()
        var smallLabels:[UILabel] = [UILabel]()
        var mediumLabels:[UILabel] = [UILabel]()
        var largeLabels:[UILabel] = [UILabel]()
        
        switch Constants.ScreenDimensions.screenHeight {
        case Constants.ScreenDimensions.IPHONE_4_HEIGHT:
            extraSmallLabels.append(seekingHeaderLabel)
            extraSmallLabels.append(interestsHeaderLabel)
            extraSmallLabels.append(professionHeaderLabel)
            extraSmallLabels.append(aboutHeaderLabel)
            extraSmallLabels.append(nameHeaderLabel)
            
            smallLabels.append(updateButton.titleLabel!)
            
            nameField.font = UIFont(name: nameField.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            experienceField.font = UIFont(name: experienceField.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            lookingForField.font = UIFont(name: lookingForField.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            aboutField.font = UIFont(name: aboutField.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            activeField.font = UIFont(name: activeField.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            interestFieldOne.font = UIFont(name: interestFieldOne.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            interestFieldTwo.font = UIFont(name: interestFieldTwo.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            interestFieldThree.font = UIFont(name: interestFieldThree.font!.fontName, size: Constants.XSMALL_FONT_SIZE)
            break
        case Constants.ScreenDimensions.IPHONE_6_HEIGHT:
            mediumLabels.append(seekingHeaderLabel)
            mediumLabels.append(interestsHeaderLabel)
            mediumLabels.append(professionHeaderLabel)
            mediumLabels.append(aboutHeaderLabel)
            mediumLabels.append(nameHeaderLabel)
            
            largeLabels.append(updateButton.titleLabel!)
            nameField.font = UIFont(name: nameField.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            experienceField.font = UIFont(name: experienceField.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            lookingForField.font = UIFont(name: lookingForField.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            aboutField.font = UIFont(name: aboutField.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            activeField.font = UIFont(name: activeField.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            interestFieldOne.font = UIFont(name: interestFieldOne.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            interestFieldTwo.font = UIFont(name: interestFieldTwo.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            interestFieldThree.font = UIFont(name: interestFieldThree.font!.fontName, size: Constants.MEDIUM_FONT_SIZE)
            break
        case Constants.ScreenDimensions.IPHONE_6_PLUS_HEIGHT:
            largeLabels.append(seekingHeaderLabel)
            largeLabels.append(interestsHeaderLabel)
            largeLabels.append(professionHeaderLabel)
            largeLabels.append(aboutHeaderLabel)
            largeLabels.append(nameHeaderLabel)
            
            nameField.font = UIFont(name: nameField.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            experienceField.font = UIFont(name: experienceField.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            lookingForField.font = UIFont(name: lookingForField.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            aboutField.font = UIFont(name: aboutField.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            activeField.font = UIFont(name: activeField.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            interestFieldOne.font = UIFont(name: interestFieldOne.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            interestFieldTwo.font = UIFont(name: interestFieldTwo.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            interestFieldThree.font = UIFont(name: interestFieldThree.font!.fontName, size: Constants.LARGE_FONT_SIZE)
            break
        default:
            break
        }
        
        fontDict[Constants.XSMALL_FONT_SIZE] = extraSmallLabels
        fontDict[Constants.MEDIUM_FONT_SIZE] = mediumLabels
        fontDict[Constants.LARGE_FONT_SIZE] = largeLabels
        
        return fontDict
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
        switch indexPath.row {
        case 0:
            return screenHeight / 4.0
        case 3:
            return screenHeight / 5.5
        case 4:
            return screenHeight / 4.0
        case 6:
            return screenHeight / 8.0
        default:
            return screenHeight / 10.0
        }
    }
}
