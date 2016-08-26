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

class UploadPictureViewController: ViewController, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {
    
    var bot:CGFloat!;
    
    @IBOutlet weak var uploadedImage: UIImageView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var continueDistFromBot: NSLayoutConstraint!
    
    @IBOutlet weak var imageY: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var subWelcomeLabel: UILabel!
    
    @IBOutlet weak var finishButton: UIButton!
    // Finish button clicked, store all information and dismiss VC
    @IBAction func finishedOnboarding(sender: UIButton) {
        
        if uploadedImage.image != nil {
            // Indicate that the user has finished onboarding and can have access to app
            defaults.setObject(false, forKey: Constants.TempKeys.fromNew);
        
            // Saves image to local datastore and preps image to store into Parse
            
            uploadedImage.contentMode = .ScaleAspectFit
            Utilities().saveImage(uploadedImage.image!);
            
            NSNotificationCenter.defaultCenter().postNotificationName("selectProfileVC", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("backToHomeView", object: nil);
            
            NetworkManager().onboardingComplete()
            
            self.navigationController?.popToRootViewControllerAnimated(true);
        } else {
            let alert = UIAlertController(title: "Upload an Image", message: "Please upload an image first.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
    
    @IBAction func skipUpload(sender: AnyObject) {
        saveTempImage()
        NSNotificationCenter.defaultCenter().postNotificationName("selectProfileVC", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("backToHomeView", object: nil)
        NetworkManager().onboardingComplete()
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    // Prepares local data store and image picker
    let picker = UIImagePickerController();
    var popover:UIPopoverController? = nil;
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
 
    private func saveTempImage() {
        let tempImage = UIImageView(image: UIImage(named: "selectImage"))
        Utilities().saveImage(tempImage.image!)
    }
    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            welcomeLabel.font = welcomeLabel.font.fontWithSize(17.0);
            imageY.constant = -35;
            subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(14.0);
            imageHeight.constant = 160;
            imageWidth.constant = 160;
            buttonHeight.constant = 45;
            self.continueDistFromBot.constant = bot;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            welcomeLabel.font = welcomeLabel.font.fontWithSize(18.0);
            subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(14.0);
            imageHeight.constant = 190
            imageWidth.constant = 190
            imageY.constant = -20
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            welcomeLabel.font = welcomeLabel.font.fontWithSize(24.0);
            subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(18.0);
            imageHeight.constant = 250
            imageWidth.constant = 250
            return;
        }
    }

    // If image tapped, prompt user to upload or take photos
    func tappedImage() {
        let alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet);
        
        let galleryAction = UIAlertAction(title: "Upload a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallery()
        }
        let cameraAction = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        
        uploadedImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        Utilities().formatImage(uploadedImage);
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in})
        uploadedImage.image = image
        Utilities().formatImage(uploadedImage);
    }
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    override func viewDidLoad() {
        super.viewDidLoad();
        bot = self.continueDistFromBot.constant - 10;
        self.title = "2 of 2";
        // Initializes gesture recognizer
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UploadPictureViewController.tappedImage))
        tapGestureRecognizer.delegate = self;
        self.uploadedImage.addGestureRecognizer(tapGestureRecognizer);
        self.uploadedImage.userInteractionEnabled = true;
        // Initializes the delegate of the picker to the view controller
        picker.delegate = self
        finishButton.layer.cornerRadius = 5
        
    }
    override func viewDidLayoutSubviews() {
        manageiOSModelType();

    }
}
