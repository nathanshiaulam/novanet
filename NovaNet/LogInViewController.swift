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


class LogInViewController: UIViewController {

    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginFunction(sender: UIButton) {
        userLogin(usernameField.text, password: passwordField.text);
    }
    
    override func viewDidLayoutSubviews() {
        let borderName = CALayer();
        let widthName = CGFloat(2.0);
        borderName.borderColor = UIColor.darkGrayColor().CGColor;
        borderName.frame = CGRect(x: 0, y: usernameField.frame.size.height - widthName, width:  usernameField.frame.size.width, height: usernameField.frame.size.height);
        
        borderName.borderWidth = widthName;
        
        let borderPass = CALayer();
        let widthPass = CGFloat(2.0);
        borderPass.borderColor = UIColor.darkGrayColor().CGColor;
        borderPass.frame = CGRect(x: 0, y: usernameField.frame.size.height - widthPass, width:  usernameField.frame.size.width, height: usernameField.frame.size.height);
        
        borderPass.borderWidth = widthPass;
        
        usernameField.layer.addSublayer(borderName)
        usernameField.layer.masksToBounds = true
        
        passwordField.layer.addSublayer(borderPass);
        passwordField.layer.masksToBounds = true
        
    }
    
    func userLogin(username: String, password:String) {
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        var usernameLen = count(username);
        var passwordLen = count(password);
        
        if (usernameLen == 0 || passwordLen == 0) {
            var alert = UIAlertController(title: "Submission Failure", message: "Invalid username or password", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user, error) -> Void in
            if (user != nil) {
                defaults.setObject(self.usernameField.text, forKey: Constants.UserKeys.usernameKey);
                
                var query = PFQuery(className:"Profile");
                var currentID = PFUser.currentUser()!.objectId;
                query.whereKey("ID", equalTo:currentID!);
                
                query.getFirstObjectInBackgroundWithBlock {
                    (profile: PFObject?, error: NSError?) -> Void in
                    if error != nil || profile == nil {
                        println(error);
                    } else if let profile = profile {
                        defaults.setObject(profile["Name"], forKey: Constants.UserKeys.nameKey);
                        defaults.setObject(profile["Interests"], forKey: Constants.UserKeys.interestsKey);
                        defaults.setObject(profile["Background"], forKey: Constants.UserKeys.backgroundKey);
                        defaults.setObject(profile["Goals"], forKey: Constants.UserKeys.goalsKey);
                        defaults.setObject(profile["Distance"], forKey: Constants.UserKeys.distanceKey);
                        defaults.setObject(profile["Available"], forKey: Constants.UserKeys.availableKey);
                        
                        let userImageFile = profile["Image"] as! PFFile;
                        userImageFile.getDataInBackgroundWithBlock {
                            (imageData, error) -> Void in
                            if (error == nil) {
                                var image = UIImage(data:imageData!);
                                self.saveImage(image!);
                            }
                            else {
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
    func dismissToHomePage() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var usernamePlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        var passwordPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        
        usernameField.attributedPlaceholder = usernamePlaceholder;
        passwordField.attributedPlaceholder = passwordPlaceholder;
        
        usernameField.layer.cornerRadius = 0;
        passwordField.layer.cornerRadius = 0;
        passwordField.secureTextEntry = true;
        
        usernameField.borderStyle = UITextBorderStyle.None;
        usernameField.backgroundColor = UIColor.clearColor();
        var usernameFieldPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        usernameField.attributedPlaceholder = usernameFieldPlaceholder;
        usernameField.textColor = UIColor.whiteColor();
        
        passwordField.borderStyle = UITextBorderStyle.None;
        passwordField.backgroundColor = UIColor.clearColor();
        var passwordFieldPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.whiteColor();
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissToHomePage", name: "dismissToHomePage", object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
