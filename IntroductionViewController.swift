//
//  IntroductionViewController.swift
//  
//
//  Created by Nathan Lam on 8/13/15.
//
//

import UIKit
import Bolts
import Parse

class IntroductionViewController: UIViewController {
    
    
    var bot:CGFloat!;
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var continueDistFromBot: NSLayoutConstraint!
    
    @IBOutlet weak var imageY: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var subWelcomeLabel: UILabel!
    // Takes user back to homeview after coming from uploadProfilePictureVC
    func backToHomeView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        self.title = "1 of 4";
        self.welcomeLabel.text = "Welcome, " + PFUser.currentUser()!.username!;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backToHomeView", name: "backToHomeView", object: nil);
        bot = self.continueDistFromBot.constant - 10;
        
    }
    
    override func viewDidLayoutSubviews() {
        manageiOSModelType()
    }
    
    
    func manageiOSModelType() {
        let modelName = UIDevice.currentDevice().modelName;
      
        switch modelName {
            case "iPhone 4s":
                welcomeLabel.font = welcomeLabel.font.fontWithSize(17.0);
                imageY.constant = -35;
                subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(14.0);
                imageHeight.constant = 160;
                imageWidth.constant = 160;
                buttonHeight.constant = 45;
                self.continueDistFromBot.constant = bot;
                return;
            case "iPhone 5":
                welcomeLabel.font = welcomeLabel.font.fontWithSize(18.0);
                subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(14.0);
                imageHeight.constant = 190
                imageWidth.constant = 190
                imageY.constant = -20
                return;
            case "iPhone 6":
                
                return; // Do nothing because designed on iPhone 6 viewport
            case "iPhone 6 Plus":
                welcomeLabel.font = welcomeLabel.font.fontWithSize(24.0);
                subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(18.0);
                imageHeight.constant = 250
                imageWidth.constant = 250
                return;
            default:
                return; // Do nothing
        }
    }

}
