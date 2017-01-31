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

class ProfileViewController: ViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var firstInterestLabel: UILabel!
    @IBOutlet weak var secondInterestLabel: UILabel!
    @IBOutlet weak var thirdInterestLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    @IBOutlet weak var editLabel: UIButton!
    
    private var currProfile: Profile!
    
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    private func loadView(prof: Profile) {
        nameLabel.text = prof.getName()
        experienceLabel.text = prof.getExp()
        aboutLabel.text = prof.getAbout()?.swapIfEmpty(replace: Placeholders.ABOUT)
        
        if let interests:[String] = prof.getInterests() {
            firstInterestLabel.text = interests[0].swapIfEmpty(replace: Placeholders.INTEREST_ONE)
            secondInterestLabel.text = interests[1].swapIfEmpty(replace: Placeholders.INTEREST_ONE)
            thirdInterestLabel.text = interests[2].swapIfEmpty(replace: Placeholders.INTEREST_ONE)
        }
        
        lookingForLabel.text = prof.getLookingFor()?.swapIfEmpty(replace: Placeholders.LOOKING_FOR)
        self.profileImage.image = prof.getImage()
        
        for label in self.view.getLabelsInView() {
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.sizeToFit()
        }
    }

    //TODO: REMOVE
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
        
        editLabel.layer.cornerRadius = 5
    }

    override func viewDidAppear(_ animated: Bool) {
        
        // Go to login page if no user logged in
        if (!UserAPI.sharedInstance.loggedIn()) {
            self.tabBarController?.selectedIndex = 0
            return
        }
        
        ProfileAPI.sharedInstance.getProfileByUserId(
            userId: UserAPI.sharedInstance.getId(),
            completion: {prof in
                self.currProfile = prof
                self.loadView(prof: prof)
        })
        
        self.tabBarController?.navigationItem.title = "PROFILE"
        super.viewDidAppear(true)
    }
    
    override func viewWillLayoutSubviews() {
        let fontDict:[CGFloat : [UILabel]] = getChangeLabelDict()
        Utilities.manageFontSizes(fontDict)
    }
    
    override func viewDidLayoutSubviews() {
        Utilities().formatImage(self.profileImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toEditProfile" {
            let destinationVC = segue.destination.childViewControllers[0] as! SettingsMenuTableVC
            destinationVC.currProfile = self.currProfile
        }
    }


}
