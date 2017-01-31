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
    let defaults:UserDefaults = UserDefaults.standard
    @IBOutlet weak var profileImage: UIImageView!

    /* TEXTFIELDS */
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var experienceField: UITextField!
    @IBOutlet weak var lookingForField: UITextField!
    @IBOutlet weak var aboutField: UITextView!
    @IBOutlet weak var interestFieldOne: UITextField!
    @IBOutlet weak var interestFieldTwo: UITextField!
    @IBOutlet weak var interestFieldThree: UITextField!
    var activeField:UITextField = UITextField()

    /* LABELS */
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    @IBOutlet weak var aboutHeaderLabel: UILabel!
    @IBOutlet weak var nameHeaderLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    /* INSTANCE VARS */
    
    let picker = UIImagePickerController()
    var popover:UIPopoverController?
    var currProfile: Profile!
    
    @IBAction func updateValues(_ sender: UIButton) {
        if (nameField.text?.characters.count > 0 && experienceField.text?.characters.count > 0) {
            saveProfile()
        } else {
            Utilities.presentStandardError(errorString: "Please fill in your name and profession.", alertTitle: "Empty Field", actionTitle: "Ok", sender: self)
        }
    }
    
    fileprivate let profileImageHeight = Constants.ScreenDimensions.screenHeight / 4.0 - 14.0
    fileprivate var lightenedImage:Bool!
    
    /* NIB LIFE CYCLE METHODS */
    override func viewDidLoad() {
        lightenedImage = false
        updateButton.layer.cornerRadius = 5
        
        // Allows user to upload photo
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsMenuTableVC.tappedImage))
        tapGestureRecognizer.delegate = self
        self.profileImage.addGestureRecognizer(tapGestureRecognizer)
        self.profileImage.isUserInteractionEnabled = true
        self.profileImage.frame = CGRect(x: 0, y: 0, width: profileImageHeight, height: profileImageHeight)
        Utilities.formatImageWithWidth(profileImage, width: profileImageHeight)
        picker.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        tableView.allowsSelection = false
        picker.delegate = self

        prepareTextFields()
        super.viewDidLoad()
    }
    
    /* TEXTVIEW DELEGATE METHODS*/
    
    // Saves all necessary fields of the profile
    func saveProfile() {
        let userId = UserAPI.sharedInstance.getId()
        ProfileAPI.sharedInstance.editProfileByUserId(
            userId: userId,
            dict: self.currProfile.prof_dictRepresentation(),
            completion: {
                UserAPI.sharedInstance.setUserDefaults(id: userId, prof: self.currProfile)
                self.navigationController!.popViewController(animated: true)
        })
    }
    
    // Prepares all text fields
    func prepareTextFields() {
        
        nameField.backgroundColor = UIColor.clear
        let nameFieldPlaceholder = NSAttributedString(string: Placeholders.NAME, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        nameField.attributedPlaceholder = nameFieldPlaceholder
        nameField.borderStyle = UITextBorderStyle.none
        nameField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        aboutField.backgroundColor = UIColor.clear
        aboutField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        interestFieldOne.backgroundColor = UIColor.clear
        let interestsFieldOnePlaceholder = NSAttributedString(string: Placeholders.INTEREST_ONE, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        interestFieldOne.attributedPlaceholder = interestsFieldOnePlaceholder
        interestFieldOne.borderStyle = UITextBorderStyle.none
        interestFieldOne.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        let dotOneImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotOneImage.frame = CGRect(x: 0, y: 0, width: dotOneImage.frame.width + 15, height: dotOneImage.frame.height)
        dotOneImage.contentMode = UIViewContentMode.center
        interestFieldOne.leftView = dotOneImage
        interestFieldOne.leftViewMode = UITextFieldViewMode.always
        
        interestFieldTwo.backgroundColor = UIColor.clear
        let interestsFieldTwoPlaceholder = NSAttributedString(string: Placeholders.INTEREST_TWO, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        interestFieldTwo.attributedPlaceholder = interestsFieldTwoPlaceholder
        interestFieldTwo.borderStyle = UITextBorderStyle.none
        interestFieldTwo.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        let dotTwoImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotTwoImage.frame = CGRect(x: 0, y: 0, width: dotTwoImage.frame.width + 15, height: dotTwoImage.frame.height)
        dotTwoImage.contentMode = UIViewContentMode.center
        interestFieldTwo.leftView = dotTwoImage
        interestFieldTwo.leftViewMode = UITextFieldViewMode.always
        
        interestFieldThree.backgroundColor = UIColor.clear
        let interestsFieldThreePlaceholder = NSAttributedString(string: Placeholders.INTEREST_THREE, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        interestFieldThree.attributedPlaceholder = interestsFieldThreePlaceholder
        interestFieldThree.borderStyle = UITextBorderStyle.none
        interestFieldThree.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        let dotThreeImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThreeImage.frame = CGRect(x: 0, y: 0, width: dotThreeImage.frame.width + 15, height: dotThreeImage.frame.height)
        dotThreeImage.contentMode = UIViewContentMode.center
        interestFieldThree.leftView = dotThreeImage
        interestFieldThree.leftViewMode = UITextFieldViewMode.always

        experienceField.backgroundColor = UIColor.clear
        let backgroundFieldPlaceholder = NSAttributedString(string: Placeholders.EXPERIENCE, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder
        experienceField.borderStyle = UITextBorderStyle.none
        experienceField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        lookingForField.backgroundColor = UIColor.clear
        let goalsFieldPlaceholder = NSAttributedString(string: Placeholders.LOOKING_FOR, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder
        lookingForField.borderStyle = UITextBorderStyle.none
        lookingForField.font = UIFont(name: "OpenSans", size: Constants.SMALL_FONT_SIZE)
        
        for field in self.view.getFieldsInView() {
            field.autocapitalizationType = UITextAutocapitalizationType.words
        }
        aboutField.autocapitalizationType = UITextAutocapitalizationType.sentences
        
        // Set texts if exists
        nameField.text = currProfile.getName()
        experienceField.text = currProfile.getExp()
        lookingForField.text = currProfile.getLookingFor()?.swapIfEmpty(replace: Placeholders.LOOKING_FOR)
        profileImage.image = currProfile.getImage()
        
        let interests:[String] = currProfile.getInterests()!
        let interestsFields = [interestFieldOne, interestFieldTwo, interestFieldThree]

        for i in 0..<interests.count {
            interestsFields[i]?.text = interests[i] as? String
        }
        
        aboutField.text = currProfile.getAbout()?.swapIfEmpty(replace: Placeholders.ABOUT)
        if (aboutField.text == Placeholders.ABOUT) {
            aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Placeholders.ABOUT
            textView.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
        currProfile.setAbout(about: textView.text)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxtext = 80
        //If the text is larger than the maxtext, the return is false
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }
    func textViewShouldReturn(_ textView: UITextView!) -> Bool {
        self.view.endEditing(true)
        interestFieldOne.becomeFirstResponder()
        return true
    }
    
    /* TEXTFIELD DELEGATE METHODS*/
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(_ textField: UITextField)-> Bool {
        if (textField == nameField) {
            experienceField.becomeFirstResponder()
        }
        else if (textField == experienceField) {
            textField.resignFirstResponder()
            aboutField.becomeFirstResponder()
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
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if false {}
        switch textField {
        case nameField:
            currProfile.setName(name: nameField.text!)
            break
        case experienceField:
            currProfile.setExp(experience: experienceField.text!)
            break
        case interestFieldOne:
            let interest = interestFieldOne.text!.swapIfEmpty(replace: Placeholders.INTEREST_ONE)
            currProfile.setInterest(interest: interest, index: 0)
            break
        case interestFieldTwo:
            let interest = interestFieldTwo.text!.swapIfEmpty(replace: Placeholders.INTEREST_TWO)
            currProfile.setInterest(interest: interest, index: 1)
            break
        case interestFieldThree:
            let interest = interestFieldThree.text!.swapIfEmpty(replace: Placeholders.INTEREST_THREE)
            currProfile.setInterest(interest: interest, index: 2)
            break
        case lookingForField:
            let looking_for = lookingForField.text!.swapIfEmpty(replace: Placeholders.LOOKING_FOR)
            currProfile.setSeeking(seeking: looking_for)
            break
        default:
            break
        }
    }
    // checks active field
    private func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
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
        self.view.endEditing(true)
    }
    
    /* IMAGE PICKER METHODS */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        Utilities.formatImageWithWidth(profileImage, width: profileImageHeight)
        currProfile.setImage(image: profileImage.image!)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Picker cancel.")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        profileImage.image = image
        currProfile.setImage(image: profileImage.image!)
        self.dismiss(animated: true, completion: { () -> Void in})
    }
    
    /* CAMERA METHODS */
    
    func tappedImage() {
        let alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
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
        alert.addAction(galleryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
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
            popover = UIPopoverController(contentViewController: picker)
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
        
        let ctx = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        ctx?.scaleBy(x: 1, y: -1)
        ctx?.translateBy(x: 0, y: -area.size.height)
        ctx?.setBlendMode(CGBlendMode.multiply)
        ctx?.setAlpha(value)
        ctx?.draw(image.cgImage!, in: area)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
