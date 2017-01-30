/*
 * NovaNet
 * UserPersistencyManager.swift
 *
 * Singleton class to store basic user
 * information and user-profile
 *
 * Created by Nathan Lam on 12/29/16.
 * Copyright © 2016 Nova. All rights reserved.
 */
//  UserPersistencyManager.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/29/16.
//
//

import UIKit

class UserPersistencyManager: NSObject {
    
    var id: String!
    var userProfile: Profile!
    
    public func createUser(username: String) {
        Constants.defaults.set(username, forKey: Constants.UserKeys.usernameKey)
        Constants.defaults.set(username, forKey: Constants.UserKeys.emailKey)
        Constants.defaults.set(true, forKey: Constants.TempKeys.fromNew)
    }
    
    public func getId() -> String {
        return id
    }
    
    public func getProfile() -> Profile {
        return userProfile
    }
    
    public func setId(id: String) {
        self.id = id
    }
    
    public func clearDefaults() {
        let dict = Constants.defaults.dictionaryRepresentation()
        for key in dict.keys {
            Constants.defaults.removeObject(forKey: key.debugDescription)
        }
        Constants.defaults.synchronize()
    }
    
    func setImage(_ image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let relativePath = "image_\(Date.timeIntervalSinceReferenceDate).jpg"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let path = paths[0];
        let fullPath = "\(path )/\(relativePath)"
        
        FileManager.default.createFile(atPath: fullPath, contents: imageData, attributes: nil)
        Constants.defaults.set(relativePath, forKey: Constants.UserKeys.profileImageKey)
    }

    
    public func setProfDefaults(prof: Profile) {
        self.userProfile = prof
        
        // TODO: Remove dependency on nsuserdefaults
        if prof.getImage() != nil {
            setImage(prof.getImage()!)
        }
        Constants.defaults.set(prof.getName(), forKey: Constants.UserKeys.nameKey)
        Constants.defaults.set(prof.getEmail(), forKey: Constants.UserKeys.emailKey)
        Constants.defaults.set(prof.getEmail(), forKey: Constants.UserKeys.usernameKey)
        Constants.defaults.set(prof.getInterests(), forKey: Constants.UserKeys.interestsKey)
        Constants.defaults.set(prof.getAbout(), forKey: Constants.UserKeys.aboutKey)
        Constants.defaults.set(prof.getExp(), forKey: Constants.UserKeys.experienceKey)
        Constants.defaults.set(prof.getSeeking(), forKey: Constants.UserKeys.lookingForKey)
        Constants.defaults.set(Constants.DISCOVERY_RADIUS, forKey: Constants.UserKeys.distanceKey)
        Constants.defaults.set(prof.getAvailability(), forKey: Constants.UserKeys.availableKey)
        Constants.defaults.set(prof.getNew(), forKey: Constants.TempKeys.fromNew)
        Constants.defaults.set(prof.getGreeting(), forKey: Constants.UserKeys.greetingKey)
    }
    
}
