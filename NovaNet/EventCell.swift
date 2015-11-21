//
//  EventCell.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/3/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse

class EventCell: UITableViewCell {
    @IBOutlet weak var eventDay: UILabel!
    @IBOutlet weak var eventMonth: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventOrganizer: UILabel!
    @IBOutlet weak var eventDistance: UILabel!

    @IBOutlet weak var goingButton: EventAttendanceButton!
    @IBOutlet weak var maybeButton: EventAttendanceButton!
    @IBOutlet weak var notGoingButton: EventAttendanceButton!
    
    
}
