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
        static let usernameKey = "usernameKey"
        static let nameKey = "nameKey"
        static let interestsKey = "interestsKey"
        static let experienceKey = "experienceKey"
        static let profileImageKey = "profileImageKey"
        static let aboutKey = "aboutKey"
        static let distanceKey = "distanceKey"
        static let longitudeKey = "longitudeKey"
        static let latitudeKey = "latitudeKey"
        static let profilesInRangeKey = "profilesInRangeKey"
        static let conversationsInRangeKey = "conversationsInRange"
        static let lookingForKey = "lookingForKey"
        static let availableKey = "availableKey"
        static let emailKey = "emailKey"
        static let greetingKey = "greetingKey"
    }
    struct TempKeys {
        static let fromNew = "fromNew"
        static let notificationPayloadKey = "notificationPayloadKey"
    }
    struct ConstantStrings {
        static let greetingMessage = "I saw you were in the same area as me. Would you like to meet up some time?"
        static let aboutText = "A sentence or two illustrating what you're about. Who are you in a nutshell?"
        static let loadText = "Please wait while we find other Novas nearby..."
        static let feedbackText = "Write your feedback or support request here. Try to be specific so we can address the issue as precisely as possible!"
        static let feedbackAlertText = "We'll do our best to reply to support any requests by email and squash any bugs found. To submit further feedback, simply fill out the form + resubmit!"
        static let feedbackEmptyText = "Please fill out the form."
        static let placeHolderAbout = "A sentence or two illustrating what you're about. Who are you in a nutshell?"
        static let placeHolderDesc = "More info..."
    }
    struct SelectedUserKeys {
        static let selectedUsernameKey = "selectedUsernameKey"
        static let selectedAboutKey = "selectedAboutKey"
        static let selectedIdKey = "selectedIdKey"
        static let selectedNameKey = "selectedNameKey"
        static let selectedInterestsKey = "selectedInterestsKey"
        static let selectedExperienceKey = "selectedExperienceKey"
        static let selectedLookingForKey = "selectedLookingForKey"
        static let selectedProfileImageKey = "selectedprofileImageKey"
        static let selectedDistanceKey = "selectedDistanceKey"
        static let selectedAvailableKey = "selectedAvaiableKey"
        
    }
    struct ScreenDimensions {
        static let screenHeight = UIScreen.mainScreen().bounds.size.height
        static let screenWidth = UIScreen.mainScreen().bounds.size.width
        static let IPHONE_4_HEIGHT:CGFloat = 480
        static let IPHONE_5_HEIGHT:CGFloat = 568
        static let IPHONE_6_HEIGHT:CGFloat = 667
        static let IPHONE_6_PLUS_HEIGHT:CGFloat = 736
    }
    
    static let XXSMALL_FONT_SIZE:CGFloat = 10.0
    static let XSMALL_FONT_SIZE:CGFloat = 12.0
    static let SMALL_FONT_SIZE:CGFloat = 14.0
    static let MEDIUM_FONT_SIZE:CGFloat = 16.0
    static let LARGE_FONT_SIZE:CGFloat = 18.0
    static let XLARGE_FONT_SIZE:CGFloat = 20.0
    
    static let DISCOVERY_RADIUS = 35
    static let MAX_NUM_INTERESTS = 3

}
