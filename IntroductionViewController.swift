//
//  IntroductionViewController.swift
//  
//
//  Created by Nathan Lam on 8/13/15.
//
//

import UIKit
import Bolts
import Parse

class IntroductionViewController: UIViewController {
    
    // Takes user back to homeview after coming from uploadProfilePictureVC
    func backToHomeView() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        self.title = "1 of 4";
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backToHomeView", name: "backToHomeView", object: nil);
        
    }
}
