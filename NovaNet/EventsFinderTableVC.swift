//
//  EventsFinderTableVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/3/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse

class EventsFinderTableVC: ViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate   {
    
    
    
 
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1;
    }
    
    // Return the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        
        return cell;
    }
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
    }
}
