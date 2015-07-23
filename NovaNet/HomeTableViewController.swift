//
//  HomeTableViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/21/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

class HomeTableViewController: UITableViewController, CLLocationManagerDelegate {
    // Sets up CLLocationManager
    let locationManager = CLLocationManager()
    
    // Creates arrays to pass data
    var profileList:NSArray = NSArray();
    
    
    @IBAction func Yay(sender: AnyObject) {
        println("it works");
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        var currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self);
        }
        
        // Sets up core location manager
        locationManager.distanceFilter = 50.0;
        locationManager.activityType = CLActivityType.AutomotiveNavigation;
        locationManager.delegate = self;
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("findUsersInRange"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self);
        }
        
        var fromNew = defaults.boolForKey(Constants.TempKeys.fromNew);
        if (fromNew) {
            self.performSegueWithIdentifier("toOnboardingPage", sender: nil);
        }
        if defaults.objectForKey(Constants.UserKeys.nameKey) != nil {
            var query = PFQuery(className:"Profile");
            var currentID = PFUser.currentUser()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackgroundWithBlock {
                (profile: PFObject?, error: NSError?) -> Void in
                if error != nil || profile == nil {
                    println(error);
                } else if let profile = profile {
                    var latitude = defaults.doubleForKey(Constants.UserKeys.latitudeKey);
                    var longitude = defaults.doubleForKey(Constants.UserKeys.longitudeKey);
                    var point:PFGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude);
                    profile["Location"] = point;
                    profile.saveInBackground();
                }
            }
            findUsersInRange();
        }
        super.viewDidAppear(true);
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                currentLocation = locationManager.location;
        }
        defaults.setObject(currentLocation.coordinate.longitude, forKey: Constants.UserKeys.longitudeKey);
        defaults.setObject(currentLocation.coordinate.latitude, forKey: Constants.UserKeys.latitudeKey);
        
        
        if defaults.stringForKey(Constants.UserKeys.latitudeKey) != nil {
            var query = PFQuery(className:"Profile");
            var currentID = PFUser.currentUser()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackgroundWithBlock {
                (profile: PFObject?, error: NSError?) -> Void in
                if error != nil || profile == nil {
                    println(error);
                } else if let profile = profile {
                    var point:PFGeoPoint = PFGeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude);
                    profile["Location"] = point;
                    profile.saveInBackground();
                }
            }
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    
    func findUsersInRange() {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var longitude = defaults.doubleForKey(Constants.UserKeys.longitudeKey);
        var distance = defaults.integerForKey(Constants.UserKeys.distanceKey);
        var latitude = defaults.doubleForKey(Constants.UserKeys.latitudeKey);
        var currentID = PFUser.currentUser()!.objectId;
        
        // Wipes away old profiles in data stored
        let clearProfileList = NSArray();
        defaults.setObject(clearProfileList, forKey: Constants.UserKeys.profilesInRangeKey)
        
        PFCloud.callFunctionInBackground("findUsers", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.profileList = result as! NSArray;
                self.tableView.reloadData();
                self.refreshControl?.endRefreshing();
            } else {
                println(error);
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return profileList.count;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! HomeTableViewCell
        
        if (profileList.count > 0) {
            var profile: AnyObject = profileList[indexPath.row];
            cell.textLabel?.text = "";
            cell.nameLabel.text = profile["Name"] as? String;
            cell.interestsLabel.text = profile["Interests"] as? String;
        } else {
            cell.textLabel?.text = Constants.UserKeys.loadText;
        }
        return cell
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
