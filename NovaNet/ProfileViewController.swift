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

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var interestsLabel: UILabel!
    
    @IBAction func uploadNewImage(sender: UIButton) {

    }
    
    func formatImage(var profileImage: UIButton) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatImage(self.profileImageButton);
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);        
        
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
