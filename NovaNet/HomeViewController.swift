//
//  HomeViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
class HomeViewController: UIViewController {

    @IBOutlet weak var helloLabel: UILabel!
    @IBAction func userLogout(sender: AnyObject) {
        PFUser.logOut();
        self.performSegueWithIdentifier("toUserLogin", sender: self);
    }

    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        var currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
    
    func goToSettingsPage() {
        self.performSegueWithIdentifier("goToSettingsPage", sender: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Go to login page if no user logged in
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goToSettingsPage", name: "goToSettingsPage", object: nil);
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self);
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
