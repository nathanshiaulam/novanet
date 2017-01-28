//
//  AboutContentVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/25/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class AboutContentVC: ViewController {

    @IBOutlet var tutorialLabel: UILabel!
    @IBOutlet var tutorialImage: UIImageView!
    
    var pageIndex:Int!
    var titleText: String!
    var imageFile: String!
    
    @IBOutlet var imageHeight: NSLayoutConstraint!
    @IBOutlet var labelWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tutorialImage.image = UIImage(named: self.imageFile)
        self.tutorialLabel.text = self.titleText
        self.view.backgroundColor = UIColor.white
        manageiOSModelType()
    }
    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            self.imageHeight.constant = 230
            self.labelWidth.constant = 300
            return
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            self.imageHeight.constant = 230
            self.labelWidth.constant = 300
            return
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            self.imageHeight.constant = 270
            self.labelWidth.constant = 350
            return
        }
    }

}
