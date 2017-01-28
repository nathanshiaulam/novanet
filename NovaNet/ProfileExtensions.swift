//
//  ProfileExtensions.swift
//  
//
//  Created by Nathan Lam on 12/19/16.
//
//

import Foundation

extension Profile {
    func prof_dictRepresentation() -> ([String:AnyObject?]) {
        return [COLS.PROFILE.ID: id as AnyObject?,
                COLS.PROFILE.USER_ID: userId as AnyObject?,
                COLS.PROFILE.NAME: name as AnyObject?,
                COLS.PROFILE.EXP: exp as AnyObject,
                COLS.PROFILE.EMAIL: email as AnyObject,
                COLS.PROFILE.ABOUT: about as AnyObject,
                COLS.PROFILE.SEEKING: seeking as AnyObject,
                COLS.PROFILE.GREETING: greeting as AnyObject,
                COLS.PROFILE.INTERESTS: interestsList as AnyObject,
                COLS.PROFILE.LAST_ACTIVE: DateFormatter().standardFormatter().string(from: last_active!) as AnyObject]
    }
}
