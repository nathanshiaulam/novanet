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
    
    public func setProfile(prof: Profile) {
        self.userProfile = prof
        
        // TODO: Remove dependency on nsuserdefaults
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
