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
        static let experienceKey = "experienceKey";
        static let profileImageKey = "profileImageKey";
        static let websiteKey = "websiteKey";
        static let distanceKey = "distanceKey";
        static let longitudeKey = "longitudeKey";
        static let latitudeKey = "latitudeKey";
        static let profilesInRangeKey = "profilesInRangeKey";
        static let conversationsInRangeKey = "conversationsInRange";
        static let lookingForKey = "lookingForKey";
        static let availableKey = "availableKey";
    }
    struct TempKeys {
        static let fromNew = "fromNew";
        static let notificationPayloadKey = "notificationPayloadKey";
    }
    struct ConstantStrings {
        static let fikaText = "Hey! I thought your profile was pretty interesting and I'd love to meet for a chat sometime! When are you free?";
        static let loadText = "Please wait while we find other Novas nearby...";

    }
    struct SelectedUserKeys {
        static let selectedUsernameKey = "selectedUsernameKey";
        static let selectedIdKey = "selectedIdKey";
        static let selectedNameKey = "selectedNameKey";
        static let selectedInterestsKey = "selectedInterestsKey";
        static let selectedExperienceKey = "selectedExperienceKey";
        static let selectedLookingForKey = "selectedLookingForKey";
        static let selectedProfileImageKey = "selectedprofileImageKey";
        
    }
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
