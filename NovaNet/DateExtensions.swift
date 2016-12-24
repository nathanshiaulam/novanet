//
//  DateExtensions.swift
//  
//
//  Created by Nathan Lam on 12/23/16.
//
//

import Foundation

extension DateFormatter {
    func standardFormatter() -> DateFormatter {
        let standardFormat = DateFormatter()
        standardFormat.dateFormat = "MM/dd/yyyy"
        return standardFormat
    }
}
