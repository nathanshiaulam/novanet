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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tabItems = self.tabBar.items as! [UITabBarItem]
        let tabItem0 = tabItems[0] as UITabBarItem
        let tabItem1 = tabItems[1] as UITabBarItem
        let tabItem2 = tabItems[2] as UITabBarItem
        let tabItem3 = tabItems[3] as UITabBarItem
        self.title = "Finder"
        self.title = "Messages"
        
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self);
        }
    }
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        var currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
}
