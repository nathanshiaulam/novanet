//
//  LogInViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit

import Parse
import Bolts


class LogInViewController: UIViewController, UITextFieldDelegate {

    var bot:CGFloat!;

    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginFunction(sender: UIButton) {
        userLogin(usernameField.text, password: passwordField.text);
    }
    
    // Set up local data store
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    /*-------------------------------- CONSTRAINTS ------------------------------------*/
    
    @IBOutlet weak var signInHeight: NSLayoutConstraint!
    
    @IBOutlet weak var distFromSignInToBottom: NSLayoutConstraint!
    @IBOutlet weak var distFromLogoToText: NSLayoutConstraint!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var splashHorizontal: NSLayoutConstraint!
    @IBOutlet weak var splashBottom: NSLayoutConstraint!
    @IBOutlet weak var splashOtherHorizontal: NSLayoutConstraint!
    @IBOutlet weak var splashTop: NSLayoutConstraint!


    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    func userLogin(username: String, password:String) {
        var usernameLen = count(username);
        var passwordLen = count(password);
        
        // If either the username or password field are empty, alert user
        if (usernameLen == 0 || passwordLen == 0) {
            var alert = UIAlertController(title: "Submission Failure", message: "Invalid username or password", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        // Log in function and set up datastore
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user, error) -> Void in
            if (user != nil) {
                self.defaults.setObject(self.usernameField.text, forKey: Constants.UserKeys.usernameKey);
                
                var query = PFQuery(className:"Profile");
                var currentID = PFUser.currentUser()!.objectId;
                query.whereKey("ID", equalTo:currentID!);
                
                query.getFirstObjectInBackgroundWithBlock {
                    (profile: PFObject?, error: NSError?) -> Void in
                    if error != nil || profile == nil {
                        println(error);
                    } else if let profile = profile {
                        // Notes that the user is online
                        profile["Online"] = true;
                        
                        // Sets up local datastore
                        self.prepareDataStore(profile);
                        
                        // Sets installation so that push notifications get sent to this device
                        let installation = PFInstallation.currentInstallation()
                        installation["user"] = PFUser.currentUser()
                        installation.saveInBackground()
                        
                        // Stores image in local data store and refreshes image from Parse
                        let userImageFile = profile["Image"] as! PFFile;
                        userImageFile.getDataInBackgroundWithBlock {
                            (imageData, error) -> Void in
                            if (error == nil) {
                                var image = UIImage(data:imageData!);
                                self.saveImage(image!);
                            }
                            else {
                                let placeHolder = UIImage(named: "selectImage");
                                self.saveImage(placeHolder!);
                                println(error);
                            }
                        }
                        
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil);
            }
            else {
                var alert = UIAlertController(title: "Log-In Failed", message: "Username or password is incorrect", preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
                self.presentViewController(alert, animated: true, completion: nil);
            }
        }
    }
    
    func manageiOSModelType() {
        let modelName = UIDevice.currentDevice().modelName;
        
        switch modelName {
        case "iPhone 4s":
            signInHeight.constant = 50
            textFieldHeight.constant = 40
            distFromSignInToBottom.constant = bot - 10;
            return;
        case "iPhone 5":
            signInHeight.constant = 50
            textFieldHeight.constant = 50
            distFromSignInToBottom.constant = bot;
            return;
        case "iPhone 6":
            
            return; // Do nothing because designed on iPhone 6 viewport
        case "iPhone 6 Plus":
            splashHorizontal.constant = -20;
            splashOtherHorizontal.constant = -20;
            splashTop.constant = 0;
            return;
        default:
            return; // Do nothing
        }
    }

    // Sets up local datastore
    func prepareDataStore(profile: PFObject) {
        defaults.setObject(profile["Name"], forKey: Constants.UserKeys.nameKey);
        defaults.setObject(PFUser.currentUser()?.email, forKey: Constants.UserKeys.emailKey);
        defaults.setObject(profile["InterestsList"], forKey: Constants.UserKeys.interestsKey);
        defaults.setObject(profile["About"], forKey: Constants.UserKeys.aboutKey);
        defaults.setObject(profile["Experience"], forKey: Constants.UserKeys.experienceKey);
        defaults.setObject(profile["Looking"], forKey: Constants.UserKeys.lookingForKey);
        defaults.setObject(profile["Distance"], forKey: Constants.UserKeys.distanceKey);
        defaults.setObject(profile["Available"], forKey: Constants.UserKeys.availableKey);
    }
    
    // Removes keyboard when tap outside
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    // Helper methods to save images into local datastore from Parse
    func documentsPathForFileName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let path = paths[0] as! String;
        let fullPath = path.stringByAppendingPathComponent(name)
        
        return fullPath
    }
    func saveImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path = self.documentsPathForFileName(relativePath)
        imageData.writeToFile(path, atomically: true)
        NSUserDefaults.standardUserDefaults().setObject(relativePath, forKey: Constants.UserKeys.profileImageKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // Dismisses to home
    func dismissToHomePage() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // Moves to next field when hits enter
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameField) {
            passwordField.becomeFirstResponder();
        }
        else {
            self.userLogin(usernameField.text, password: passwordField.text);
            textField.resignFirstResponder();
        }
        return true;
    }
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    // Style all of the textfields to remove borders/add gray underline
//    override func viewDidLayoutSubviews() {
//        let borderName = CALayer();
//        let widthName = CGFloat(2.0);
//        borderName.borderColor = UIColor.darkGrayColor().CGColor;
//        borderName.frame = CGRect(x: 0, y: usernameField.frame.size.height - widthName, width:  usernameField.frame.size.width, height: usernameField.frame.size.height);
//        
//        borderName.borderWidth = widthName;
//        
//        let borderPass = CALayer();
//        let widthPass = CGFloat(2.0);
//        borderPass.borderColor = UIColor.darkGrayColor().CGColor;
//        borderPass.frame = CGRect(x: 0, y: usernameField.frame.size.height - widthPass, width:  usernameField.frame.size.width, height: usernameField.frame.size.height);
//        
//        borderPass.borderWidth = widthPass;
//        
//        usernameField.layer.addSublayer(borderName)
//        usernameField.layer.masksToBounds = true
//        
//        passwordField.layer.addSublayer(borderPass);
//        passwordField.layer.masksToBounds = true
//        
//    }
//    
    // Load in all of the textfield attributes
    override func viewDidLoad() {
        super.viewDidLoad()
        bot = distFromSignInToBottom.constant - 20;
        var usernamePlaceholder = NSAttributedString(string: "   Username", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        var passwordPlaceholder = NSAttributedString(string: "   Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        
        usernameField.attributedPlaceholder = usernamePlaceholder;
        passwordField.attributedPlaceholder = passwordPlaceholder;
        
        var userFrameRect = usernameField.frame;
        var passwordFrameRect = passwordField.frame;
        userFrameRect.size.height = 250;
        passwordFrameRect.size.height = 250;
        usernameField.frame = userFrameRect;
        passwordField.frame = passwordFrameRect;
        
//        usernameField.leftViewMode = UITextFieldViewMode.Always;
//        var userImageView = UIImageView(image: UIImage(named: "fika"));
//        userImageView.frame = CGRect(x: 50, y: 0, width: 20, height: 20)
//        userImageView.bounds.origin.x += 10.0
//        usernameField.leftView = userImageView
//        
//        passwordField.leftViewMode = UITextFieldViewMode.Always;
//        var passImageView = UIImageView(image: UIImage(named: "fika"));
//        passImageView.frame = CGRect(x: 50, y: 0, width: 20, height: 20)
//        passImageView.bounds.origin.x += 10.0
//        passwordField.leftView = passImageView
        
        usernameField.layer.cornerRadius = 15;
        passwordField.layer.cornerRadius = 15;
        passwordField.secureTextEntry = true;
        
        var usernameFieldPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        usernameField.attributedPlaceholder = usernameFieldPlaceholder;
        usernameField.textColor = UIColor.whiteColor();
        
        var passwordFieldPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.whiteColor();
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissToHomePage", name: "dismissToHomePage", object: nil);
    }
    
    override func viewDidLayoutSubviews() {
        manageiOSModelType();
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
