//
//  APIClient.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class APIClient: NSObject {
    
    // Searches table and filters by key -> val to return [col : val]
    // for a specific object in table
    
    // completion takes in a dictionary
    public func fetchObject(
        table: String,
        key: String,
        val: AnyObject,
        cols: [String],
        completion: @escaping(_: [String:AnyObject], _: (_:AnyObject) -> Void) -> Void,
        setter: @escaping(_:AnyObject) -> Void)
    {
        let query = PFQuery(className: table)
        query.whereKey(key, equalTo: val)
        query.getFirstObjectInBackground {
            (obj: PFObject?, error: Error?) -> Void in
            if let obj = obj {
                completion(self.convertToDict(object: obj, keys: cols), setter)
            }
        }
    }
    
    public func createObject(
        table: String,
        dict:[String:AnyObject?]) {
        let newObj = PFObject(className: table)
        for (k, v) in dict {
            if v != nil {
                newObj[k] = v
            }
        }
        newObj.saveInBackground()
    }
    
    public func setObject(
        table: String,
        key: String,
        val: AnyObject,
        dict:[String: AnyObject]) {
        
        let query = PFQuery(className: table)
        query.whereKey(key, equalTo: val)
        query.getFirstObjectInBackground {
            (obj: PFObject?, error: Error?) -> Void in
            if let obj = obj {
                for (k, v) in dict {
                    obj[k] = v
                }
                obj.saveInBackground()
            }
        }
    }
    
    public func createUser(
        email: String,
        password: String,
        completionHandler: @escaping() -> Void,
        errorHandler: @escaping(String) -> Void) {
        let newUser = PFUser();
        
        // Sets attributes of new users
        newUser.email = email;
        newUser.password = password;
        newUser.username = email;
        
        Constants.defaults.set(email, forKey: Constants.UserKeys.usernameKey)
        Constants.defaults.set(true, forKey: Constants.TempKeys.fromNew)
        Constants.defaults.set(email, forKey: Constants.UserKeys.emailKey);
        
        newUser.signUpInBackground {
            (succeeded, error) -> Void in
            if (succeeded) {
                completionHandler()
                self.installUser()
            } else {
                if let error = error as? NSError {
                    errorHandler(error.userInfo["error"] as! String)
                }
            }
        }
    }
    
    // Returns a list of key->val mappings for a number of objects
    private func convertToDict(object: PFObject, keys: [String]) -> [String : AnyObject] {
        var valueDict = [String:AnyObject]()
        for key in keys{
            if object[key] != nil {
                valueDict[key] = object.value(forKey: key) as AnyObject?
            }
        }
        return valueDict
    }
    
    // Sets up basic properites for uses
    private func installUser() {
        let installation = PFInstallation.current()
        installation["user"] = PFUser.current()
        installation.saveInBackground()
    }
}
