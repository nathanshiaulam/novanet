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
    @IBOutlet weak var takePhotoTableView: UITableView!

    // Finish button clicked, store all information and dismiss VC
    @IBAction func finishedOnboarding(sender: UIButton) {
        // Indicate that the user has finished onboarding and can have access to app
        defaults.setObject(false, forKey: Constants.TempKeys.fromNew);
        
        // Sets up profile query by username to load in image
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        // Saves image to local datastore and preps image to store into Parse
        saveImage(uploadedImage.image!);
        let pickedImage:UIImage = self.uploadedImage.image!;
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
    
    // Prepares local data store and image picker
    let picker = UIImagePickerController();
    var popover:UIPopoverController? = nil;
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/

    func formatImage(var profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }

    // Saves image into local data store
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
    
    // If image tapped, prompt user to upload or take photos
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
    // Opens gallery
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
    // Opens Camera
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
    

    
    /*-------------------------------- IMAGE PICKER DELEGATE METHODS ------------------------------------*/

    // Upload completion events
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        
        uploadedImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        println("Picker cancel.");
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in})
        uploadedImage.image = image
    }
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = "3 of 4";
        // Initializes gesture recognizer
        var tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedImage");
        tapGestureRecognizer.delegate = self;
        self.uploadedImage.addGestureRecognizer(tapGestureRecognizer);
        self.uploadedImage.userInteractionEnabled = true;
        formatImage(uploadedImage);
        
        // Initializes the delegate of the picker to the view controller
        picker.delegate = self
        
    }
}
