//
//  ConversationTableViewCell.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/10/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var hasUnreadMessage:Bool = false;
}
