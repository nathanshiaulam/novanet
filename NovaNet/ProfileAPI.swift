//
//  ProfileAPI.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class ProfileAPI: NSObject {

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
    
    /**
     * Create's a profile for the current user and stores it
     * in the user cache.
     */
    public func create(prof: Profile)
    {
        persistencyManager.addProfile(id: prof.getUserId(), prof: prof)
        apiClient.createObject(table: TABLES.PROFILES, dict: prof.prof_dictRepresentation())
    }

    public func getProfileByUserId(userId: String, completion: @escaping(Profile) -> Void) {
        // Returns cached value if own profile
        let prof = persistencyManager.getProfWithId(id: userId)
        if prof != nil {
            completion(prof!)
            return
        }
        getProfileBy(key: COLS.PROFILE.USER_ID, val: userId as AnyObject, completion: completion)
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
    
    public func editProfileByUserId(
        userId: String,
        dict: [String: AnyObject?],
        completion: @escaping() -> Void)
    {
        let editedProfile = Profile.constructProfile(dict: dict)
        self.persistencyManager.setProfile(id: userId, prof: editedProfile)
        editProfileBy(key: COLS.PROFILE.USER_ID, val: userId as AnyObject, dict: dict, completion: completion)
    }

    private func editProfileBy(
        key: String,
        val: AnyObject,
        dict: [String:AnyObject?],
        completion: @escaping() -> Void)
    {
        apiClient.setObject(
            table: TABLES.PROFILES,
            key: key,
            val: val,
            dict: dict,
            completion: completion)
    }
    
    public func setAvailability(prof: Profile, available: Bool) {
        prof.setAvailability(available: available)
        ProfileAPI.sharedInstance.editProfileByUserId(userId: prof.getUserId(), dict: [COLS.PROFILE.AVAILABLE : true as AnyObject], completion: {})
    }
    
    private func constructProfile(dict: [String:AnyObject], completion: (Profile) -> Void) {
        let prof:Profile = Profile.constructProfile(dict: dict)
        completion(prof)
    }
}
