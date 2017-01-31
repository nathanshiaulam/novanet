//
//  UIViewExtensions.swift
//  NovaNet
//
//  Created by Nathan Lam on 1/30/17.
//  Copyright © 2017 Nova. All rights reserved.
//

import Foundation

extension UIView {
    func getLabelsInView() -> [UILabel] {
        var results = [UILabel]()
        for subview in self.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += subview.getLabelsInView()
            }
        }
        return results
    }
    
    func getFieldsInView() -> [UITextView] {
        var results = [UITextView]()
        for subview in self.subviews as [UIView] {
            if let labelView = subview as? UITextView {
                results += [labelView]
            } else {
                results += subview.getFieldsInView()
            }
        }
        return results
    }
}
