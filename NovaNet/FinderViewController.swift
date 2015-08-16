//
//  FinderViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
import AudioToolbox



class FinderViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate  {
    
    @IBOutlet var tableView: UITableView!
    
    // Creates array of Profiles to pass data
    var profileList:NSArray = NSArray();
    var distList:NSArray = NSArray();

    // Sets up CLLocationManager and Local Data Store
    let locationManager = CLLocationManager()
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    // Sets up pull to refresh
    var refreshControl:UIRefreshControl! = UIRefreshControl();
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadAndRefreshData", name: "loadAndRefreshData", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "phoneVibrate", name: "phoneVibrate", object: nil);
        self.title = "Finder";
        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self);
        } else {
            // Sets up the row height of Table View Cells
            self.tableView.rowHeight = 75.0
            
            // Sets up core location manager
            locationManager.distanceFilter = 100.0;
            locationManager.activityType = CLActivityType.AutomotiveNavigation;
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            // Request auth to use location in background and then start updating location
            locationManager.requestAlwaysAuthorization();
            locationManager.startUpdatingLocation();
            
            // Sets up refresh control on pull down so that it calls findUsersInRange
            refreshControl.addTarget(self, action: Selector("findUsersInRange"), forControlEvents: UIControlEvents.ValueChanged)
            
            tableView.addSubview(self.refreshControl);
        }

        
    }
    
    override func viewDidAppear(animated: Bool) {
        // If the user logged out, empty the tableView and perform segue to User Login
        if (!self.userLoggedIn()) {
            profileList = NSArray();
            tableView.reloadData()
            self.performSegueWithIdentifier("toUserLogin", sender: self);
            return;
        }
        
        // Notes whether or not user was just created
        var fromNew = defaults.boolForKey(Constants.TempKeys.fromNew);
        
        // Since view appears, if the user is logged in for the first time, segue to Onboarding
        if (fromNew) {
            self.performSegueWithIdentifier("toOnboardingPage", sender: nil);
        }
        // If the user successfully completes onboarding, found the user's current location, save it, and call findUsersInRange
        else if defaults.objectForKey(Constants.UserKeys.nameKey) != nil {
            locationManager.startUpdatingLocation();
            loadAndRefreshData()
        }
        super.viewDidAppear(true);
        
    }
    
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileList.count;
    }
    
    // Return the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! HomeTableViewCell
        formatLabels(cell);
        
        if (profileList.count > 0) {
            var profile: AnyObject = profileList[indexPath.row];
            var dist: AnyObject = distList[indexPath.row];
            cell.name.text = profile["Name"] as? String;
            cell.experience.text = profile["Experience"] as? String;
            cell.selectedUserId = (profile["ID"] as? String)!;
            cell.dist.text = String(stringInterpolationSegment: dist) + "km";
            cell.experience.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            cell.experience.sizeToFit();
            var image = PFFile();
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile;
                image.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if (error == nil) {
                        cell.profileImage.image = UIImage(data:imageData!);
                    }
                    else {
                        println(error);
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "selectImage")!;
            }
            // Formats image into circle
            formatImage(cell.profileImage);
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profileCellIdentifier:String = "ProfileCell";
        if (profileList.count > 0) {
            var profile: AnyObject = profileList[indexPath.row];
            var dist: AnyObject = distList[indexPath.row];
            
            // Sets values for selected user
            prepareDataStore(profile as! PFObject);
            defaults.setObject(dist, forKey: Constants.SelectedUserKeys.selectedDistanceKey);
            let cell = tableView.dequeueReusableCellWithIdentifier(profileCellIdentifier, forIndexPath: indexPath) as! HomeTableViewCell
        }

    }

    
    /*-------------------------------- LOCATION MANAGER METHODS ------------------------------------*/
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                currentLocation = locationManager.location;
        }
        defaults.setObject(currentLocation.coordinate.longitude, forKey: Constants.UserKeys.longitudeKey);
        defaults.setObject(currentLocation.coordinate.latitude, forKey: Constants.UserKeys.latitudeKey);
        
        
        if userLoggedIn() && defaults.stringForKey(Constants.UserKeys.latitudeKey) != nil {
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
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager!, error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    

    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        var currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
    
    // Converts RGB value to Hex Value with alpha value
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // Takes in a few parameters and returns a list of users that are available and within range
    func findUsersInRange() {
        var longitude = defaults.doubleForKey(Constants.UserKeys.longitudeKey);
        var distance = defaults.integerForKey(Constants.UserKeys.distanceKey);
        var latitude = defaults.doubleForKey(Constants.UserKeys.latitudeKey);
        var currentID = PFUser.currentUser()!.objectId;

        // Wipes away old profiles in data stored
        // Might be useless, may remove key in near future
        var available:Bool = defaults.objectForKey(Constants.UserKeys.availableKey) as! Bool
        if (!available) {
            self.profileList = NSArray();
            return;
        }
        PFCloud.callFunctionInBackground("findUsers", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.profileList = result as! NSArray;
                self.findDistList(longitude, latitude: latitude, distance: distance);
            } else {
                println(error);
            }
        }
    }
    
    // Takes in geopoint + currentID and finds distances of users in range
    func findDistList(longitude: Double, latitude: Double, distance: Int) {
        PFCloud.callFunctionInBackground("findDistances", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.distList = result as! NSArray;
                self.tableView.reloadData();
                self.refreshControl.endRefreshing();
            } else {
                println(error);
            }
        }

    }
    func loadAndRefreshData() {
        var query = PFQuery(className:"Profile");
        var currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);
        
        // Gets current geopoint of the user and saves it
        var latitude = self.defaults.doubleForKey(Constants.UserKeys.latitudeKey);
        var longitude = self.defaults.doubleForKey(Constants.UserKeys.longitudeKey);
        var point:PFGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude);
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                println(error);
            } else if let profile = profile {
                profile["Location"] = point;
                profile.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                        self.findUsersInRange();
                    } else {
                        println(error);
                    }
                }
            }
        }
    }

    
    // Sets up local datastore
    func prepareDataStore(profile: PFObject) {
        defaults.setObject(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey);
        defaults.setObject(profile["InterestsList"], forKey: Constants.SelectedUserKeys.selectedInterestsKey);
        defaults.setObject(profile["About"], forKey: Constants.SelectedUserKeys.selectedAboutKey);
        defaults.setObject(profile["Experience"], forKey: Constants.SelectedUserKeys.selectedExperienceKey);
        defaults.setObject(profile["Looking"], forKey: Constants.SelectedUserKeys.selectedLookingForKey);
        defaults.setObject(profile["Available"], forKey: Constants.SelectedUserKeys.selectedAvailableKey);
        var image = PFFile();
        if let userImageFile = profile["Image"] as? PFFile {
            image = userImageFile;
            image.getDataInBackgroundWithBlock {
                (imageData, error) -> Void in
                if (error == nil) {
                    self.saveOtherImage(UIImage(data:imageData!)!);
                }
                else {
                    println(error);
                }
            }
        } else {
            self.saveOtherImage(UIImage(named: "selectImage")!);
        }

    }
    
    // Helper methods to save images into local datastore from Parse
    func documentsPathForFileName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let path = paths[0] as! String;
        let fullPath = path.stringByAppendingPathComponent(name)
        
        return fullPath
    }
    func saveOtherImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path = self.documentsPathForFileName(relativePath)
        imageData.writeToFile(path, atomically: true)
        NSUserDefaults.standardUserDefaults().setObject(relativePath, forKey: Constants.SelectedUserKeys.selectedProfileImageKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    // Converts string into NSDate with format
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    
    // Formats image into circle if the image is a square *should probably crop to square first*
    func formatImage(var profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }

    // formats labels for each cell
    func formatLabels(cell: HomeTableViewCell) {
        
        // If run out of room, go to next line so it doesn't go off page
        cell.experience.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.experience.sizeToFit();
        cell.name.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.name.sizeToFit();
        cell.dist.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.dist.sizeToFit();

    }
    
    // Vibrates the phone when receives message
    func phoneVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }


}
