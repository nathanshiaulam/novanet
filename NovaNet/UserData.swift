//
//  UserData.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/21/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse


class UserData {
    class Profile {
        let name : String;
        let interests: String;
        let image : UIImage;
        let id : String;
        init(name: String, interests: String, image: UIImage, id: String) {
            self.name = name;
            self.interests = interests;
            self.image = image;
            self.id = id;
        }
    }
}