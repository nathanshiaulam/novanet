//
//  ProfileViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Bolts
import Parse

class ProfileViewController: ViewController, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var firstInterestLabel: UILabel!
    @IBOutlet weak var secondInterestLabel: UILabel!
    @IBOutlet weak var thirdInterestLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    
    @IBOutlet weak var editLabel: UIButton!
    let picker = UIImagePickerController()
    var popover:UIPopoverController? = nil
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var dotOne:UIImageView!
    var dotTwo:UIImageView!
    var dotThree:UIImageView!
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dotOne = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotOne.frame = CGRectMake(-10, firstInterestLabel.bounds.size.height / 2.0 - 5, 5, 5)
        dotOne.contentMode = UIViewContentMode.Center
        firstInterestLabel.addSubview(dotOne)
        
        dotTwo = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotTwo.frame = CGRectMake(-10, secondInterestLabel.bounds.size.height / 2.0 - 5, 5, 5)
        dotTwo.contentMode = UIViewContentMode.Center
        secondInterestLabel.addSubview(dotTwo)
        
        dotThree = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThree.frame = CGRectMake(-10, thirdInterestLabel.bounds.size.height / 2.0 - 5, 5, 5)
        dotThree.contentMode = UIViewContentMode.Center
        thirdInterestLabel.addSubview(dotThree)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Allows user to upload photo
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tappedImage))
        tapGestureRecognizer.delegate = self

        self.profileImage.addGestureRecognizer(tapGestureRecognizer)
        self.profileImage.userInteractionEnabled = true
        self.tabBarController?.navigationItem.title = "PROFILE"
        
        editLabel.layer.cornerRadius = 5
        
        picker.delegate = self
        setValues()

    }
    
    override func viewWillLayoutSubviews() {
        let fontDict:[CGFloat : [UILabel]] = getChangeLabelDict()
        
        Utilities.manageFontSizes(fontDict)
        Utilities().formatImage(self.profileImage)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Go to login page if no user logged in
        if (!NetworkManager.userLoggedIn()) {
            self.tabBarController?.selectedIndex = 0
            return
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.setValues), name: "setValues", object: nil)

        self.tabBarController?.navigationItem.title = "PROFILE"

        super.viewDidAppear(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    private func getChangeLabelDict() -> [CGFloat : [UILabel]]{
        var fontDict:[CGFloat : [UILabel]] = [CGFloat : [UILabel]]()
        
        var doubleExtraSmallLabels:[UILabel] = [UILabel]()
        var extraSmallLabels:[UILabel] = [UILabel]()
        var smallLabels:[UILabel] = [UILabel]()
        var mediumLabels:[UILabel] = [UILabel]()
        var largeLabels:[UILabel] = [UILabel]()
        var extraLargeLabels:[UILabel] = [UILabel]()
        
        switch Constants.ScreenDimensions.screenHeight {
        case Constants.ScreenDimensions.IPHONE_4_HEIGHT:
            doubleExtraSmallLabels.append(experienceLabel)
            
            extraSmallLabels.append(firstInterestLabel)
            extraSmallLabels.append(secondInterestLabel)
            extraSmallLabels.append(thirdInterestLabel)
            extraSmallLabels.append(aboutLabel)
            extraSmallLabels.append(lookingForLabel)

            smallLabels.append(nameLabel)
            smallLabels.append(editLabel.titleLabel!)
            break
        case Constants.ScreenDimensions.IPHONE_6_HEIGHT:
            smallLabels.append(experienceLabel)
            
            mediumLabels.append(firstInterestLabel)
            mediumLabels.append(secondInterestLabel)
            mediumLabels.append(thirdInterestLabel)
            mediumLabels.append(aboutLabel)
            mediumLabels.append(lookingForLabel)
            
            largeLabels.append(nameLabel)
            break
        case Constants.ScreenDimensions.IPHONE_6_PLUS_HEIGHT:
            mediumLabels.append(experienceLabel)
            
            largeLabels.append(firstInterestLabel)
            largeLabels.append(secondInterestLabel)
            largeLabels.append(thirdInterestLabel)
            largeLabels.append(aboutLabel)
            largeLabels.append(lookingForLabel)
            
            extraLargeLabels.append(nameLabel)
            break
        default:
            break
        }
        
        fontDict[Constants.XXSMALL_FONT_SIZE] = doubleExtraSmallLabels
        fontDict[Constants.XSMALL_FONT_SIZE] = extraSmallLabels
        fontDict[Constants.SMALL_FONT_SIZE] = smallLabels
        fontDict[Constants.MEDIUM_FONT_SIZE] = mediumLabels
        fontDict[Constants.LARGE_FONT_SIZE] = largeLabels
        fontDict[Constants.XLARGE_FONT_SIZE] = extraLargeLabels

        return fontDict
    }
    
    // Sets all values of the user profile fields
    @objc private func setValues() {
        
        if let name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameLabel.text = name
            if name.characters.count == 0 {
                nameLabel.text = "Name"
            }
        } else {
            nameLabel.text = "Name"
        }
        if let about = defaults.stringForKey(Constants.UserKeys.aboutKey) {
            aboutLabel.text = about
            if about.characters.count == 0 {
                aboutLabel.text = "A sentence or two illustrating what you're about. Who are you, in a nutshell?"
            }
        } else {
            aboutLabel.text = "A sentence or two illustrating what you're about. Who are you, in a nutshell?"
        }
        if let interests = defaults.arrayForKey(Constants.UserKeys.interestsKey) {
            var interestsArr = interests
            if (interestsArr.count == 0) {
                firstInterestLabel.text = "What are your interests?"
            } else {
                var interestsLabelArr:[UILabel] = [UILabel]()
                interestsLabelArr.append(firstInterestLabel)
                interestsLabelArr.append(secondInterestLabel)
                interestsLabelArr.append(thirdInterestLabel)
                
                var dotsImage:[UIImageView] = UIImageView()
                dotsImage.append(dotOne)
                dotsImage.append(dotTwo)
                dotsImage.append(dotThree)
                var numInterests = 0
                if interestsArr.count > Constants.MAX_NUM_INTERESTS {
                    numInterests = Constants.MAX_NUM_INTERESTS
                } else  {
                    numInterests = interestsArr.count
                }
                
                
                for i in 0..<numInterests {
                    let interest = interestsArr[i] as? String
                    interestsLabelArr[i].text = interest!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                }
                for i in numInterests..<interestsLabelArr.count {
                    interestsLabelArr[i].text = ""
                    dotsImage[i].hidden = true
                }
                let firstInterest = interestsArr[0] as? String
                if (firstInterest!.characters.count == 0) {
                    interestsLabelArr[1].text = "What are your interests?"
                }
            }
            
        }
        if let experience = defaults.stringForKey(Constants.UserKeys.experienceKey) {
            experienceLabel.text = experience
            if (experience.characters.count == 0) {
                experienceLabel.text = "What's your experience?"
            }
        } else {
            experienceLabel.text = "What's your experience?"
        }
        if let lookingFor = defaults.stringForKey(Constants.UserKeys.lookingForKey) {
            let seekingString = NSMutableAttributedString(string: lookingFor)
            let seekingHeader = "Seeking // "
            
            let attrs:[String : AnyObject] =  [NSFontAttributeName : UIFont(name: "OpenSans-Bold", size: Constants.SMALL_FONT_SIZE)!, NSForegroundColorAttributeName: Utilities().UIColorFromHex(0x879494, alpha: 1.0)]
            
            let boldedString = NSMutableAttributedString(string:seekingHeader, attributes:attrs)
            
            boldedString.appendAttributedString(seekingString)
            
            lookingForLabel.text = boldedString.string
            if (lookingFor.characters.count == 0) {
                lookingForLabel.text = "Who are you looking for?"
            }
        } else {
            lookingForLabel.text = "Who are you looking for?"
        }
        
        experienceLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        experienceLabel.sizeToFit()
        
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        nameLabel.sizeToFit()
        
        firstInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        firstInterestLabel.sizeToFit()
        
        secondInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        secondInterestLabel.sizeToFit()

        thirdInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        thirdInterestLabel.sizeToFit()

        lookingForLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        lookingForLabel.sizeToFit()
        
        self.profileImage.image = Utilities().readImage()
    }
    
    func tappedImage() {
        let alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
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
        alert.addAction(galleryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
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
            popover = UIPopoverController(contentViewController: picker)
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
    
    /*-------------------------------- Image Picker Delegate Methods ------------------------------------*/
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        Utilities().saveImage(profileImage.image!)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        print("Picker cancel.")
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

        profileImage.image = image
        self.dismissViewControllerAnimated(true, completion: { () -> Void in})
         
        Utilities().saveImage(profileImage.image!)
    }
}
