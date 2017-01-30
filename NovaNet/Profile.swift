//
//  Profile.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit

class Profile: NSObject {
    var id: String!
    var userId: String!
    var name: String!
    var exp: String?
    var email: String?
    var about: String?
    var seeking: String?
    var greeting: String?
    var interestsList: [String]?
    var last_active: Date?
    var image: UIImage?
    var available: Bool?
    var new: Bool?
    
    // Initializer when user creates account
    init(userId: String, greeting: String, email: String) {
        super.init()
        self.userId = userId
        self.greeting = greeting
        self.email = email
        self.last_active = Date()
        self.new = true
    }
    
    init(id: String,
         userId: String,
         name: String,
         exp: String,
         email: String,
         about: String,
         seeking: String,
         greeting: String,
         interestsList: [String])
    {
        super.init()
        self.id = id
        self.userId = userId
        self.name = name
        self.exp = exp
        self.email = email
        self.about = about
        self.seeking = seeking
        self.greeting = greeting
        self.interestsList = interestsList
        available = true
    }
    
    public func getId() -> String {
        return self.id
    }
    
    public func getUserId() -> String {
        return self.userId
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getExp() -> String? {
        return self.exp
    }
    
    public func getEmail() -> String? {
        return self.email
    }
    
    public func getAbout() -> String? {
        return self.about
    }
    
    public func getSeeking() -> String? {
        return self.seeking
    }
    
    public func getGreeting() -> String? {
        return self.greeting
    }
    
    public func getInterests() -> [String]? {
        return self.interestsList
    }
    
    public func getImage() -> UIImage? {
        return self.image
    }
    
    public func getAvailability() -> Bool? {
        return self.available
    }
    
    public func getNew() -> Bool? {
        return self.new
    }
    
    public func setId(id: String) {
        self.id = id
    }
    
    public func setUserId(userId: String) {
        self.userId = userId
    }
    
    public func setName(name: String) {
        self.name = name
    }
    
    public func setExp(experience: String) {
        self.exp = experience
    }
    
    public func setEmail(email: String) {
        self.email = email
    }
    
    public func setAbout(about: String) {
        self.about = about
    }
    
    public func setSeeking(seeking: String) {
        self.seeking = seeking
    }
    
    public func setGreeting(greeting: String) {
        self.greeting = greeting
    }
    
    public func setInterests(interests: [String]) {
        self.interestsList = interests
    }
    
    public func setImage(image: UIImage) {
        self.image = image
    }
    
    public func setAvailability(available: Bool) {
        self.available = available
    }
    
    public func setNew(new: Bool) {
        self.new = new
    }
    
    public static func constructProfile(dict: [String:AnyObject?]) -> Profile {
        let prof:Profile =  Profile(id: dict[COLS.PROFILE.ID] as! String,
                                    userId: dict[COLS.PROFILE.USER_ID] as! String,
                                    name: dict[COLS.PROFILE.NAME] as! String,
                                    exp: dict[COLS.PROFILE.EXP] as! String,
                                    email: dict[COLS.PROFILE.EMAIL] as! String,
                                    about: dict[COLS.PROFILE.ABOUT] as! String,
                                    seeking: dict[COLS.PROFILE.SEEKING] as! String,
                                    greeting: dict[COLS.PROFILE.GREETING] as! String,
                                    interestsList: dict[COLS.PROFILE.INTERESTS] as! [String])
        
        prof.setImage(image: dict[COLS.PROFILE.IMAGE] as! UIImage)
        prof.setNew(new: dict[COLS.PROFILE.NEW] as! Bool)
        prof.setAvailability(available: dict[COLS.PROFILE.AVAILABLE] as! Bool)
        return prof
    }
    
    override var description: String {
        return "name: \(name)" +
            "email: \(email)" +
            "id: \(id)" +
            "userId: \(userId)" +
            "about: \(about)"
    }
}
