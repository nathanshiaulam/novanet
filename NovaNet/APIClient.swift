//
//  APIClient.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class APIClient: NSObject {
    
    // Returns key->val for a single object
    public func fetchObject(
        name: String,
        key: String,
        val: AnyObject,
        keys: [String],
        completion: @escaping(_: [String:AnyObject]) -> Void)
    {
        let query = PFQuery(className: name)
        query.whereKey(key, equalTo: val)
        query.getFirstObjectInBackground {
            (obj: PFObject?, error: Error?) -> Void in
            if let obj = obj {
                completion(self.getObjectVal(object: obj, keys: keys))
            }
        }
    }
    
    private func getObjectVal(object: PFObject, keys: [String]) -> [String : AnyObject] {
        var valueDict = [String:AnyObject]()
        for key in keys{
            if object[key] != nil {
                valueDict[key] = object.value(forKey: key) as AnyObject?
            }
        }
        return valueDict
    }
    
    
    // Returns a list of key->val mappings for a number of objects

    
}
