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
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    // Sets up CLLocationManager
    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBAction func userLogout(sender: AnyObject) {
        PFUser.logOut();
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var dict = defaults.dictionaryRepresentation();
        for key in dict.keys {
            defaults.removeObjectForKey(key.description);
        }
        defaults.synchronize();
        
        self.performSegueWithIdentifier("toUserLogin", sender: self);
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        locationManager.distanceFilter = 50.0;
        locationManager.activityType = CLActivityType.AutomotiveNavigation;
        locationManager.delegate = self;
        
        
        // Do any additional setup after loading the view.
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                currentLocation = locationManager.location;
        }
        defaults.setObject(currentLocation, forKey:Constants.UserKeys.locationKey);
        if defaults.stringForKey(Constants.UserKeys.nameKey) != nil {
            var query = PFQuery(className:"Profile");
            var currentID = PFUser.currentUser()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackgroundWithBlock {
                (profile: PFObject?, error: NSError?) -> Void in
                if error != nil || profile == nil {
                    println(error);
                } else if let profile = profile {
                    var point:PFGeoPoint = PFGeoPoint(location: currentLocation);
                    profile["Location"] = point;
                    profile.saveInBackground();
                }
            }

        }
    }
    
    func locationManager(manager: CLLocationManager!, error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }

    override func viewDidAppear(animated: Bool) {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();

        var fromNew = defaults.boolForKey(Constants.TempKeys.fromNew);
        if (fromNew) {
            defaults.setObject(false, forKey: Constants.TempKeys.fromNew);
            self.performSegueWithIdentifier("goToSettingsPage", sender: nil);
        }
        if defaults.stringForKey(Constants.UserKeys.nameKey) != nil {
            var query = PFQuery(className:"Profile");
            var currentID = PFUser.currentUser()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackgroundWithBlock {
                (profile: PFObject?, error: NSError?) -> Void in
                if error != nil || profile == nil {
                    println(error);
                } else if let profile = profile {
                    var currentLocation:CLLocation = defaults.objectForKey(Constants.UserKeys.locationKey) as! CLLocation;
                    var point:PFGeoPoint = PFGeoPoint(location: currentLocation);
                    profile["Location"] = point;
                    profile.saveInBackground();
                }
            }
            
        }
        super.viewDidAppear(true);
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
