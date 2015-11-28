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
    
    override func viewDidLoad() {
        super.viewDidLoad();
        doneButton = nil;
        self.navigationItem.leftBarButtonItem = nil;
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
