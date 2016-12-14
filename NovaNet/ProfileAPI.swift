//
//  ProfileAPI.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit

class ProfileAPI: NSObject {
    // Read in profile list from datastore and into persistency manager
    // Edit profile information
    // Create profile
    // Read in specific profile
    private let persistencyManager: ProfilePersistencyManager
    private let apiClient: APIClient
    
    override init() {
        persistencyManager = ProfilePersistencyManager()
        apiClient = APIClient()
        
        super.init()
    }
    
    class var sharedInstance: ProfileAPI {
        struct Singleton {
            static let instance = ProfileAPI()
        }
        return Singleton.instance
    }
    
    public func getProfileById(id: String, completion: (_: Profile)) {
    
    }
    
    public func getProfileByEmail(email: String, completion: (_:Profile)) {
    
    }
    
    public func getProfileListByIds(ids: [String], completion: (_: Profile)){
    
    }
    
    public func editProfileById(id: String, changeDict: [String: AnyObject]) {
        
    }
    
    public func editProfileByEmail(email: String, changeDict: [String: AnyObject]) {
        
    }
    
    public func createProfile(
        id: String,
        name: String,
        email: String,
        exp: String,
        about: String,
        seeking: String,
        greeting: String,
        interestsList: [String]) -> Profile?
    {
        
        return nil
    }
    
}
