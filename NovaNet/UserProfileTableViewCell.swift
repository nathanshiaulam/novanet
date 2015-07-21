//
//  UserProfileTableViewCell.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/21/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profileInterestsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func toProfileInfo(sender: UIButton) {
    }
    @IBAction func toProfileContact(sender: UIButton) {
    }
}
