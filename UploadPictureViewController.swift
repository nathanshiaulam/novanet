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
    @IBAction func finishedOnboarding(_ sender: UIButton) {
        
        if uploadedImage.image != nil {
            // Indicate that the user has finished onboarding and can have access to app
            defaults.set(false, forKey: Constants.TempKeys.fromNew);
        
            // Saves image to local datastore and preps image to store into Parse
            
            uploadedImage.contentMode = .scaleAspectFit
            Utilities().saveImage(uploadedImage.image!);
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "selectProfileVC"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "backToHomeView"), object: nil);
            
            NetworkManager().onboardingComplete()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setValues"), object: nil)

            self.navigationController?.popToRootViewController(animated: true);
        } else {
            let alert = UIAlertController(title: "Upload an Image", message: "Please upload an image first.", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    @IBAction func skipUpload(_ sender: AnyObject) {
        saveTempImage()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "selectProfileVC"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "backToHomeView"), object: nil)
        NetworkManager().onboardingComplete()
        self.navigationController?.popToRootViewController(animated: true);
    }
    // Prepares local data store and image picker
    let picker = UIImagePickerController();
    
    var popover:UIPopoverController? = nil;
    let defaults:UserDefaults = UserDefaults.standard;
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
 
    fileprivate func saveTempImage() {
        let tempImage = UIImageView(image: UIImage(named: "selectImage"))
        Utilities().saveImage(tempImage.image!)
    }
    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            welcomeLabel.font = welcomeLabel.font.withSize(17.0);
            imageY.constant = -35;
            subWelcomeLabel.font = subWelcomeLabel.font.withSize(14.0);
            imageHeight.constant = 160;
            imageWidth.constant = 160;
            buttonHeight.constant = 45;
            self.continueDistFromBot.constant = bot;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            welcomeLabel.font = welcomeLabel.font.withSize(18.0);
            subWelcomeLabel.font = subWelcomeLabel.font.withSize(14.0);
            imageHeight.constant = 190
            imageWidth.constant = 190
            imageY.constant = -20
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            welcomeLabel.font = welcomeLabel.font.withSize(24.0);
            subWelcomeLabel.font = subWelcomeLabel.font.withSize(18.0);
            imageHeight.constant = 250
            imageWidth.constant = 250
            return;
        }
    }

    // If image tapped, prompt user to upload or take photos
    func tappedImage() {
        let alert:UIAlertController = UIAlertController(title: "Choose an Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet);
        
        let galleryAction = UIAlertAction(title: "Upload a Photo", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                self.openGallery()
        }
        let cameraAction = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
        }
        // Add the actions
        alert.addAction(galleryAction);
        alert.addAction(cameraAction);
        alert.addAction(cancelAction);
        
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
    }
    // Opens gallery
    func openGallery() {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: picker);
            popover?.present(from: uploadedImage.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    // Opens Camera
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    

    
    /*-------------------------------- IMAGE PICKER DELEGATE METHODS ------------------------------------*/

    // Upload completion events
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil);
        
        uploadedImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        Utilities().formatImage(uploadedImage);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.dismiss(animated: true, completion: { () -> Void in})
        uploadedImage.image = image
        Utilities().formatImage(uploadedImage);
    }
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    override func viewDidLoad() {
        super.viewDidLoad();
        
        picker.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        bot = self.continueDistFromBot.constant - 10;
        self.title = "2 of 2";
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        // Initializes gesture recognizer
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UploadPictureViewController.tappedImage))
        tapGestureRecognizer.delegate = self;
        self.uploadedImage.addGestureRecognizer(tapGestureRecognizer);
        self.uploadedImage.isUserInteractionEnabled = true;
        // Initializes the delegate of the picker to the view controller
        picker.delegate = self
        finishButton.layer.cornerRadius = 5
        
    }
    override func viewDidLayoutSubviews() {
        manageiOSModelType();

    }
}
