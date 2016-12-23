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
    
    // Cache own profile
    // Update other profiles when profiles are loaded
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
    
    public func create(prof: Profile)
    {
        persistencyManager.setProfile(prof: prof)
        apiClient.createObject(table: TABLES.PROFILES, dict: prof.prof_dictRepresentation())
    }
    
    public func getProfileById(id: String, completion: @escaping(Profile) -> Void) {
        // Returns cached value if own profile
        if id == persistencyManager.getUserProfile().getId() {
            completion(persistencyManager.getUserProfile())
            return
        }
        getProfileBy(key: COLS.PROFILE.ID, val: id as AnyObject, completion: completion)
    }
    
    public func getProfileByEmail(email: String, completion: @escaping(Profile) -> Void) {
        // Returns cached value if own profile
        if email == persistencyManager.getUserProfile().getEmail() {
            return completion(persistencyManager.getUserProfile())
        }
        getProfileBy(key: COLS.PROFILE.EMAIL, val: email as AnyObject, completion: completion)
    }
    
    private func getProfileBy(key: String, val: AnyObject, completion: @escaping(Profile) -> Void) {
        apiClient.fetchObject(
            table: TABLES.PROFILES,
            key: key,
            val: val,
            cols: COLS.PROFILE.COL_LIST,
            completion: constructProfile,
            setter: completion as! (AnyObject) -> Void)
    }
    
    public func editProfileById(id: String, dict: [String: AnyObject]) {
        let editedProfile = Profile.constructProfile(dict: dict)
        self.persistencyManager.setProfile(prof: editedProfile)
        editProfileBy(key: COLS.PROFILE.ID, val: id as AnyObject, dict: dict)
    }
    
    public func editProfileByEmail(email: String, dict: [String:AnyObject]) {
        let editedProfile = Profile.constructProfile(dict: dict)
        self.persistencyManager.setProfile(prof: editedProfile)
        editProfileBy(key: COLS.PROFILE.EMAIL, val: email as AnyObject, dict: dict)
    }
    
    private func editProfileBy(key: String, val: AnyObject, dict: [String:AnyObject]) {
        apiClient.setObject(
            table: TABLES.PROFILES,
            key: key,
            val: val,
            dict: dict)
    }
    
    private func constructProfile(dict: [String:AnyObject], completion: (Profile) -> Void) {
        let prof:Profile = Profile.constructProfile(dict: dict)
        completion(prof)
    }
}
