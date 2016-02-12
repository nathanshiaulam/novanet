//
//  HomeTabBarController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/15/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//


import UIKit
import Parse
import Bolts

class HomeTabBarController: UITabBarController {
    
 
    @IBOutlet var doneButton: UIBarButtonItem!
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        doneButton = nil;
        self.navigationItem.leftBarButtonItem = nil;
        // Notes whether or not user was just created
        if userLoggedIn() {
            let fromNew = defaults.boolForKey(Constants.TempKeys.fromNew)
            
            // Since view appears, if the user is logged in for the first time, segue to Onboarding
            if (fromNew) {
                self.performSegueWithIdentifier("toOnboardingPage", sender: nil)
            }
        }
    }
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
}


