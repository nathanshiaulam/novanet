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

    
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var goalsLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var availableSwitch: UISwitch!
    
    
    override func viewWillDisappear(animated: Bool) {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        if (availableSwitch.on) {
            defaults.setBool(true, forKey: Constants.UserKeys.availableKey)
        } else {
            defaults.setBool(false, forKey:Constants.UserKeys.availableKey);
        }
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                profile["Available"] = defaults.boolForKey(Constants.UserKeys.availableKey);
                profile.saveInBackground();
            }
        }

        super.viewWillDisappear(true);
    }
    
    func formatImage(var profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

    func manageiOSModelType() {
        let modelName = UIDevice.currentDevice().modelName;
        
        switch modelName {
        case "iPhone 4s":
//            let currentX = profileImage.frame.origin.x;
//            let currentY = profileImage.frame.origin.y;
//            var rect = CGRect(x: currentX, y: currentY, width: 40, height: 40);
//            var imageView = UIImageView(frame: rect);
//            self.profileImage.frame = imageView.frame;
            self.nameLabel.font = self.nameLabel.font.fontWithSize(17.0);
            self.aboutLabel.font = self.aboutLabel.font.fontWithSize(11.0);
            self.interestsLabel.font = self.interestsLabel.font.fontWithSize(11.0);
            self.goalsLabel.font = self.goalsLabel.font.fontWithSize(11.0);
            self.availableLabel.font = self.availableLabel.font.fontWithSize(12.0);
        case "iPhone 5":
//            let currentX = profileImage.frame.origin.x;
//            let currentY = profileImage.frame.origin.y;
//            var rect = CGRect(x: currentX, y: currentY, width: 60, height: 60);
//            var imageView = UIImageView(frame: rect);
//            self.profileImage.frame = imageView.frame;
            self.nameLabel.font = self.nameLabel.font.fontWithSize(18.0);
            self.aboutLabel.font = self.aboutLabel.font.fontWithSize(11.0);
            self.interestsLabel.font = self.interestsLabel.font.fontWithSize(11.0);
            self.goalsLabel.font = self.goalsLabel.font.fontWithSize(11.0);
            self.availableLabel.font = self.availableLabel.font.fontWithSize(13.0);
        case "iPhone 6":
            return; // Essentially do nothing
        default:
            return; // Essentially do nothing
        }
    }
    func readImage() -> UIImage {
        let possibleOldImagePath = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserKeys.profileImageKey) as! String?
        var oldImage = UIImage();
        if let oldImagePath = possibleOldImagePath {
            let oldFullPath = self.documentsPathForFileName(oldImagePath)
            let oldImageData = NSData(contentsOfFile: oldFullPath)
            // here is your saved image:
            oldImage = UIImage(data: oldImageData!)!
        }
        return oldImage;
    }
    func saveImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path = self.documentsPathForFileName(relativePath)
        imageData.writeToFile(path, atomically: true)
        NSUserDefaults.standardUserDefaults().setObject(relativePath, forKey: Constants.UserKeys.profileImageKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    func documentsPathForFileName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let path = paths[0] as! String;
        let fullPath = path.stringByAppendingPathComponent(name)
        
        return fullPath
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject];
       
//        manageiOSModelType();
        setValues();
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);        
        let size = CGSizeMake(10, 10)
   
        setValues();
        
    }
    
    func setValues() {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var available = defaults.boolForKey(Constants.UserKeys.availableKey);
        if (available) {
            self.availableSwitch.on = true;
        } else {
            self.availableSwitch.on = false;
        }
        
        if let name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameLabel.text = name;
        }
        if let interests = defaults.stringForKey(Constants.UserKeys.interestsKey) {
            interestsLabel.text = "Interests: " + interests;
        }
        if let background = defaults.stringForKey(Constants.UserKeys.backgroundKey) {
            aboutLabel.text = "Background: " + background;
        }
        if let goals = defaults.stringForKey(Constants.UserKeys.backgroundKey) {
            goalsLabel.text = "Goals: " + goals;
        }
        
        aboutLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        aboutLabel.sizeToFit();
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        nameLabel.sizeToFit();
        interestsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        interestsLabel.sizeToFit();
        goalsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        goalsLabel.sizeToFit();
        
        self.title = "Profile";
        self.profileImage.image = readImage();
        formatImage(self.profileImage);
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
