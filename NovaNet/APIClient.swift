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
    
    /** 
     Searches table and filters by key -> val to return [col : val]
    */
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
                if let image = newObj[k] as? UIImage {
                    newObj[k] = writeImage(image: image)
                } else {
                    newObj[k] = v
                }
            }
        }
        newObj.saveInBackground()
    }
    
    public func setObject(
        table: String,
        key: String,
        val: AnyObject,
        dict:[String: AnyObject?],
        completion: @escaping() -> Void)
    {
        let query = PFQuery(className: table)
        query.whereKey(key, equalTo: val)
        query.getFirstObjectInBackground {
            (obj: PFObject?, error: Error?) -> Void in
            if let obj = obj {
                completion()
                for (k, v) in dict {
                    if let image = obj[k] as? UIImage {
                        obj[k] = self.writeImage(image: image)
                    } else {
                        obj[k] = v
                    }
                }
                obj.saveInBackground()
            }
        }
    }
    
    public func createUser(
        username: String,
        password: String,
        completionHandler: @escaping() -> Void,
        errorHandler: @escaping(String) -> Void) {
        let newUser = PFUser();
        
        // Sets attributes of new users
        newUser.email = username;
        newUser.username = username;
        newUser.password = password;

        newUser.signUpInBackground {
            (success, error) -> Void in
            if (success) {
                completionHandler()
                self.installUser()
            } else {
                if let error = error as? NSError {
                    errorHandler(error.userInfo["error"] as! String)
                }
            }
        }
    }
    
    public func logInUser(
        username: String,
        password: String,
        completionHandler: @escaping() -> Void,
        errorHandler: @escaping(String) -> Void) {
        PFUser.logInWithUsername(inBackground: username, password: password) {
            (success, error) -> Void in
            if (success != nil) {
                completionHandler()
                self.installUser()
            }
            else {
                if let error = error as? NSError {
                    errorHandler(error.userInfo["error"] as! String)
                }
            }
        }
    }
    
    public func logOut(completion: @escaping() -> Void) {
        PFUser.logOutInBackground(block: {
            (error) -> Void in
            if error != nil {
                completion()
            } else {
                print(error ?? <#default value#>)
            }
        })
    }
    
    public func resetPassword(
        email: String,
        completionHandler: @escaping() -> Void,
        errorHandler: @escaping(String) -> Void) {
        PFUser.requestPasswordResetForEmail(inBackground: email, block: {
            (success, error) -> Void in
            if (success) {
                completionHandler()
            } else {
                if let error = error as? NSError {
                    errorHandler(error.userInfo["error"] as! String)
                }
            }
        })
    }
    
    /** 
     Reads an image from a PFFile. Sets the image to the
     default image if none is found
     */
    private func readImage(data: PFFile, completion: @escaping(UIImage) -> Void) {
        var image:UIImage? = Constants.DEFAULT_IMAGE
        data.getDataInBackground {
            (imageData, error) -> Void in
            if error == nil {
                image = UIImage(data: imageData!)
            }
            completion(image!)
        }
    }
    
    /**
     Converts a UIImage into a PFFile in order to write
     into backend
     */
    private func writeImage(image: UIImage) -> PFFile {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        return PFFile(data: imageData!)
    }
    
    /** 
     Returns a list of key->val mappings for a number of objects
     If the object is a PFFile, assume it's an image and load it in
     
     TODO: Change!
     */
    private func convertToDict(object: PFObject, keys: [String]) -> [String : AnyObject] {
        var valueDict = [String:AnyObject]()
        for key in keys{
            if let data = object[key] as? PFFile {
                readImage(data: data, completion: {(image) -> Void in
                    valueDict[key] = image
                })
            }
            else if object[key] != nil {
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
