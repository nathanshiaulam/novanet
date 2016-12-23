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
    
    override init() {
        apiClient = APIClient()
        
        super.init()
    }
    
    class var sharedInstance: UserAPI {
        struct Singleton {
            static let instance = UserAPI()
        }
        return Singleton.instance
    }
    
    public func create(email: String, password: String, completion: @escaping() -> Void, error: @escaping(String) -> Void) {
        apiClient.createUser(email: email, password: password, completionHandler: completion, errorHandler: error)
        Mixpanel.sharedInstance().registerSuperProperties(["Email": email])
    }
    
    public func logOut() {
        
    }
    
    public func logIn() {
        
    }
}
