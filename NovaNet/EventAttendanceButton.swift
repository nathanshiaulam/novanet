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
        
        self.setTitleColor(Utilities().UIColorFromHex(0x879494, alpha: 1.0), for: UIControlState())
        self.setTitleColor(Utilities().UIColorFromHex(0xFC6706, alpha: 1.0), for: UIControlState.highlighted)
        self.setTitleColor(Utilities().UIColorFromHex(0xFC6706, alpha: 1.0), for: UIControlState.selected)
        
        self.titleLabel!.font = UIFont(name: "OpenSans", size: 12.0)
        
        self.backgroundColor = UIColor.white;
        self.layer.borderWidth = 0.0;
        
    }
}
