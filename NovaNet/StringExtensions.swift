//
//  StringExtensions.swift
//  NovaNet
//
//  Created by Nathan Lam on 1/28/17.
//  Copyright © 2017 Nova. All rights reserved.
//

import Foundation

extension String {
    var length: Int {
        return self.characters.count
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func swapIfEmpty(replace: String) -> String {
        if self == nil {
            return replace
        }
        return self.trimmed.length == 0 ? replace : self.trimmed
    }
}
