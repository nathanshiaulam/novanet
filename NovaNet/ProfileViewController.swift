//
//  ProfileViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var interestsLabel: UILabel!
    
    @IBOutlet weak var websiteButton: UIButton!
    
    
    func formatImage(var profileImage: UIButton) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    

    func userLogoutSegue() {
        println("ho");
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    @IBAction func openURL(sender: UIButton) {
        if let url = NSURL(string:"http://" + sender.titleLabel!.text!) {
            print("http://" + sender.titleLabel!.text!);
            UIApplication.sharedApplication().openURL(url);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatImage(self.profileImageButton);
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        println("hi");
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLogoutSegue", name: "userLogoutSegue", object: nil);
        
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        
        if let name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameLabel.text = name;
        }
        if let interests = defaults.stringForKey(Constants.UserKeys.interestsKey) {
            interestsLabel.text = "Interests: " + interests;
        }
        if let background = defaults.stringForKey(Constants.UserKeys.backgroundKey) {
            aboutLabel.text = "About: " + background;
        }
        
        aboutLabel.numberOfLines = 0;
        aboutLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        aboutLabel.sizeToFit();
        
        if let website = defaults.stringForKey(Constants.UserKeys.websiteKey) {
            websiteButton.titleLabel?.text = website;
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
