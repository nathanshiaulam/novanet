//
//  TableViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 10/25/15.
//  Copyright © 2015 Nova. All rights reserved.
//


import UIKit
import Parse
import Bolts


class TableViewController: UITableViewController, UITextFieldDelegate {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "BrandonGrotesque-Medium", size: 18)!]
        self.tableView.separatorColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
    }
    

    // Removes keyboard when tap outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    
    func willEnterForeground(_ notification: Notification!) {
        if (Utilities().userLoggedIn()) {
            let query:PFQuery = PFQuery(className: "Profile");
            let currentID = PFUser.current()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackground {
                (profile: PFObject?, error: NSError?) -> Void in
                if (profile == nil || error != nil) {
                    print(error);
                } else if let profile = profile {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    profile["last_active"] = dateFormatter.string(from: Date());
                    profile["Available"] = true
                    profile.saveInBackground();
                    print(dateFormatter.string(from: Date()));
                }
            }
        }
    }
    
    deinit {
        // make sure to remove the observer when this view controller is dismissed/deallocated
        
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
    }
}
