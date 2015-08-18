//
//  FinishOnboardingViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/13/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class FinishOnboardingViewController: UIViewController {
    
    var bot:CGFloat!;
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var continueDistFromBot: NSLayoutConstraint!
    
    @IBOutlet weak var imageY: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var subWelcomeLabel: UILabel!
    
    @IBAction func finishedOnboardingProcess(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("backToHomeView", object: nil);
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        bot = self.continueDistFromBot.constant - 10;

        self.title = "4 of 4";
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
