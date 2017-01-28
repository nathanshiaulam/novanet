//
//  MeetupAPI.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit

class UserAPI: NSObject {
    private let apiClient: APIClient
    private let persistencyManager: UserPersistencyManager
    override init() {
        apiClient = APIClient()
        persistencyManager = UserPersistencyManager()
        super.init()
    }
    
    class var sharedInstance: UserAPI {
        struct Singleton {
            static let instance = UserAPI()
        }
        return Singleton.instance
    }
    
    public func create(
        username: String,
        password: String,
        completion: @escaping() -> Void,
        error: @escaping(String) -> Void)
    {
        persistencyManager.createUser(username: username)
        apiClient.createUser(username: username, password: password, completionHandler: completion, errorHandler: error)
        Mixpanel.sharedInstance().registerSuperProperties(["Email": username])
    }
    
    public func logIn(
        username: String,
        password: String,
        completion: @escaping() -> Void,
        error: @escaping(String) -> Void)
    {
        apiClient.logInUser(username: username, password: password, completionHandler: completion, errorHandler: error)
    }
    
    public func resetPassword(
        email: String,
        completion: @escaping() -> Void,
        error: @escaping(String) -> Void)
    {
        apiClient.resetPassword(email: email, completionHandler: completion, errorHandler: error)
    }
    
    public func logOut() {
        
    }
    
    public func setUserDefaults(id: String, prof: Profile) {
        persistencyManager.setProfile(prof: prof)
        persistencyManager.setId(id: id)
    }    
}
