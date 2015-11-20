//
//  EventDescriptionTableVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/5/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse


class EventDescriptionTableVC: TableViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        descriptionLabel.sizeToFit();
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }
    
}
