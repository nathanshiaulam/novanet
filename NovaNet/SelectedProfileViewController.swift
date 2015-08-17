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

    @IBOutlet weak var profileImage: UIImageView! = UIImageView();
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    
    @IBOutlet weak var firstInterestLabel: UILabel!
    @IBOutlet weak var secondInterestLabel: UILabel!
    @IBOutlet weak var thirdInterestLabel: UILabel!
    
    @IBOutlet weak var lookingForLabel: UILabel!

    @IBOutlet weak var distLabel: UILabel!
    
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad();
        println("Result: " );
        println(profileImage.image);
        setValues();
    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Methods to read and write images from local data store/Parse
    func readOtherImage() -> UIImage {
        let possibleOldImagePath = NSUserDefaults.standardUserDefaults().objectForKey(Constants.SelectedUserKeys.selectedProfileImageKey) as! String?
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
//        self.profileImage.image = readOtherImage();
        formatImage(self.profileImage);
    }
   

}
