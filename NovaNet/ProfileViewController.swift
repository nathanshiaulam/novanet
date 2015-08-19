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

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var experienceLabel: UILabel!

    @IBOutlet weak var firstInterestLabel: UILabel!
    @IBOutlet weak var secondInterestLabel: UILabel!
    @IBOutlet weak var thirdInterestLabel: UILabel!
    
    @IBOutlet weak var lookingForLabel: UILabel!
    
    @IBOutlet weak var seekingHeaderLabel: UILabel!
    @IBOutlet weak var professionHeaderLabel: UILabel!
    @IBOutlet weak var interestsHeaderLabel: UILabel!
    @IBOutlet weak var editLabel: UIButton!
    let picker = UIImagePickerController();
    var popover:UIPopoverController? = nil;
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    /*-------------------------------- CONSTRAINTS ------------------------------------*/
    
    // Creates dictionary of subviews for constraint adjustment
    var bot:CGFloat!;
    var otherBot:CGFloat!;
    
    // Profile Image Constraints
    @IBOutlet weak var profileImageTopDist: NSLayoutConstraint!
    @IBOutlet weak var profileImageHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidth: NSLayoutConstraint!
    @IBOutlet weak var profileImageNameDist: NSLayoutConstraint!
    
    // Gray Separator Constraints
    @IBOutlet weak var graySeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var graySeparatorWidth: NSLayoutConstraint!
    
    @IBOutlet weak var nameBottomToAbout: NSLayoutConstraint!
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Allows user to upload photo
        var tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedImage");
        tapGestureRecognizer.delegate = self;
        self.profileImage.addGestureRecognizer(tapGestureRecognizer);
        self.profileImage.userInteractionEnabled = true;
        
        picker.delegate = self;
        bot = self.nameBottomToAbout.constant - 3;
        otherBot = self.profileImageNameDist.constant/self.profileImageNameDist.multiplier - 5;
        setValues();
    }
    
    override func viewWillLayoutSubviews() {
        formatImage(self.profileImage);
        manageiOSModelType()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.tabBarController?.selectedIndex = 0;
            return;
        }
        setValues();
        super.viewDidAppear(true);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    

    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        var currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
    
    // Edits font sizes and image constraints to fit in each mode
    func manageiOSModelType() {
        

        if (Constants.ScreenDimensions.screenHeight == 480) {
                
                self.profileImageTopDist.constant = 10;
                self.profileImageHeight.constant = 130;
                self.profileImageWidth.constant = 130;
                self.nameBottomToAbout.constant = bot;
                self.profileImageNameDist.constant = otherBot;
                
                // Set font size of each label
                self.nameLabel.font = self.nameLabel.font.fontWithSize(20.0);
                self.editLabel.titleLabel!.font = self.editLabel.titleLabel!.font.fontWithSize(10.0);
                self.aboutLabel.font = self.aboutLabel.font.fontWithSize(13.0);
                self.experienceLabel.font = self.experienceLabel.font.fontWithSize(13.0);
                self.firstInterestLabel.font = self.firstInterestLabel.font.fontWithSize(13.0);
                self.secondInterestLabel.font = self.secondInterestLabel.font.fontWithSize(13.0);
                self.thirdInterestLabel.font = self.thirdInterestLabel.font.fontWithSize(13.0);
                self.lookingForLabel.font = self.lookingForLabel.font.fontWithSize(13.0);
                self.professionHeaderLabel.font = self.professionHeaderLabel.font.fontWithSize(13.0);
                self.interestsHeaderLabel.font = self.interestsHeaderLabel.font.fontWithSize(13.0);
                self.seekingHeaderLabel.font = self.seekingHeaderLabel.font.fontWithSize(13.0);
                
                return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
                self.profileImageTopDist.constant = 20;
                self.profileImageHeight.constant = 150;
                self.profileImageWidth.constant = 150;
                
                // Set font size of each label
                self.nameLabel.font = self.nameLabel.font.fontWithSize(23.0);
                self.editLabel.titleLabel!.font = self.editLabel.titleLabel!.font.fontWithSize(13.0);
                self.aboutLabel.font = self.aboutLabel.font.fontWithSize(16.0);
                self.experienceLabel.font = self.experienceLabel.font.fontWithSize(16.0);
                self.firstInterestLabel.font = self.firstInterestLabel.font.fontWithSize(16.0);
                self.secondInterestLabel.font = self.secondInterestLabel.font.fontWithSize(16.0);
                self.thirdInterestLabel.font = self.thirdInterestLabel.font.fontWithSize(16.0);
                self.lookingForLabel.font = self.lookingForLabel.font.fontWithSize(16.0);
                self.professionHeaderLabel.font = self.professionHeaderLabel.font.fontWithSize(16.0);
                self.interestsHeaderLabel.font = self.interestsHeaderLabel.font.fontWithSize(16.0);
                self.seekingHeaderLabel.font = self.seekingHeaderLabel.font.fontWithSize(16.0);

                return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
                self.profileImageTopDist.constant = 20;
                self.profileImageHeight.constant = 200;
                self.profileImageWidth.constant = 200;
                return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
                self.profileImageTopDist.constant = 40;
                self.profileImageHeight.constant = 225;
                self.profileImageWidth.constant = 225;

                return;
        }
    }

    
    // Methods to read and write images from local data store/Parse
    func readImage() -> UIImage {
        let possibleOldImagePath = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserKeys.profileImageKey) as! String?
        var oldImage = UIImage();
        if let oldImagePath = possibleOldImagePath {
            let oldFullPath = self.documentsPathForFileName(oldImagePath)
            let oldImageData = NSData(contentsOfFile: oldFullPath)
            oldImage = UIImage(data: oldImageData!)!
        } else {
            oldImage = UIImage(named: "selectImage")!;
        }
        return oldImage;
    }
    func saveImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
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
    
    
    func formatImage(var profileImage: UIImageView) {
        let croppedImage: UIImage = ImageUtil.cropToSquare(image: profileImage.image!)
        profileImage.image = croppedImage
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }


    
    // Sets all values of the user profile fields
    func setValues() {
        
        if let name = defaults.stringForKey(Constants.UserKeys.nameKey) {
            nameLabel.text = name;
        }
        if let about = defaults.stringForKey(Constants.UserKeys.aboutKey) {
            aboutLabel.text = about;
        }
        if let interests = defaults.arrayForKey(Constants.UserKeys.interestsKey) {
            var interestsArr = interests;
            firstInterestLabel.text = interestsArr[0] as? String;
            secondInterestLabel.text = interestsArr[1] as? String;
            thirdInterestLabel.text = interestsArr[2] as? String;
            
        }
        if let experience = defaults.stringForKey(Constants.UserKeys.experienceKey) {
            experienceLabel.text = experience;
        }
        if let lookingFor = defaults.stringForKey(Constants.UserKeys.lookingForKey) {
            lookingForLabel.text = lookingFor;
        }
        
        experienceLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        experienceLabel.sizeToFit();
        
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        nameLabel.sizeToFit();
        
        firstInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        firstInterestLabel.sizeToFit();
        
        secondInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        secondInterestLabel.sizeToFit();

        thirdInterestLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        thirdInterestLabel.sizeToFit();

        lookingForLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        lookingForLabel.sizeToFit();
        
        self.title = "Profile";
        self.profileImage.image = readImage();
    }
    
    func tappedImage() {
        var alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet);
        
        var galleryAction = UIAlertAction(title: "Upload a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallery()
        }
        var cameraAction = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
        }
        // Add the actions
        alert.addAction(galleryAction);
        alert.addAction(cameraAction);
        alert.addAction(cancelAction);
        
        // Present the actionsheet
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func openGallery() {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: picker);
            popover?.presentPopoverFromRect(profileImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    
    /*-------------------------------- Image Picker Delegate Methods ------------------------------------*/

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        saveImage(profileImage.image!);
        let pickedImage:UIImage = self.profileImage.image!;
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5);
        let imageFile:PFFile = PFFile(data: imageData)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                profile["Image"] = imageFile;
                profile.saveInBackground();
            }
        }

    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        println("Picker cancel.");
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

        profileImage.image = image
        self.dismissViewControllerAnimated(true, completion: { () -> Void in})
        
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        saveImage(profileImage.image!);
        let pickedImage:UIImage = self.profileImage.image!;
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5);
        let imageFile:PFFile = PFFile(data: imageData)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                profile["Image"] = imageFile;
                profile.saveInBackground();
            }
        }
        
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
