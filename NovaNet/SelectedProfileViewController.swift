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

class SelectedProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!;
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    
    @IBOutlet weak var firstInterestLabel: UILabel!
    @IBOutlet weak var secondInterestLabel: UILabel!
    @IBOutlet weak var thirdInterestLabel: UILabel!
    
    @IBOutlet weak var lookingForLabel: UILabel!

    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var distHeader: UILabel!
    
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    /*-------------------------------- CONSTRAINTS ------------------------------------*/
    @IBOutlet weak var profileImageHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var graySeparatorWidth: NSLayoutConstraint!
    @IBOutlet weak var graySeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var chatButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var chatButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var nameBottomToAbout: NSLayoutConstraint!
    @IBOutlet weak var profileImageNameDist: NSLayoutConstraint!
    @IBOutlet weak var profileImageTopDist: NSLayoutConstraint!
    var image:UIImage? = nil
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad();
        if (self.image != nil) {
            profileImage.image = image;
        } else {
            profileImage.image = UIImage(named: "selectImage");
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        formatImage(self.profileImage);
        manageiOSModelType();
        setValues();
        
    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/

    // Methods to format image and convert RGB to hex
    func formatImage(var profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    // Sets all values of the user profile fields
    func setValues() {
        
        if let name = defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey) {
            nameLabel.text = name;
        }
        if let about = defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey) {
            aboutLabel.text = about;
        }
        if let interests = defaults.arrayForKey(Constants.SelectedUserKeys.selectedInterestsKey) {
            var interestsArr = interests;
            firstInterestLabel.text = interestsArr[0] as? String;
            secondInterestLabel.text = interestsArr[1] as? String;
            thirdInterestLabel.text = interestsArr[2] as? String;
            
        }
        if let experience = defaults.stringForKey(Constants.SelectedUserKeys.selectedExperienceKey) {
            experienceLabel.text = experience;
        }
        if let lookingFor = defaults.stringForKey(Constants.SelectedUserKeys.selectedLookingForKey) {
            lookingForLabel.text = lookingFor;
        }
        if let dist: AnyObject = defaults.objectForKey(Constants.SelectedUserKeys.selectedDistanceKey) {
            distLabel.text = String(stringInterpolationSegment: dist) + "km";
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
    func manageiOSModelType() {
        let modelName = UIDevice.currentDevice().modelName;
        
        
        switch modelName {
        case "iPhone 4s":
            
            self.profileImageTopDist.constant = self.profileImageTopDist.constant - 17;
            self.profileImageHeight.constant = 120;
            self.profileImageWidth.constant = 120;
            self.nameBottomToAbout.constant = self.nameBottomToAbout.constant - 5;
            self.profileImageNameDist.constant = self.profileImageNameDist.constant/self.profileImageNameDist.multiplier - 5;
            self.graySeparatorHeight.constant = 8;
            self.graySeparatorWidth.constant = 80;
            
            // Set font size of each label
            self.nameLabel.font = self.nameLabel.font.fontWithSize(17.0);
            self.aboutLabel.font = self.aboutLabel.font.fontWithSize(13.0);
            self.experienceLabel.font = self.experienceLabel.font.fontWithSize(13.0);
            self.firstInterestLabel.font = self.firstInterestLabel.font.fontWithSize(13.0);
            self.secondInterestLabel.font = self.secondInterestLabel.font.fontWithSize(13.0);
            self.thirdInterestLabel.font = self.thirdInterestLabel.font.fontWithSize(13.0);
            self.lookingForLabel.font = self.lookingForLabel.font.fontWithSize(13.0);
            self.professionHeaderLabel.font = self.professionHeaderLabel.font.fontWithSize(13.0);
            self.interestsHeaderLabel.font = self.interestsHeaderLabel.font.fontWithSize(13.0);
            self.seekingHeaderLabel.font = self.seekingHeaderLabel.font.fontWithSize(13.0);
            self.distLabel.font = self.distLabel.font.fontWithSize(13.0);
            self.distHeader.font = self.distHeader.font.fontWithSize(13.0);            return;
            
        case "iPhone 5":
            
            self.profileImageTopDist.constant = self.profileImageTopDist.constant - 10;
            self.profileImageNameDist.constant = self.profileImageNameDist.constant - 3
            self.profileImageHeight.constant = 150;
            self.profileImageWidth.constant = 150;
            self.nameBottomToAbout.constant = self.nameBottomToAbout.constant - 3;
            
            // Set font size of each label
            self.nameLabel.font = self.nameLabel.font.fontWithSize(20.0);
            self.aboutLabel.font = self.aboutLabel.font.fontWithSize(15.0);
            self.experienceLabel.font = self.experienceLabel.font.fontWithSize(15.0);
            self.firstInterestLabel.font = self.firstInterestLabel.font.fontWithSize(15.0);
            self.secondInterestLabel.font = self.secondInterestLabel.font.fontWithSize(15.0);
            self.thirdInterestLabel.font = self.thirdInterestLabel.font.fontWithSize(15.0);
            self.lookingForLabel.font = self.lookingForLabel.font.fontWithSize(15.0);
            self.professionHeaderLabel.font = self.professionHeaderLabel.font.fontWithSize(15.0);
            self.interestsHeaderLabel.font = self.interestsHeaderLabel.font.fontWithSize(15.0);
            self.seekingHeaderLabel.font = self.seekingHeaderLabel.font.fontWithSize(15.0);
            self.distLabel.font = self.distLabel.font.fontWithSize(15.0);
            self.distHeader.font = self.distHeader.font.fontWithSize(15.0);
            return;
        case "iPhone 6":
            self.profileImageTopDist.constant = 10;
            self.profileImageHeight.constant = 200;
            self.profileImageWidth.constant = 200;
            return; // Do nothing because designed on iPhone 6 viewport
        case "iPhone 6 Plus":
            
            self.profileImageTopDist.constant = 30;
            self.profileImageHeight.constant = 225;
            self.profileImageWidth.constant = 225;
            
            return;
        default:
            return; // Do nothing
        }
    }

   

}
