//
//  Schema.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/17/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import Foundation

struct TABLES {
    static let PROFILES = "Profile"
    static let MEETUPS = "Meetup"
}

struct COLS {
    struct PROFILE {
        static let ID = "ID"
        static let NAME = "Name"
        static let EMAIL = "Email"
        static let ABOUT = "About"
        static let EXP = "Experience"
        static let SEEKING = "Looking"
        static let AVAILABLE = "Available"
        static let NEW = "New"
        static let GREETING = "Greeting"
        static let INTERESTS = "InterestsList"
        static let COL_LIST = [ID, NAME, EMAIL, ABOUT, EXP, SEEKING, AVAILABLE, GREETING, INTERESTS]
    }
}
