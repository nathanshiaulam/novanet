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
    var name: String!
    var exp: String?
    var email: String?
    var about: String?
    var seeking: String?
    var greeting: String?
    var interestsList: [String]?
    private var available: Bool?
    private var new: Bool?
    
    init(id: String, greeting: String) {
        super.init()
        self.id = id
        self.greeting = greeting
        self.new = true
    }
    
    init(id: String,
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
    
    public func getEmail() -> String {
        return self.email!
    }
    
    public func setNew(new: Bool) {
        self.new = new
    }
    
    public func setAvailability(available: Bool) {
        self.available = available
    }
    
    public static func constructProfile(dict: [String:AnyObject?]) -> Profile {
        let prof:Profile =  Profile(id: dict[COLS.PROFILE.ID] as! String,
                       name: dict[COLS.PROFILE.NAME] as! String,
                       exp: dict[COLS.PROFILE.EXP] as! String,
                       email: dict[COLS.PROFILE.EMAIL] as! String,
                       about: dict[COLS.PROFILE.ABOUT] as! String,
                       seeking: dict[COLS.PROFILE.SEEKING] as! String,
                       greeting: dict[COLS.PROFILE.GREETING] as! String,
                       interestsList: dict[COLS.PROFILE.INTERESTS] as! [String])
        prof.setNew(new: dict[COLS.PROFILE.NEW] as! Bool)
        prof.setAvailability(available: dict[COLS.PROFILE.AVAILABLE] as! Bool)
        
        return prof
    }
    
    override var description: String {
        return "name: \(name)" +
            "email: \(email)" +
            "id: \(id)" +
            "about: \(about)"
    }
}
