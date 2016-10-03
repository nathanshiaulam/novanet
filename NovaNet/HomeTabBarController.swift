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
    let defaults:UserDefaults = UserDefaults.standard;
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "BrandonGrotesque-Medium", size: 18)!]

        super.viewDidLoad();
        doneButton = nil;
        self.navigationItem.leftBarButtonItem = nil;
        // Notes whether or not user was just created
    }
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.current();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
}


