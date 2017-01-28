    //
//  SystemSettingsTableViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class SystemSettingsTableViewController: TableViewController {
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
            self.dismiss(animated: true, completion: nil);
    }
    
    @IBOutlet weak var greetingTemplate: UITextView!
    // Set up local datastore
    let defaults:UserDefaults = UserDefaults.standard;
    
    // Logout user and reset datastore
    @IBAction func userLogOut(_ sender: UIButton) {
        let query = PFQuery(className:"Profile")
        let currentID = PFUser.current()!.objectId
        query.whereKey("ID", equalTo:currentID!)
        
        query.getFirstObjectInBackground {
            (profile: PFObject?, error: Error?) -> Void in
            if error != nil || profile == nil {
                print(error);
            } else if let profile = profile {
                // Notes that the user is online
                profile["Available"] = false
                profile.saveInBackground()
                PFUser.logOut()
            }
        }
        
        let dict = defaults.dictionaryRepresentation();
        for key in dict.keys {
            defaults.removeObject(forKey: key.debugDescription);
        }
        defaults.synchronize();
        self.dismiss(animated: true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        logoutButton.layer.cornerRadius = 5
        tableView.allowsSelection = false;
        if let template = defaults.string(forKey: Constants.UserKeys.greetingKey) {
            greetingTemplate.text = template;
        } else {
            defaults.set(Constants.ConstantStrings.greetingMessage, forKey: Constants.UserKeys.greetingKey);
            greetingTemplate.text = Constants.ConstantStrings.greetingMessage;
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make footerview so it fill up size of the screen
        // The button is aligned to bottom of the footerview
        // using autolayout constraints
        self.tableView.tableFooterView = nil
        var footerHeight = self.tableView.frame.size.height - self.tableView.contentSize.height - self.footerView.frame.size.height
        if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_4_HEIGHT) {
            footerHeight += 160
        }
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: footerHeight)
        self.tableView.tableFooterView = self.footerView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (self.userLoggedIn()) {
            let query:PFQuery = PFQuery(className: "Profile");
            query.whereKey("ID", equalTo: PFUser.current()!.objectId!);
            
            query.getFirstObjectInBackground {
                (profile: PFObject?, error: Error?) -> Void in
                if (error != nil || profile == nil) {
                    print(error);
                } else if let profile = profile {
                    profile["Greeting"] = self.greetingTemplate.text;
                    self.defaults.set(self.greetingTemplate.text, forKey: Constants.UserKeys.greetingKey);
                    profile.saveInBackground();
                }
            }
        }
        super.viewWillDisappear(true);

    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.current();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }

  }
