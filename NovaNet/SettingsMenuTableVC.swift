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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SettingsMenuTableVC: TableViewController, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UINavigationControllerDelegate, UITextViewDelegate  {
    let defaults:UserDefaults = UserDefaults.standard;
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
    
    @IBAction func updateValues(_ sender: UIButton) {
        if (nameField.text?.characters.count > 0 && experienceField.text?.characters.count > 0) {
            saveProfile()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setValues"), object: nil)
            self.navigationController!.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Empty Field", message: "Please fill in your name and profession.", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    fileprivate let firstInterestPlaceholder = "Nova"
    fileprivate let secondInterestPlaceholder = "Reading"
    fileprivate let thirdInterestPlaceholder = "Sports"
    fileprivate let seekingPlaceholder = "Novas."
    fileprivate let profileImageHeight = Constants.ScreenDimensions.screenHeight / 4.0 - 14.0
    fileprivate var lightenedImage:Bool!
    /* NIB LIFE CYCLE METHODS */
    override func viewDidLoad() {
        lightenedImage = false
        super.viewDidLoad()
        updateButton.layer.cornerRadius = 5
        
        // Allows user to upload photo
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsMenuTableVC.tappedImage));
        tapGestureRecognizer.delegate = self;
        
        self.profileImage.addGestureRecognizer(tapGestureRecognizer);
        self.profileImage.isUserInteractionEnabled = true;
        self.profileImage.frame = CGRect(x: 0, y: 0, width: profileImageHeight, height: profileImageHeight)
        Utilities.formatImageWithWidth(profileImage, width: profileImageHeight)
        picker.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        tableView.allowsSelection = false;
        picker.delegate = self;

        prepareTextFields();
    }
    
    /* TEXTVIEW DELEGATE METHODS*/
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "A sentence or two illustrating what you're about. Who are you in a nutshell?";
            textView.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxtext = 80
        //If the text is larger than the maxtext, the return is false
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }
    func textViewShouldReturn(_ textView: UITextView!) -> Bool {
        self.view.endEditing(true)
        interestFieldOne.becomeFirstResponder()
        return true;
    }
    
    /* TEXTFIELD DELEGATE METHODS*/
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(_ textField: UITextField)-> Bool {
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
    private func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField;
        
    }

    // Sets the character limit of each text field
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var limit:Int!
        if (textField == nameField ||
            textField == experienceField ||
            textField == lookingForField)
        {
            limit = 30
        } else {
            limit = 9
        }
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= limit
    }
    
    // Removes keyboard when tap out of screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    /* IMAGE PICKER METHODS */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil);
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        Utilities.formatImageWithWidth(profileImage, width: profileImageHeight)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
        print("Picker cancel.");
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        profileImage.image = image
        self.dismiss(animated: true, completion: { () -> Void in})
        
        let query = PFQuery(className:"Profile");
        let currentID = PFUser.current()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        let pickedImage:UIImage = self.profileImage.image!;
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5);
        let imageFile:PFFile = PFFile(data: imageData!)
        
        query.getFirstObjectInBackground {
            (profile: PFObject?, error: Error?) -> Void in
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
        let alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet);
        
        let galleryAction = UIAlertAction(title: "Upload a Photo", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                self.openGallery()
        }
        let cameraAction = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
        }
        // Add the actions
        alert.addAction(galleryAction);
        alert.addAction(cameraAction);
        alert.addAction(cancelAction);
        
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
    }
    func openGallery() {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: picker);
            popover?.present(from: profileImage.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }

    /* HELPER METHODS */

    func trim(_ val: String) -> String {
        return val.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // Saves all necessary fields of the profile
    func saveProfile() {
        var interestsArr:[String] = [String]()
        interestFieldOne.text?.characters.count != 0 ? interestsArr.append(trim(interestFieldOne.text!)) : interestsArr.append(firstInterestPlaceholder)
        interestFieldTwo.text?.characters.count != 0 ? interestsArr.append(trim(interestFieldTwo.text!)) : interestsArr.append(secondInterestPlaceholder)
        interestFieldThree.text?.characters.count != 0 ? interestsArr.append(trim(interestFieldThree.text!)) : interestsArr.append(thirdInterestPlaceholder)
        
        defaults.set(nameField.text, forKey: Constants.UserKeys.nameKey)
        defaults.set(interestsArr, forKey: Constants.UserKeys.interestsKey)
        defaults.set(experienceField.text, forKey: Constants.UserKeys.experienceKey)
        defaults.set(lookingForField.text, forKey: Constants.UserKeys.lookingForKey)
        defaults.set(aboutField.text, forKey: Constants.UserKeys.aboutKey)
        Utilities().saveImage(profileImage.image!);

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
        
        nameField.autocapitalizationType = UITextAutocapitalizationType.words
        interestFieldOne.autocapitalizationType = UITextAutocapitalizationType.words
        interestFieldTwo.autocapitalizationType = UITextAutocapitalizationType.words
        interestFieldThree.autocapitalizationType = UITextAutocapitalizationType.words
        experienceField.autocapitalizationType = UITextAutocapitalizationType.words
        lookingForField.autocapitalizationType = UITextAutocapitalizationType.words
        aboutField.autocapitalizationType = UITextAutocapitalizationType.sentences
        
        nameField.backgroundColor = UIColor.clear;
        let nameFieldPlaceholder = NSAttributedString(string: "What's your name?", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        nameField.attributedPlaceholder = nameFieldPlaceholder;
        nameField.borderStyle = UITextBorderStyle.none;
        nameField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        aboutField.backgroundColor = UIColor.clear;
        aboutField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        interestFieldOne.backgroundColor = UIColor.clear;
        let interestsFieldOnePlaceholder = NSAttributedString(string: firstInterestPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestFieldOne.attributedPlaceholder = interestsFieldOnePlaceholder;
        interestFieldOne.borderStyle = UITextBorderStyle.none
        interestFieldOne.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        let dotOneImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotOneImage.frame = CGRect(x: 0, y: 0, width: dotOneImage.frame.width + 15, height: dotOneImage.frame.height)
        dotOneImage.contentMode = UIViewContentMode.center
        interestFieldOne.leftView = dotOneImage
        interestFieldOne.leftViewMode = UITextFieldViewMode.always
        
        interestFieldTwo.backgroundColor = UIColor.clear;
        let interestsFieldTwoPlaceholder = NSAttributedString(string: secondInterestPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestFieldTwo.attributedPlaceholder = interestsFieldTwoPlaceholder;
        interestFieldTwo.borderStyle = UITextBorderStyle.none
        interestFieldTwo.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        let dotTwoImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotTwoImage.frame = CGRect(x: 0, y: 0, width: dotTwoImage.frame.width + 15, height: dotTwoImage.frame.height)
        dotTwoImage.contentMode = UIViewContentMode.center
        interestFieldTwo.leftView = dotTwoImage
        interestFieldTwo.leftViewMode = UITextFieldViewMode.always
        
        interestFieldThree.backgroundColor = UIColor.clear;
        let interestsFieldThreePlaceholder = NSAttributedString(string: thirdInterestPlaceholder, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        interestFieldThree.attributedPlaceholder = interestsFieldThreePlaceholder;
        interestFieldThree.borderStyle = UITextBorderStyle.none
        interestFieldThree.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        let dotThreeImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThreeImage.frame = CGRect(x: 0, y: 0, width: dotThreeImage.frame.width + 15, height: dotThreeImage.frame.height)
        dotThreeImage.contentMode = UIViewContentMode.center
        interestFieldThree.leftView = dotThreeImage
        interestFieldThree.leftViewMode = UITextFieldViewMode.always

        experienceField.backgroundColor = UIColor.clear;
        let backgroundFieldPlaceholder = NSAttributedString(string: "e.g. Systems Engineer", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder;
        experienceField.borderStyle = UITextBorderStyle.none
        experienceField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        lookingForField.backgroundColor = UIColor.clear;
        let goalsFieldPlaceholder = NSAttributedString(string: "What are you looking for?", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder;
        lookingForField.borderStyle = UITextBorderStyle.none
        lookingForField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE);
        
        // Set texts if exists
        if let name = defaults.string(forKey: Constants.UserKeys.nameKey) {
            nameField.text = name;
        }
        // Set About Field View Text
        if let about = defaults.string(forKey: Constants.UserKeys.aboutKey) {
            aboutField.text = about;
            if (about == Constants.ConstantStrings.aboutText) {
                aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0);
            }
        } else {
            aboutField.text = "A sentence or two illustrating what you're about. Who are you in a nutshell?";
            aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0);
        }
        
        let interestsFields = [interestFieldOne, interestFieldTwo, interestFieldThree]
        if let interests = defaults.array(forKey: Constants.UserKeys.interestsKey) {
            var interestsArr = interests;
            for i in 0..<interestsArr.count {
                interestsFields[i]?.text = interestsArr[i] as? String
            }

        }
        if let experience = defaults.string(forKey: Constants.UserKeys.experienceKey) {
            experienceField.text = experience;
        }
        if let looking = defaults.string(forKey: Constants.UserKeys.lookingForKey) {
            lookingForField.text = looking;
        }
        self.profileImage.image = Utilities().readImage();
    }
    
    fileprivate func getChangeLabelDict() -> [CGFloat : [UILabel]]{
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
    
    func alpha(_ value:CGFloat, image:UIImage)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext();
        let area = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height);
        
        ctx?.scaleBy(x: 1, y: -1);
        ctx?.translateBy(x: 0, y: -area.size.height);
        ctx?.setBlendMode(CGBlendMode.multiply);
        ctx?.setAlpha(value);
        ctx?.draw(image.cgImage!, in: area);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            return screenHeight / 4.0
        case 3:
            return screenHeight / 5.5
        case 4:
            return screenHeight / 4.5
        case 6:
            return screenHeight / 7.5
        default:
            return screenHeight / 10.0
        }
    }
}
