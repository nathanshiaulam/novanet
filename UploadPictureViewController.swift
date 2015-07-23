//
//  UploadPictureViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/22/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class UploadPictureViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {
    @IBOutlet weak var uploadedImage: UIImageView!
    let picker = UIImagePickerController();
    var popover:UIPopoverController? = nil;
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    @IBAction func finishedOnboarding(sender: UIButton) {
        defaults.setObject(uploadedImage.image, forKey: Constants.UserKeys.profileImageKey);
        defaults.setObject(false, forKey: Constants.TempKeys.fromNew);
        
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                profile["Image"] = self.uploadedImage;
                profile.saveInBackground();
            }
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    @IBOutlet weak var takePhotoTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Initializes gesture recognizer
        var tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedImage");
        tapGestureRecognizer.delegate = self;
        self.uploadedImage.addGestureRecognizer(tapGestureRecognizer);
        self.uploadedImage.userInteractionEnabled = true;
        
        // Initializes the delegate of the picker to the view controller
        picker.delegate = self
        
        // Makes the profile image circular 
        self.uploadedImage.layer.cornerRadius = 10.0;

        
        // Adds a border to the circular image 
        self.uploadedImage.layer.borderWidth = 5.0;
        self.uploadedImage.layer.borderColor = UIColor.grayColor().CGColor;

    }
    
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        
        defaults.setObject(info[UIImagePickerControllerOriginalImage] as? UIImage, forKey: Constants.UserKeys.profileImageKey);
        uploadedImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        uploadedImage.frame = CGRectMake(100, 150, 150, 150);
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("Picker cancel.");
        
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
            popover?.presentPopoverFromRect(uploadedImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in})
        uploadedImage.image = image
    }

}
