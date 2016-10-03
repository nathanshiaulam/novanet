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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class NetworkManager: NSObject {
    let defaults:UserDefaults = UserDefaults.standard;
    
    static func userLoggedIn() -> Bool{
        let currentUser = PFUser.current()
        if ((currentUser) != nil) {
            return true
        }
        return false
    }
    
    func onboardingComplete() {
        let query = PFQuery(className:"Profile");
        let currentID = PFUser.current()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        query.getFirstObjectInBackground {
            (profile: PFObject?, error: NSError?) -> Void in
            if (error != nil || profile == nil) {
                print(error);
            } else if let profile = profile {
                profile["New"] = false;
                profile.saveInBackground();
            }
        }
    }
    
    func updateObjectWithName(_ name: String, profileFields: Dictionary<String, AnyObject>, dataStoreFields: Dictionary<String, Any>, segueType: String, sender: UIViewController) {
        let query = PFQuery(className: name);
        let currentID = PFUser.current()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        query.getFirstObjectInBackground {
            (object: PFObject?, error: NSError?) -> Void in
            if (object == nil || error != nil) {
                print(error);
            } else if let object = object{
                
                for (key, item) in profileFields {
                    object[key] = item;
                }
                object.saveInBackground {
                    (success, error) -> Void in
                    if (success) {
                        if (segueType == "POP") {
                            sender.navigationController?.popViewController(animated: true);
                        } else if (segueType == "DISMISS") {
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func createProfile() {
        let newProfile = PFObject(className: "Profile");
        newProfile["ID"] = PFUser.current()!.objectId;
        newProfile["New"] = true;
        newProfile["Greeting"] = Constants.ConstantStrings.greetingMessage;
        
        newProfile.saveInBackground();
    }
    
    // Creates user with information
    func createUser(_ email: String, password: String, confPassword: String, sender: SignUpViewController) {
        let newUser = PFUser();
        
        // Ensures that fields are not equal
        if (email.characters.count == 0 || password.characters.count == 0 || confPassword.characters.count == 0) {
            let alert = UIAlertController(title: "Submission Failure", message: "Invalid password or email", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
            sender.present(alert, animated: true, completion: nil);
            return;
        }
        
        if (password != confPassword) {
            let alert = UIAlertController(title: "Submission Failure", message: "Your passwords don't match!", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
            sender.present(alert, animated: true, completion: nil);
            return;
        }
        
        // Sets attributes of new users
        newUser.email = email;
        newUser.password = password;
        newUser.username = email;

        
        defaults.set(email, forKey: Constants.UserKeys.usernameKey)
        defaults.set(PFUser.current()?.email, forKey: Constants.UserKeys.emailKey)
        defaults.set(25, forKey: Constants.UserKeys.distanceKey)
        defaults.set(true, forKey: Constants.TempKeys.fromNew)
        defaults.set(Constants.ConstantStrings.greetingMessage, forKey: Constants.UserKeys.greetingKey)

        defaults.set(email, forKey: Constants.UserKeys.emailKey);
        
        newUser.signUpInBackground {
            (succeeded, error) -> Void in
            if (error == nil) {
                
                // Sets up basic properites for uses
                sender.setUpInstallations();
                self.createProfile();
                
                sender.dismiss(animated: true, completion: { () -> Void in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissToHomePage"), object: nil);
                })
                sender.dismiss(animated: true, completion: nil);
            } else {
                // Show the errorString somewhere and let the user try again.
                let errorString = error!.userInfo["error"] as! NSString;
                let alert = UIAlertController(title: "Submission Failure", message: errorString as String, preferredStyle: UIAlertControllerStyle.alert);
                alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil));
                sender.present(alert, animated: true, completion: nil);
            }
        }
    }
    
    func userLogin(_ email: String, password:String, vc: LogInViewController) {
        let emailLen = email.characters.count;
        let passwordLen = password.characters.count;

        // If either the username or password field are empty, alert user
        if (emailLen == 0 || passwordLen == 0) {
            let alert = UIAlertController(title: "Submission Failure", message: "Invalid email or password", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
            vc.present(alert, animated: true, completion: nil);
            return;
        }
        
        
        let userQuery = PFQuery(className: "_User");
        userQuery.whereKey("email", equalTo: email);
        userQuery.getFirstObjectInBackground {
            (user: AnyObject?, error: NSError?) -> Void in
            if (error != nil || user == nil) {
                let alert = UIAlertController(title: "Submission Failure", message: "Invalid email or password", preferredStyle: UIAlertControllerStyle.alert);
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
                vc.present(alert, animated: true, completion: nil);
                return;
            } else {
                // Log in function and set up datastore
                let username = user!.username;
                PFUser.logInWithUsername(inBackground: username!!, password: password) {
                    (success, error) -> Void in
                    if (error == nil && user != nil) {
                        vc.defaults.set(vc.usernameField.text, forKey: Constants.UserKeys.usernameKey);
                        
                        let query = PFQuery(className:"Profile");
                        let currentID = PFUser.current()!.objectId;
                        query.whereKey("ID", equalTo:currentID!);
                        
                        query.getFirstObjectInBackground {
                            (profile: PFObject?, error: NSError?) -> Void in
                            if error != nil || profile == nil {
                                print(error);
                            } else if let profile = profile {
                                // Notes that the user is online
                                profile["Online"] = true;
                                profile["Available"] = true;

                                // Sets up local datastore
                                self.defaults.set(profile["Name"], forKey: Constants.UserKeys.nameKey)
                                self.defaults.set(PFUser.current()!.email, forKey: Constants.UserKeys.emailKey)
                                self.defaults.set(profile["InterestsList"], forKey: Constants.UserKeys.interestsKey)
                                self.defaults.set(profile["About"], forKey: Constants.UserKeys.aboutKey)
                                self.defaults.set(profile["Experience"], forKey: Constants.UserKeys.experienceKey)
                                self.defaults.set(profile["Looking"], forKey: Constants.UserKeys.lookingForKey)
                                self.defaults.set(profile["Distance"], forKey: Constants.UserKeys.distanceKey)
                                self.defaults.set(profile["Available"], forKey: Constants.UserKeys.availableKey)
                                self.defaults.set(profile["New"], forKey: Constants.TempKeys.fromNew)
                                self.defaults.set(profile["Greeting"], forKey: Constants.UserKeys.greetingKey)
                                
                                profile.saveInBackground()
                                // Sets installation so that push notifications get sent to this device
                                let installation = PFInstallation.current()
                                installation["user"] = PFUser.current()
                                installation.saveInBackground()
                                
                                // Stores image in local data store and refreshes image from Parse
                                let userImageFile = profile["Image"] as! PFFile;
                                userImageFile.getDataInBackground {
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
                        vc.dismiss(animated: true, completion: nil);
                    }
                    else {
                        let alert = UIAlertController(title: "Log-In Failed", message: "Username or password is incorrect", preferredStyle: UIAlertControllerStyle.alert);
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
                        vc.present(alert, animated: true, completion: nil);
                    }
                }
            }
        }
    }
    
    func sendResetPasswordEmail(_ emailField : UITextField!, sender: UIViewController) {
        if (emailField.text?.characters.count > 0) {
            PFUser.requestPasswordResetForEmail(inBackground: emailField.text!, block: {
                (success, error) -> Void in
                if (success) {
                    let alert = UIAlertController(title: "E-mail Sent!", message: "Check your inbox to reset your password.", preferredStyle: UIAlertControllerStyle.alert);
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        sender.navigationController?.dismiss(animated: true, completion: nil);
                    }
                    alert.addAction(okAction);
                    sender.present(alert, animated: true, completion: nil);
                    return;
                    
                } else {
                    
                }
            });
        } else {
            let alert = UIAlertController(title: "Submission Failure", message: "Invalid email or password", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
            sender.present(alert, animated: true, completion: nil);
            return;
        }

    }
    
    


    
}
