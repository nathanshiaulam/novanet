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
//                    print(key);
                }
                object.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                        print("yes");
                        self.prepareDataStore(dataStoreFields);
                        if (segueType == "POP") {
                            sender.navigationController?.popViewControllerAnimated(true);
                        } else if (segueType == "DISMISS") {
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func prepareDataStore(dataStoreFields: Dictionary<String, Any>) {
        for (key, item) in dataStoreFields {
            print(key);
            defaults.setObject(item as? AnyObject, forKey: key);
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
    func createUser(username: String, password: String, email: String, sender: SignUpViewController) {
        let newUser = PFUser();
        
        // Ensures that fields are not equal
        if (username.characters.count == 0 || password.characters.count == 0 || email.characters.count == 0) {
            let alert = UIAlertController(title: "Submission Failure", message: "Invalid username, password, or email", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            sender.presentViewController(alert, animated: true, completion: nil);
            return;
        }
        
        // Sets attributes of new users
        newUser.email = email;
        newUser.password = password;
        newUser.username = username;
        
        let dataStoreFields:Dictionary<String, Any> = [
            Constants.UserKeys.usernameKey : username,
            Constants.UserKeys.emailKey : PFUser.currentUser()?.email,
            Constants.UserKeys.distanceKey : 25,
            Constants.TempKeys.fromNew : true,
            Constants.UserKeys.greetingKey : Constants.ConstantStrings.greetingMessage
        ]
        
        defaults.setObject(email, forKey: Constants.UserKeys.emailKey);
        
        newUser.signUpInBackgroundWithBlock {
            (succeeded, error) -> Void in
            if (error == nil) {
                
                // Sets up basic properites for uses
                sender.setUpInstallations();
                self.prepareDataStore(dataStoreFields);
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
                    if (user != nil) {
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
                                
                                // Sets up local datastore
                                let dataStoreFields:Dictionary<String, Any> = [
                                    Constants.UserKeys.nameKey : profile["Name"],
                                    Constants.UserKeys.emailKey : PFUser.currentUser()!.email,
                                    Constants.UserKeys.interestsKey : profile["InterestsList"],
                                    Constants.UserKeys.aboutKey : profile["About"],
                                    Constants.UserKeys.experienceKey : profile["Experience"],
                                    Constants.UserKeys.lookingForKey : profile["Looking"],
                                    Constants.UserKeys.distanceKey : profile["Distance"],
                                    Constants.UserKeys.availableKey : profile["Available"],
                                    Constants.TempKeys.fromNew : profile["New"],
                                    Constants.UserKeys.greetingKey : profile["Greeting"]
                                ];
                                
                                self.prepareDataStore(dataStoreFields);
                                
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