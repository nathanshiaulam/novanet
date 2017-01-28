//
//  ProfilePersistencyManager.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit

class ProfilePersistencyManager: NSObject {
    var profileList: [String : Profile]!
    
    override init() {
        profileList = [String : Profile]()
    }
    
    public func getProfList() -> [String : Profile]{
        return profileList
    }
    
    public func getProfWithId(id: String) -> Profile? {
        if profileList[id] != nil {
            return profileList[id]
        }
        return nil
    }
    
    public func setProfile(id: String, prof: Profile) {
        if profileList[id] != nil {
            profileList.updateValue(prof, forKey: id)
        }
    }
    
    public func addProfile(id: String, prof: Profile) {
        profileList[id] = prof
    }
}
