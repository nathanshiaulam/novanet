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
    let defaults:UserDefaults = UserDefaults.standard
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dotOne = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotOne.frame = CGRect(x: -10, y: firstInterestLabel.bounds.size.height / 2.0 - 5, width: 5, height: 5)
        dotOne.contentMode = UIViewContentMode.center
        firstInterestLabel.addSubview(dotOne)
        
        let dotTwo = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotTwo.frame = CGRect(x: -10, y: secondInterestLabel.bounds.size.height / 2.0 - 5, width: 5, height: 5)
        dotTwo.contentMode = UIViewContentMode.center
        secondInterestLabel.addSubview(dotTwo)
        
        let dotThree = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThree.frame = CGRect(x: -10, y: thirdInterestLabel.bounds.size.height / 2.0 - 5, width: 5, height: 5)
        dotThree.contentMode = UIViewContentMode.center
        thirdInterestLabel.addSubview(dotThree)
        
        self.view.backgroundColor = UIColor.white
   
        self.tabBarController?.navigationItem.title = "PROFILE"
        
        editLabel.layer.cornerRadius = 5
        
        picker.delegate = self
        setValues()

    }
    
    override func viewWillLayoutSubviews() {
        let fontDict:[CGFloat : [UILabel]] = getChangeLabelDict()
        Utilities.manageFontSizes(fontDict)
    }
    
    override func viewDidLayoutSubviews() {
        Utilities().formatImage(self.profileImage)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Go to login page if no user logged in
        if (!NetworkManager.userLoggedIn()) {
            self.tabBarController?.selectedIndex = 0
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.setValues), name: NSNotification.Name(rawValue: "setValues"), object: nil)
        setValues()
        self.tabBarController?.navigationItem.title = "PROFILE"

        super.viewDidAppear(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    fileprivate func getChangeLabelDict() -> [CGFloat : [UILabel]]{
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
    @objc fileprivate func setValues() {
        
        if let name = defaults.string(forKey: Constants.UserKeys.nameKey) {
            nameLabel.text = name
            if name.characters.count == 0 {
                nameLabel.text = "Name"
            }
        } else {
            nameLabel.text = "Name"
        }
        if let about = defaults.string(forKey: Constants.UserKeys.aboutKey) {
            aboutLabel.text = about
            if about.characters.count == 0 {
                aboutLabel.text = "A sentence or two illustrating what you're about. Who are you, in a nutshell?"
            }
        } else {
            aboutLabel.text = "A sentence or two illustrating what you're about. Who are you, in a nutshell?"
        }
        if let interests = defaults.array(forKey: Constants.UserKeys.interestsKey) {
            var interestsArr = interests
            if (interestsArr.count == 0) {
                firstInterestLabel.text = "What are your interests?"
            } else {
                var interestsLabelArr:[UILabel] = [UILabel]()
                interestsLabelArr.append(firstInterestLabel)
                interestsLabelArr.append(secondInterestLabel)
                interestsLabelArr.append(thirdInterestLabel)

                for i in 0..<interestsLabelArr.count {
                    let interest = interestsArr[i] as? String
                    interestsLabelArr[i].text = interest!.trimmingCharacters(in: CharacterSet.whitespaces)
                }
            }
            
        }
        if let experience = defaults.string(forKey: Constants.UserKeys.experienceKey) {
            experienceLabel.text = experience
            if (experience.characters.count == 0) {
                experienceLabel.text = "What's your experience?"
            }
        } else {
            experienceLabel.text = "What's your experience?"
        }
        if let lookingFor = defaults.string(forKey: Constants.UserKeys.lookingForKey) {
            let seekingString = NSMutableAttributedString(string: lookingFor)
            let seekingHeader = "Seeking // "
            
            let attrs:[String : AnyObject] =  [NSFontAttributeName : UIFont(name: "OpenSans-Bold", size: Constants.SMALL_FONT_SIZE)!, NSForegroundColorAttributeName: Utilities().UIColorFromHex(0x879494, alpha: 1.0)]
            
            let boldedString = NSMutableAttributedString(string:seekingHeader, attributes:attrs)
            
            boldedString.append(seekingString)
            
            lookingForLabel.text = boldedString.string
            if (lookingFor.characters.count == 0) {
                lookingForLabel.text = "Who are you looking for?"
            }
        } else {
            lookingForLabel.text = "Who are you looking for?"
        }
        
        experienceLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        experienceLabel.sizeToFit()
        
        nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameLabel.sizeToFit()
        
        firstInterestLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        firstInterestLabel.sizeToFit()
        
        secondInterestLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        secondInterestLabel.sizeToFit()

        thirdInterestLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        thirdInterestLabel.sizeToFit()

        lookingForLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        lookingForLabel.sizeToFit()
        
        self.profileImage.image = Utilities().readImage()
    }
}
