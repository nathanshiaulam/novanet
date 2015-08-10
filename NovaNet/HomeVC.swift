//
//  HomeVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/10/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate  {
    // Sets up CLLocationManager and Local Data Store
    let locationManager = CLLocationManager()
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    // Creates array of Profiles to pass data
    var profileList:NSArray = NSArray();
    var conversationList:NSArray = NSArray();
    var conversationParticipantList:NSArray = NSArray();
    
    // Sets up pull to refresh
    var refreshControl:UIRefreshControl! = UIRefreshControl();

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func segmentControlChanged(sender: UISegmentedControl) {
        loadAndRefreshData();
    }
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pingCell", name: "pingCell", object: nil);
        
        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);

        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self);
        } else {
            // Sets up the row height of Table View Cells
            self.tableView.rowHeight = 85.0
            
            // Sets up core location manager
            locationManager.distanceFilter = 100.0;
            locationManager.activityType = CLActivityType.AutomotiveNavigation;
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            // Request auth to use location in background and then start updating location
            locationManager.requestAlwaysAuthorization();
            locationManager.startUpdatingLocation();
            
            // Sets up refresh control on pull down so that it calls findUsersInRange
            refreshControl.addTarget(self, action: Selector("findConversationParticipants"), forControlEvents:UIControlEvents.ValueChanged);
            refreshControl.addTarget(self, action: Selector("findConversations"), forControlEvents: UIControlEvents.ValueChanged);
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
    
    // Given that latitude and longitude are detected, finds current geopoint
    
    // Converts RGB value to Hex Value with alpha value
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // Edits font sizes and image constraints to fit in each mode
    func manageiOSModelType(cell: HomeTableViewCell) {
        let modelName = UIDevice.currentDevice().modelName;
        
        switch modelName {
        case "iPhone 4s":
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(12.0);
            cell.interestsLabel.font = cell.interestsLabel.font.fontWithSize(8.0);
            cell.lookingForLabel.font = cell.lookingForLabel.font.fontWithSize(8.0);
            cell.experienceLabel.font = cell.experienceLabel.font.fontWithSize(8.0);
        case "iPhone 5":
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(13.0);
            cell.interestsLabel.font = cell.interestsLabel.font.fontWithSize(10.0);
            cell.lookingForLabel.font = cell.lookingForLabel.font.fontWithSize(10.0);
            cell.experienceLabel.font = cell.experienceLabel.font.fontWithSize(10.0);
        case "iPhone 6":
            return; // Essentially do nothing
        default:
            return; // Essentially do nothing
        }
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
    
    func formatLabels(cell: HomeTableViewCell) {
        
        // If run out of room, go to next line so it doesn't go off page
        cell.experienceLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.experienceLabel.sizeToFit();
        cell.nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.nameLabel.sizeToFit();
        cell.interestsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.interestsLabel.sizeToFit();
        cell.lookingForLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.lookingForLabel.sizeToFit();
    }
    
    func findConversations() {
        // Finds all conversations initiated in background sorted by date of most recent message
        PFCloud.callFunctionInBackground("findConversations", withParameters: [:]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.conversationList = result as! NSArray;
            } else {
                println(error);
            }
        };
    }
    
    func findConversationParticipants() {
    
        // Finds all conversations initiated in background sorted by date of most recent message
        PFCloud.callFunctionInBackground("findConversationParticipants", withParameters: [:]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.conversationParticipantList = result as! NSArray;
            } else {
                println(error);
            }
        };
    }

    // Takes in a few parameters and returns a list of users that are available and within range
    func findUsersInRange() {
        var longitude = defaults.doubleForKey(Constants.UserKeys.longitudeKey);
        var distance = defaults.integerForKey(Constants.UserKeys.distanceKey);
        var latitude = defaults.doubleForKey(Constants.UserKeys.latitudeKey);
        var currentID = PFUser.currentUser()!.objectId;
        
        // Wipes away old profiles in data stored
        // Might be useless, may remove key in near future
        let clearProfileList = NSArray();
        defaults.setObject(clearProfileList, forKey: Constants.UserKeys.profilesInRangeKey)
        
        PFCloud.callFunctionInBackground("findUsers", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.profileList = result as! NSArray;
                self.tableView.reloadData();
                self.refreshControl.endRefreshing();
            } else {
                println(error);
            }
        }
    }

    func pingCell() {
        
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
                        self.findConversationParticipants();
                        self.findConversations();
                        self.findUsersInRange();
                    } else {
                        println(error);
                    }
                }
            }
        }
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
        let profileCellIdentifier:String = "ProfileCell";
        let chatCellIdentifier:String = "ChatCell";
        
        if segmentControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(profileCellIdentifier, forIndexPath: indexPath) as! HomeTableViewCell
            
            formatLabels(cell);
            
            // Loads all of the data for each cell generated
            if (profileList.count > 0) {
                var profile: AnyObject = profileList[indexPath.row];
                manageiOSModelType(cell);
                cell.nameLabel.text = profile["Name"] as? String;
                cell.interestsLabel.text = profile["Interests"] as? String;
                cell.interestsLabel.text = "Interests: " + cell.interestsLabel.text!;
                cell.experienceLabel.text = profile["Experience"] as? String;
                cell.experienceLabel.text = "Profession: " + cell.experienceLabel.text!;
                cell.lookingForLabel.text = profile["Looking"] as? String;
                cell.lookingForLabel.text = "Looking: " + cell.lookingForLabel.text!;
                cell.selectedUserId = (profile["ID"] as? String)!;
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
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(chatCellIdentifier, forIndexPath: indexPath) as! ConversationTableViewCell
            
            
            if (conversationList.count > 0) {
                var conversationParticipant: AnyObject = conversationParticipantList[indexPath.row];
                var conversation: AnyObject = conversationList[indexPath.row];
                var profile: AnyObject = profileList[indexPath.row];

                var readConversationCount:Int = conversationParticipant["ReadMessageCount"] as! Int;
                var conversationCount:Int = conversation["MessageCount"] as! Int;
                
                cell.nameLabel.text = profile["Name"] as? String;
                if readConversationCount < conversationCount {
                    cell.hasUnreadMessage = true;
                }
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
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profileCellIdentifier:String = "ProfileCell";
        let chatCellIdentifier:String = "ChatCell";

        if (profileList.count > 0) {
            var profile: AnyObject = profileList[indexPath.row];
            
            // Sets values for selected user
            defaults.setObject(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey);
            defaults.setObject(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey);
            defaults.setObject(profile["Username"], forKey: Constants.SelectedUserKeys.selectedUsernameKey);
        }
        
        if (segmentControl.selectedSegmentIndex == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(profileCellIdentifier, forIndexPath: indexPath) as! HomeTableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(chatCellIdentifier, forIndexPath: indexPath) as! ConversationTableViewCell
        }
        self.performSegueWithIdentifier("toMessageView", sender: self);
    }
}
