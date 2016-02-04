//
//  EventAttendanceButton.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/5/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import UIKit

class EventAttendanceButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 5.0;
        let cornerRadius : CGFloat = 0.0
        
        self.setTitleColor(Utilities().UIColorFromHex(0x4e5665, alpha: 1.0), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)

        self.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.cornerRadius = cornerRadius
        
    }
}
