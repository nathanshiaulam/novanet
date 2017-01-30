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


class OnboardingTableViewController: TableViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    let defaults:UserDefaults = UserDefaults.standard
    
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
    @IBOutlet weak var interestFieldOne: UITextField!
    @IBOutlet weak var interestFieldTwo: UITextField!
    @IBOutlet weak var interestFieldThree: UITextField!
    var activeField:UITextField = UITextField()

    /* LABELS */
    @IBOutlet weak var overallHeaderLabel: UILabel!
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    @IBOutlet weak var aboutHeaderLabel: UILabel!
    @IBOutlet weak var nameHeaderLabel: UILabel!
    
    var name: String = ""
    var experience: String = ""
    var lookingFor: String = ""
    var about: String = ""
    var interests: [String] = [Placeholders.INTEREST_ONE,
                               Placeholders.INTEREST_TWO,
                               Placeholders.INTEREST_THREE]
    var currProfile: Profile!
    
    // Prepares local datastore for profile information and saves profile
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        if name.length > 0 && experience.length > 0 {
            saveProfile()
        } else {
            Utilities.presentStandardError(errorString: "In order to skip, please tell us your name and profession.", alertTitle: "Empty Field", actionTitle: "Ok", sender: self)
        }
    }
    
    @IBAction func skipTutorial(_ sender: UIButton) {
        if name.length > 0 && experience.length > 0 {
            saveProfile()
            currProfile.setNew(new: false)
            currProfile.setImage(image: Constants.DEFAULT_IMAGE!)
            
            ProfileAPI.sharedInstance
                .editProfileByUserId(
                    userId: UserAPI.sharedInstance.getId(),
                    dict: currProfile.prof_dictRepresentation(),
                    completion: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "selectProfileVC"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "setValues"), object: nil)
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                })
        } else {
            Utilities.presentStandardError(errorString: "In order to skip, please tell us your name and profession.", alertTitle: "Empty Field", actionTitle: "Ok", sender: self)
        }
    }
    
    // Saves all necessary fields of the profile
    func saveProfile() {
        currProfile.setName(name: name)
        currProfile.setAbout(about: about)
        currProfile.setInterests(interests: interests)
        currProfile.setExp(experience: experience)
        currProfile.setSeeking(seeking: lookingFor)
        currProfile.setAvailability(available: true)
        
        UserAPI.sharedInstance.setUserDefaults(id: UserAPI.sharedInstance.getId(), prof: currProfile)
    }

    // Takes user back to homeview after coming from uploadProfilePictureVC
    func backToHomeView() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setChecks(_ textField: UITextField, hidden: Bool) {
        if textField == nameField {
            nameCheck.isHidden = hidden
        } else if textField == experienceField {
            professionCheck.isHidden = hidden
        } else if (textField == interestFieldOne ||
            textField == interestFieldTwo ||
            textField == interestFieldThree)
        {
            interestCheck.isHidden = hidden
        } else if textField == lookingForField {
            seekingCheck.isHidden = hidden
        }
    }
    
    // Sets the character limit of each text field
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var limit:Int!
        if (textField == nameField ||
            textField == experienceField ||
            textField == lookingForField)
        {
            limit = 29
        } else {
            limit = 9
        }
        
        let currentCharacterCount = textField.text?.length ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.length - range.length
        return newLength <= limit
    }
    
    private func textFieldDidEndEditing(_ textField: UITextField) {
        let isInterest = textField == interestFieldOne ||
            textField == interestFieldTwo ||
            textField == interestFieldThree
        let emptyInterests = interestFieldOne.text?.length == 0 &&
            interestFieldTwo.text?.length == 0 &&
            interestFieldThree.text?.length == 0
        if (textField == nameField) {
            setChecks(nameField, hidden: nameField.text?.length == 0)
        }
        if (textField == experienceField) {
            setChecks(experienceField, hidden: nameField.text?.length == 0)
        }
        if (isInterest) {
            setChecks(interestFieldOne, hidden: emptyInterests)
        }
        if (textField == lookingForField) {
            setChecks(lookingForField, hidden: lookingForField.text?.length == 0)
        }
        
    }
    
    // Removes keyboard when tap out of screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        name = textOrPlaceholder(text: nameField.text!,
                                       placeholder: "")
        experience = textOrPlaceholder(text: experienceField.text!,
                                       placeholder: "")
        about = aboutField.text!.trimmed
        lookingFor = textOrPlaceholder(text: lookingForField.text!,
                                       placeholder: Placeholders.LOOKING_FOR)
        interests[0] = textOrPlaceholder(text: interestFieldOne.text!,
                                         placeholder: Placeholders.INTEREST_ONE)
        interests[1] = textOrPlaceholder(text: interestFieldTwo.text!,
                                         placeholder: Placeholders.INTEREST_TWO)
        interests[2] = textOrPlaceholder(text: interestFieldThree.text!,
                                         placeholder: Placeholders.INTEREST_THREE)
        
        self.view.endEditing(true)
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
            textView.text = Placeholders.ABOUT
            textView.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)
            aboutCheck.isHidden = true
        } else {
            aboutCheck.isHidden = false
        }
    }
    func textViewShouldReturn(_ textView: UITextView!) -> Bool {
        self.view.endEditing(true)
        about = aboutField.text!.trimmed
        interestFieldOne.becomeFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxtext = 80
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }
    
    /* TEXTFIELD DELEGATE METHODS*/
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(_ textField: UITextField)-> Bool {
        if (textField == nameField) {
            name = textOrPlaceholder(text: nameField.text!,
                                     placeholder: "")
            experienceField.becomeFirstResponder()
        }
        else if (textField == experienceField) {
            experience = textOrPlaceholder(text: experienceField.text!,
                                           placeholder: "")
            textField.resignFirstResponder()
            aboutField.becomeFirstResponder()
        }
        if (textField == interestFieldOne) {
            interests[0] = textOrPlaceholder(text: interestFieldOne.text!,
                                             placeholder: Placeholders.INTEREST_ONE)
            textField.resignFirstResponder()
            interestFieldTwo.becomeFirstResponder()
        } else if (textField == interestFieldTwo) {
            interests[1] = textOrPlaceholder(text: interestFieldTwo.text!,
                                             placeholder: Placeholders.INTEREST_TWO)
            textField.resignFirstResponder()
            interestFieldThree.becomeFirstResponder()
        } else if (textField == interestFieldThree) {
            interests[2] = textOrPlaceholder(text: interestFieldThree.text!,
                                             placeholder: Placeholders.INTEREST_THREE)
            textField.resignFirstResponder()
            lookingForField.becomeFirstResponder()
        } else {
            lookingFor = textOrPlaceholder(text: lookingForField.text!,
                                           placeholder: Placeholders.LOOKING_FOR)
            textField.resignFirstResponder()
        }
        return false
    }
    
    // checks active field
    private func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    private func textOrPlaceholder(text: String, placeholder: String) -> String {
        return text.trimmed.length == 0 ? placeholder : text.trimmed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "1 of 2"
        
        ProfileAPI.sharedInstance.getProfileByUserId(
            userId: UserAPI.sharedInstance.getId(),
            completion: {prof in self.currProfile = prof})
        
        NotificationCenter.default.addObserver(self, selector: #selector(OnboardingTableViewController.backToHomeView), name: NSNotification.Name(rawValue: "backToHomeView"), object: nil)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        continueButton.layer.cornerRadius = 5
        nameCheck.isHidden = true
        professionCheck.isHidden = true
        aboutCheck.isHidden = true
        interestCheck.isHidden = true
        seekingCheck.isHidden = true
        
        self.tableView.tableHeaderView = nil
        tableView.allowsSelection = false
        
        prepareTextFields()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func prepareTextFields() {
        
        nameField.autocapitalizationType = UITextAutocapitalizationType.words
        interestFieldOne.autocapitalizationType = UITextAutocapitalizationType.words
        interestFieldTwo.autocapitalizationType = UITextAutocapitalizationType.words
        interestFieldThree.autocapitalizationType = UITextAutocapitalizationType.words
        experienceField.autocapitalizationType = UITextAutocapitalizationType.words
        lookingForField.autocapitalizationType = UITextAutocapitalizationType.sentences
        aboutField.autocapitalizationType = UITextAutocapitalizationType.sentences
        
        nameField.backgroundColor = UIColor.clear
        let nameFieldPlaceholder = NSAttributedString(string: Placeholders.NAME, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        nameField.attributedPlaceholder = nameFieldPlaceholder
        nameField.borderStyle = UITextBorderStyle.none
        nameField.font = UIFont(name: "OpenSans", size: 16)
        
        aboutField.backgroundColor = UIColor.clear
        aboutField.text = Placeholders.ABOUT
        aboutField.textColor = Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)
        aboutField.font = UIFont(name: "OpenSans", size: 16)
        
        interestFieldOne.backgroundColor = UIColor.clear
        let interestsFieldOnePlaceholder = NSAttributedString(string: Placeholders.INTEREST_ONE, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        interestFieldOne.attributedPlaceholder = interestsFieldOnePlaceholder
        interestFieldOne.borderStyle = UITextBorderStyle.none
        interestFieldOne.font = UIFont(name: "OpenSans", size: 16)
        
        let dotOneImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotOneImage.frame = CGRect(x: 0, y: 0, width: dotOneImage.frame.width + 15, height: dotOneImage.frame.height)
        dotOneImage.contentMode = UIViewContentMode.center
        interestFieldOne.leftView = dotOneImage
        interestFieldOne.leftViewMode = UITextFieldViewMode.always
        
        interestFieldTwo.backgroundColor = UIColor.clear
        let interestsFieldTwoPlaceholder = NSAttributedString(string: Placeholders.INTEREST_TWO, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        interestFieldTwo.attributedPlaceholder = interestsFieldTwoPlaceholder
        interestFieldTwo.borderStyle = UITextBorderStyle.none
        interestFieldTwo.font = UIFont(name: "OpenSans", size: 16)
        
        let dotTwoImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotTwoImage.frame = CGRect(x: 0, y: 0, width: dotTwoImage.frame.width + 15, height: dotTwoImage.frame.height)
        dotTwoImage.contentMode = UIViewContentMode.center
        interestFieldTwo.leftView = dotTwoImage
        interestFieldTwo.leftViewMode = UITextFieldViewMode.always
        
        interestFieldThree.backgroundColor = UIColor.clear
        let interestsFieldThreePlaceholder = NSAttributedString(string: Placeholders.INTEREST_THREE, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        interestFieldThree.attributedPlaceholder = interestsFieldThreePlaceholder
        interestFieldThree.borderStyle = UITextBorderStyle.none
        interestFieldThree.font = UIFont(name: "OpenSans", size: 16)
        
        let dotThreeImage = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThreeImage.frame = CGRect(x: 0, y: 0, width: dotThreeImage.frame.width + 15, height: dotThreeImage.frame.height)
        dotThreeImage.contentMode = UIViewContentMode.center
        interestFieldThree.leftView = dotThreeImage
        interestFieldThree.leftViewMode = UITextFieldViewMode.always
        
        experienceField.backgroundColor = UIColor.clear
        let backgroundFieldPlaceholder = NSAttributedString(string: Placeholders.ABOUT, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        experienceField.attributedPlaceholder = backgroundFieldPlaceholder
        experienceField.borderStyle = UITextBorderStyle.none
        experienceField.font = UIFont(name: "OpenSans", size: 16)
        
        lookingForField.backgroundColor = UIColor.clear
        let goalsFieldPlaceholder = NSAttributedString(string: Placeholders.LOOKING_FOR, attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)])
        lookingForField.attributedPlaceholder = goalsFieldPlaceholder
        lookingForField.borderStyle = UITextBorderStyle.none
        lookingForField.font = UIFont(name: "OpenSans", size: 16)
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
                
                smallLabels.append(overallHeaderLabel)
                smallLabels.append(continueButton.titleLabel!)
                
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
                
                largeLabels.append(overallHeaderLabel)
                largeLabels.append(continueButton.titleLabel!)
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
    
    
    /* TABLEVIEW DELEGATE METHODS */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            return screenHeight / 7.0
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
