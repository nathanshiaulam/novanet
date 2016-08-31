//
//  SelectedProfileViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/15/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class SelectedProfileViewController: ViewController {

    @IBOutlet weak var profileImage: UIImageView!;
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    
    @IBOutlet weak var firstInterestLabel: UILabel!
    @IBOutlet weak var secondInterestLabel: UILabel!
    @IBOutlet weak var thirdInterestLabel: UILabel!
    
    @IBOutlet weak var lookingForLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var distanceArrow: UIImageView!

    var image:UIImage? = nil
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var fromMessage:Bool! = false;
    
    @IBAction func chatButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("toMessageVC", sender: self)
    }
    @IBAction func backPressed(sender: UIBarButtonItem) {
        if (fromMessage == true) {
            self.navigationController?.popViewControllerAnimated(true);
        } else {
            self.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let dotOne = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotOne.frame = CGRectMake(-10 , firstInterestLabel.bounds.size.height / 2.0 - 5, 5, 5)
        dotOne.contentMode = UIViewContentMode.Center
        firstInterestLabel.addSubview(dotOne)
        
        let dotTwo = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotTwo.frame = CGRectMake(-10 , secondInterestLabel.bounds.size.height / 2.0 - 5, 5, 5)
        dotTwo.contentMode = UIViewContentMode.Center
        secondInterestLabel.addSubview(dotTwo)
        
        let dotThree = UIImageView(image: UIImage(named: "orangeDot.png"))
        dotThree.frame = CGRectMake(-10 , firstInterestLabel.bounds.size.height / 2.0 - 5, 5, 5)
        dotThree.contentMode = UIViewContentMode.Center
        thirdInterestLabel.addSubview(dotThree)
        
        setValues()

        if (self.image != nil) {
            profileImage.image = image;
        } else {
            profileImage.image = UIImage(named: "selectImage");
        }
        self.view.backgroundColor = UIColor.whiteColor();
        self.navigationController?.navigationBar.backgroundColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
    }
    
    override func viewWillLayoutSubviews() {
        let fontDict:[CGFloat : [UILabel]] = getChangeLabelDict();
        Utilities.manageFontSizes(fontDict)
    }
    
    override func viewDidLayoutSubviews() {
        Utilities().formatImage(self.profileImage)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toMessageVC" {
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! MessagerViewController
            if (self.image != nil) {
                destinationVC.nextImage = self.image;
            } else {
                destinationVC.nextImage = UIImage(named: "selectImage")
            }
        }
    }

    
    /*-------------------------------- HELPER METHODS ------------------------------------*/

    // Methods to format image and convert RGB to hex
    func formatImage( profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    // Sets all values of the user profile fields
    func setValues() {
        
        if let name = defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey) {
            nameLabel.text = name;
            if name.characters.count == 0 {
                nameLabel.text = "Name"
            }
        } else {
            nameLabel.text = "Name"
        }
        if let about = defaults.stringForKey(Constants.SelectedUserKeys.selectedAboutKey) {
            aboutLabel.text = about;
            if about.characters.count == 0 {
                aboutLabel.text = "A sentence or two illustrating what you're about. Who are you, in a nutshell?"
            }
        } else {
            aboutLabel.text = "A sentence or two illustrating what you're about. Who are you, in a nutshell?"
        }
        if let interests = defaults.arrayForKey(Constants.SelectedUserKeys.selectedInterestsKey) {
            var interestsArr = interests;
            if (interestsArr.count == 0) {
                firstInterestLabel.text = "What are your interests?"
            } else {
                var interestsLabelArr:[UILabel] = [UILabel]()
                interestsLabelArr.append(firstInterestLabel)
                interestsLabelArr.append(secondInterestLabel)
                interestsLabelArr.append(thirdInterestLabel)
                var numInterests = 0
                if interestsArr.count > Constants.MAX_NUM_INTERESTS {
                    numInterests = Constants.MAX_NUM_INTERESTS
                } else  {
                    numInterests = interestsArr.count
                }
                for i in 0..<numInterests {
                    interestsLabelArr[i].text = interestsArr[i] as? String
                }
                for i in numInterests..<interestsLabelArr.count {
                    interestsLabelArr[i].text = ""
                }
                let firstInterest = interestsArr[0] as? String
                if (firstInterest!.characters.count == 0) {
                    interestsLabelArr[0].text = "What are your interests?"
                }
            }
            
        }
        if let experience = defaults.stringForKey(Constants.SelectedUserKeys.selectedExperienceKey) {
            experienceLabel.text = experience;
            if (experience.characters.count == 0) {
                experienceLabel.text = "What's your experience?"
            }
        } else {
            experienceLabel.text = "What's your experience?"
        }
        if let lookingFor = defaults.stringForKey(Constants.SelectedUserKeys.selectedLookingForKey) {
            let seekingString = NSMutableAttributedString(string: lookingFor)
            let seekingHeader = "Seeking // "
            
            let attrs:[String : AnyObject] =  [NSFontAttributeName : UIFont(name: "OpenSans-Bold", size: Constants.MEDIUM_FONT_SIZE)!, NSForegroundColorAttributeName: Utilities().UIColorFromHex(0x879494, alpha: 1.0)]
            
            let boldedString = NSMutableAttributedString(string:seekingHeader, attributes:attrs)
            
            boldedString.appendAttributedString(seekingString)
            
            lookingForLabel.text = boldedString.string
            if (lookingFor.characters.count == 0) {
                lookingForLabel.text = "Who are you looking for?"
            }
        } else {
            lookingForLabel.text = "Who are you looking for?"
        }
        
        if let dist: AnyObject = defaults.objectForKey(Constants.SelectedUserKeys.selectedDistanceKey) {
            distLabel.text = String(stringInterpolationSegment: dist) + "km";
        } else {
            distLabel.hidden = true
            distanceArrow.hidden = true
            chatButton.layer.cornerRadius = 5
        }
        if (fromMessage == true) {
            distLabel.hidden = true
            distanceArrow.hidden = true
        }
        
        experienceLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        experienceLabel.sizeToFit();
        
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        nameLabel.sizeToFit();
        
        firstInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        firstInterestLabel.sizeToFit();
        
        secondInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        secondInterestLabel.sizeToFit();
        
        thirdInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        thirdInterestLabel.sizeToFit();
        
        lookingForLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        lookingForLabel.sizeToFit();
        
        self.title = nameLabel.text;
    }
    
    // Edits font sizes and image constraints to fit in each mode
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
}
