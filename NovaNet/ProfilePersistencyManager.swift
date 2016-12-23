//
//  ProfilePersistencyManager.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit

class ProfilePersistencyManager: NSObject {
    var userProfile: Profile! // Cache for own profile
    var profileLists: [Profile]!
    
    override init() {
        profileLists = [Profile]()
    }
    
    public func setProfile(prof: Profile) {
        userProfile = prof
    }
    
    public func getUserProfile() -> Profile {
        return userProfile
    }
}
