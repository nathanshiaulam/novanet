//
//  Constants.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse

struct Constants {
    struct UserKeys {
        static let usernameKey = "usernameKey";
        static let nameKey = "nameKey";
        static let interestsKey = "interestsKey";
        static let backgroundKey = "backgroundKey";
        static let profileImageKey = "profileImageKey";
        static let websiteKey = "websiteKey";
        static let distanceKey = "distanceKey";
        static let longitudeKey = "longitudeKey";
        static let latitudeKey = "latitudeKey";
        static let profilesInRangeKey = "profilesInRangeKey";
        static let goalsKey = "goalsKey";
        static let loadText = "Please wait while we find other Novas nearby...";
    }
    struct TempKeys {
        static let fromNew = "fromNew";
    }
    
    struct SelectedUserKeys {
        static let selectedUsernameKey = "selectedUsernameKey";
        static let selectedIdKey = "selectedIdKey";
        static let selectedNameKey = "selectedNameKey";
        static let selectedInterestsKey = "selectedInterestsKey";
        static let selectedBackgroundKey = "selectedBackgroundKey";
        static let selectedProfileImageKey = "selectedprofileImageKey";
        
    }
}
