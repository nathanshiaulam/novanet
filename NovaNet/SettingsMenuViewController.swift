//
//  SettingsMenuViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class SettingsMenuViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var aboutField: UITextView!
    @IBOutlet weak var experienceField: UITextField!
    
    @IBOutlet weak var firstInterestField: UITextField!
    @IBOutlet weak var secondInterestField: UITextField!
    @IBOutlet weak var thirdInterestField: UITextField!

    @IBOutlet weak var lookingForField: UITextField!
    
    var activeField:UITextField = UITextField();
    let picker = UIImagePickerController();
    var popover:UIPopoverController? = nil;
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    @IBAction func saveInfo(sender: UIBarButtonItem) {
        saveProfile();
    }
    
    
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyBoardNotifications()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        //Looks for single or multiple taps to remove keyboard
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Allows user to upload photo
        var tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedImage");
        tapGestureRecognizer.delegate = self;
        self.profileImage.addGestureRecognizer(tapGestureRecognizer);
        self.profileImage.userInteractionEnabled = true;
        
        prepareTextFields();
        picker.delegate = self;
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
            textView.text = Constants.ConstantStrings.aboutText;
            textView.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var maxtext = 80
        //If the text is larger than the maxtext, the return is false
        return count(textView.text) + (count(text) - range.length) <= maxtext
        
    }
    
    /*-------------------------------- TextFieldDel Methods ------------------------------------*/
    
    
    // checks active field
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField;
    }
    func textFieldDidEndEditing(textField: UITextField) {
    }
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
        if (textField == nameField) {
            return newLength <= 25
        } else {
            return newLength <= 25
        }
    }
    

    /*-------------------------------- Image Picker Delegate Methods ------------------------------------*/
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        saveImage(profileImage.image!);
        let pickedImage:UIImage = self.profileImage.image!;
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5);
        let imageFile:PFFile = PFFile(data: imageData)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                profile["Image"] = imageFile;
                profile.saveInBackground();
            }
        }
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        println("Picker cancel.");
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        profileImage.image = image
        self.dismissViewControllerAnimated(true, completion: { () -> Void in})
        
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        saveImage(profileImage.image!);
        let pickedImage:UIImage = self.profileImage.image!;
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5);
        let imageFile:PFFile = PFFile(data: imageData)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                profile["Image"] = imageFile;
                profile.saveInBackground();
            }
        }
        
    }
    /*-------------------------------- CAMERA METHODS ------------------------------------*/
    
    func tappedImage() {
        var alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet);
        
        var galleryAction = UIAlertAction(title: "Upload a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallery()
        }
        var cameraAction = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
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
    
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Converts to RGB from Hex
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

    // Methods to read and write images from local data store/Parse
    func readImage() -> UIImage {
        let possibleOldImagePath = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserKeys.profileImageKey) as! String?
        var oldImage = UIImage();
        if let oldImagePath = possibleOldImagePath {
            let oldFullPath = self.documentsPathForFileName(oldImagePath)
            let oldImageData = NSData(contentsOfFile: oldFullPath)
            oldImage = UIImage(data: oldImageData!)!
        } else {
            oldImage = UIImage(named: "selectImage")!;
        }
        return oldImage;
    }
    func saveImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path = self.documentsPathForFileName(relativePath)
        imageData.writeToFile(path, atomically: true)
        NSUserDefaults.standardUserDefaults().setObject(relativePath, forKey: Constants.UserKeys.profileImageKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    func documentsPathForFileName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let path = paths[0] as! String;
        let fullPath = path.stringByAppendingPathComponent(name)
        
        return fullPath
    }
    
    // Methods to format image and convert RGB to hex
    func formatImage(var profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    
    // Prepares all text fields
    func prepareTextFields() {
        nameField.backgroundColor = UIColor.clearColor();
        var nameFieldPlaceholder = NSAttributedString(string: "What's your name?", attributes: [NSForegroundColorAttributeName : UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.textColor = UIColor.blackColor();
        nameField.borderStyle = UITextBorderStyle.None;
        nameField.font = UIFont(name: "Avenir", size: 16);
        
        aboutField.backgroundColor = UIColor.clearColor();
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

        // Set texts if exists
        if var name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameField.text = name;
        }
        // Set About Field View Text
        if var about = defaults.stringForKey(Constants.UserKeys.aboutKey) {
            aboutField.text = about;
            if (about == Constants.ConstantStrings.aboutText) {
                aboutField.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0);
            }
        } else {
            aboutField.text = "A sentence or two illustrating what you're about. Who are you in a nutshell?";
            aboutField.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0);
        }

        if var interests = defaults.arrayForKey(Constants.UserKeys.interestsKey) {
            var interestArr = interests;
            firstInterestField.text = interestArr[0] as? String;
            secondInterestField.text = interestArr[1] as? String;
            thirdInterestField.text = interestArr[2] as? String;
        }
        if var experience = defaults.stringForKey(Constants.UserKeys.experienceKey) {
            experienceField.text = experience;
        }
        if var looking = defaults.stringForKey(Constants.UserKeys.lookingForKey) {
            lookingForField.text = looking;
        }
        self.profileImage.image = readImage();
        formatImage(self.profileImage);
    }
    
    // Ensures that you can scroll when keyboard up
    func registerForKeyBoardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWasShown:", name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil);

    }
    func keyBoardWasShown(notification: NSNotification) {
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
    
    // Saves all necessary fields of the profile
    func saveProfile() {
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                // Notes that the user is online

                var interestsArr = [String]();
                interestsArr.append(self.firstInterestField.text);
                interestsArr.append(self.secondInterestField.text);
                interestsArr.append(self.thirdInterestField.text);
                profile["Name"] = self.nameField.text;
                profile["InterestsList"] = interestsArr;
                profile["Experience"] = self.experienceField.text;
                profile["Looking"] = self.lookingForField.text;
                profile["About"] = self.aboutField.text;
                profile.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                        self.prepareDataStore();
                        self.navigationController?.popViewControllerAnimated(true);
                    }
                };
            }
        }
    }
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
    }
}
