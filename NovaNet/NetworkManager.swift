//
//  NetworkManager.swift
//  NovaNet
//
//  Created by Nathan Lam on 10/24/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse


class NetworkManager: NSObject {
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    static func userLoggedIn() -> Bool{
        let currentUser = PFUser.currentUser()
        if ((currentUser) != nil) {
            return true
        }
        return false
    }
    
    func onboardingComplete() {
        let query = PFQuery(className:"Profile");
        let currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if (error != nil || profile == nil) {
                print(error);
            } else if let profile = profile {
                profile["New"] = false;
                profile.saveInBackground();
            }
        }
    }
    
    func updateObjectWithName(name: String, profileFields: Dictionary<String, AnyObject>, dataStoreFields: Dictionary<String, Any>, segueType: String, sender: UIViewController) {
        let query = PFQuery(className: name);
        let currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if (object == nil || error != nil) {
                print(error);
            } else if let object = object{
                
                for (key, item) in profileFields {
                    object[key] = item;
                }
                object.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                        if (segueType == "POP") {
                            sender.navigationController?.popViewControllerAnimated(true);
                        } else if (segueType == "DISMISS") {
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func createProfile() {
        let newProfile = PFObject(className: "Profile");
        newProfile["ID"] = PFUser.currentUser()!.objectId;
        newProfile["New"] = true;
        newProfile["Greeting"] = Constants.ConstantStrings.greetingMessage;
        
        newProfile.saveInBackground();
    }
    
    // Creates user with information
    func createUser(email: String, password: String, confPassword: String, sender: SignUpViewController) {
        let newUser = PFUser();
        
        // Ensures that fields are not equal
        if (email.characters.count == 0 || password.characters.count == 0 || confPassword.characters.count == 0) {
            let alert = UIAlertController(title: "Submission Failure", message: "Invalid password or email", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            sender.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        if (password != confPassword) {
            let alert = UIAlertController(title: "Submission Failure", message: "Your passwords don't match!", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            sender.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        // Sets attributes of new users
        newUser.email = email;
        newUser.password = password;
        newUser.username = email;

        
        defaults.setObject(email, forKey: Constants.UserKeys.usernameKey)
        defaults.setObject(PFUser.currentUser()?.email, forKey: Constants.UserKeys.emailKey)
        defaults.setObject(25, forKey: Constants.UserKeys.distanceKey)
        defaults.setObject(true, forKey: Constants.TempKeys.fromNew)
        defaults.setObject(Constants.ConstantStrings.greetingMessage, forKey: Constants.UserKeys.greetingKey)

        defaults.setObject(email, forKey: Constants.UserKeys.emailKey);
        
        newUser.signUpInBackgroundWithBlock {
            (succeeded, error) -> Void in
            if (error == nil) {
                
                // Sets up basic properites for uses
                sender.setUpInstallations();
                self.createProfile();
                
                sender.dismissViewControllerAnimated(true, completion: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("dismissToHomePage", object: nil);
                })
                sender.dismissViewControllerAnimated(true, completion: nil);
            } else {
                // Show the errorString somewhere and let the user try again.
                let errorString = error!.userInfo["error"] as! NSString;
                let alert = UIAlertController(title: "Submission Failure", message: errorString as String, preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: nil));
                sender.presentViewController(alert, animated: true, completion: nil);
            }
        }
    }
    
    func userLogin(email: String, password:String, vc: LogInViewController) {
        let emailLen = email.characters.count;
        let passwordLen = password.characters.count;

        // If either the username or password field are empty, alert user
        if (emailLen == 0 || passwordLen == 0) {
            let alert = UIAlertController(title: "Submission Failure", message: "Invalid email or password", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            vc.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        
        let userQuery = PFQuery(className: "_User");
        userQuery.whereKey("email", equalTo: email);
        userQuery.getFirstObjectInBackgroundWithBlock {
            (user: AnyObject?, error: NSError?) -> Void in
            if (error != nil || user == nil) {
                print(error);
            } else {
                // Log in function and set up datastore
                let username = user!.username;
                PFUser.logInWithUsernameInBackground(username!!, password: password) {
                    (success, error) -> Void in
                    if (error == nil && user != nil) {
                        vc.defaults.setObject(vc.usernameField.text, forKey: Constants.UserKeys.usernameKey);
                        
                        let query = PFQuery(className:"Profile");
                        let currentID = PFUser.currentUser()!.objectId;
                        query.whereKey("ID", equalTo:currentID!);
                        
                        query.getFirstObjectInBackgroundWithBlock {
                            (profile: PFObject?, error: NSError?) -> Void in
                            if error != nil || profile == nil {
                                print(error);
                            } else if let profile = profile {
                                // Notes that the user is online
                                profile["Online"] = true;
                                profile["Available"] = true;

                                // Sets up local datastore
                                self.defaults.setObject(profile["Name"], forKey: Constants.UserKeys.nameKey)
                                self.defaults.setObject(PFUser.currentUser()!.email, forKey: Constants.UserKeys.emailKey)
                                self.defaults.setObject(profile["InterestsList"], forKey: Constants.UserKeys.interestsKey)
                                self.defaults.setObject(profile["About"], forKey: Constants.UserKeys.aboutKey)
                                self.defaults.setObject(profile["Experience"], forKey: Constants.UserKeys.experienceKey)
                                self.defaults.setObject(profile["Looking"], forKey: Constants.UserKeys.lookingForKey)
                                self.defaults.setObject(profile["Distance"], forKey: Constants.UserKeys.distanceKey)
                                self.defaults.setObject(profile["Available"], forKey: Constants.UserKeys.availableKey)
                                self.defaults.setObject(profile["New"], forKey: Constants.TempKeys.fromNew)
                                self.defaults.setObject(profile["Greeting"], forKey: Constants.UserKeys.greetingKey)
                                
                                profile.saveInBackground()
                                // Sets installation so that push notifications get sent to this device
                                let installation = PFInstallation.currentInstallation()
                                installation["user"] = PFUser.currentUser()
                                installation.saveInBackground()
                                
                                // Stores image in local data store and refreshes image from Parse
                                let userImageFile = profile["Image"] as! PFFile;
                                userImageFile.getDataInBackgroundWithBlock {
                                    (imageData, error) -> Void in
                                    if (error == nil) {
                                        let image = UIImage(data:imageData!);
                                        Utilities().saveImage(image!);
                                    }
                                    else {
                                        let placeHolder = UIImage(named: "selectImage");
                                        Utilities().saveImage(placeHolder!);
                                        print(error);
                                    }
                                }
                                
                            }
                        }
                        vc.dismissViewControllerAnimated(true, completion: nil);
                    }
                    else {
                        let alert = UIAlertController(title: "Log-In Failed", message: "Username or password is incorrect", preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
                        vc.presentViewController(alert, animated: true, completion: nil);
                    }
                }
            }
        }
    }
    
    func sendResetPasswordEmail(emailField : UITextField!, sender: UIViewController) {
        if (emailField.text?.characters.count > 0) {
            PFUser.requestPasswordResetForEmailInBackground(emailField.text!, block: {
                (success, error) -> Void in
                if (success) {
                    let alert = UIAlertController(title: "E-mail Sent!", message: "Check your inbox to reset your password.", preferredStyle: UIAlertControllerStyle.Alert);
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        sender.navigationController?.dismissViewControllerAnimated(true, completion: nil);
                    }
                    alert.addAction(okAction);
                    sender.presentViewController(alert, animated: true, completion: nil);
                    return;
                    
                } else {
                    
                }
            });
        } else {
            let alert = UIAlertController(title: "Submission Failure", message: "Invalid email or password", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            sender.presentViewController(alert, animated: true, completion: nil);
            return;
        }

    }
    
    


    
}