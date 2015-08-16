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
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var experience: UILabel!
    @IBOutlet weak var dist: UILabel!
    var selectedUserId:String = "";

    //    var fikkaPressed = false;
    //    @IBOutlet weak var fikkaButton: UIButton!

}
