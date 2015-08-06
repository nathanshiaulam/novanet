//
//  HomeTableViewCell.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/21/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lookingForLabel: UILabel!
    var selectedUserId:String = "";

    //    var fikkaPressed = false;
    //    @IBOutlet weak var fikkaButton: UIButton!

}
