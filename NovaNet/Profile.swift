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
    var exp: String!
    var email: String!
    var about: String!
    var seeking: String!
    var greeting: String!
    var interestsList: [String]!
    private var available: Bool!
    
    init(id: String,
         name: String,
         exp: String,
         email: String,
         about: String,
         seeking: String,
         greeting: String,
         interestsList: [String],
         available: Bool)
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
        self.available = available
    }
    
    override var description: String {
        return "name: \(name)" +
            "email: \(email)" +
            "id: \(id)" +
            "about: \(about)"
    }
}
