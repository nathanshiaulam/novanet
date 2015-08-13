//
//  FinishOnboardingViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/13/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class FinishOnboardingViewController: UIViewController {

    @IBAction func finishedOnboardingProcess(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("backToHomeView", object: nil);
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "4 of 4";
    }
}
