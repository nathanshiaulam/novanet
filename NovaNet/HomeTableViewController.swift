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
    
    @IBOutlet weak var messageImage: UIImageView!

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

    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    override func viewDidLoad() {
        
        super.viewDidLoad();

        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);

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
        self.tableView.rowHeight = 85.0
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("findUsersInRange"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        locationManager.startUpdatingLocation();
        if (!self.userLoggedIn()) {
            profileList = NSArray();
            tableView.reloadData()
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
        var profile: AnyObject = profileList[indexPath.row];
    
        if (profileList.count > 0) {
            manageiOSModelType(cell);
            cell.textLabel?.text = "";
            cell.nameLabel.text = profile["Name"] as? String;
            cell.interestsLabel.text = profile["Interests"] as? String;
            cell.interestsLabel.text = "Interests: " + cell.interestsLabel.text!;
            cell.interestsLabel.text = profile["Goals"] as? String;
            cell.interestsLabel.text = "Goals: " + cell.interestsLabel.text!;
            cell.backgroundLabel.text = profile["Background"] as? String;
            cell.backgroundLabel.text = "Background: " + cell.backgroundLabel.text!;
            cell.selectedUserId = (profile["ID"] as? String)!;
            var image = PFFile();
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile;
            }
            image.getDataInBackgroundWithBlock {
                (imageData, error) -> Void in
                if (error == nil) {
                    cell.profileImage.image = UIImage(data:imageData!);
                }
                else {
                    println(error);
                }
            }
            // Store all necessary information to send out push notification
            defaults.setObject(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey);
            defaults.setObject(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey);
            cell.fikkaButton.tag = indexPath.row;
            cell.fikkaButton.addTarget(self, action: "fikkaButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            formatImage(cell.profileImage);
        }
        return cell;
        
    }

    func manageiOSModelType(cell: HomeTableViewCell) {
        let modelName = UIDevice.currentDevice().modelName;
        
        switch modelName {
        case "iPhone 4s":
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(12.0);
            cell.interestsLabel.font = cell.interestsLabel.font.fontWithSize(8.0);
            cell.backgroundLabel.font = cell.backgroundLabel.font.fontWithSize(8.0);
        case "iPhone 5":
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(13.0);
            cell.interestsLabel.font = cell.interestsLabel.font.fontWithSize(10.0);
            cell.backgroundLabel.font = cell.backgroundLabel.font.fontWithSize(10.0);
        case "iPhone 6":
            return; // Essentially do nothing
        default:
            return; // Essentially do nothing
        }
    }
    
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    
    func fikkaButtonClicked(sender:UIButton) {
        println("hi");
        let defaults = NSUserDefaults.standardUserDefaults();
        var buttonIndex = sender.tag;
        var indexPath = NSIndexPath(forRow: buttonIndex, inSection: 0);
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! HomeTableViewCell;
        println("hi2");
        // Sets current username
        var profile: AnyObject = profileList[indexPath.row];
        defaults.setObject(profile["Username"], forKey: Constants.SelectedUserKeys.selectedUsernameKey);
        println("hi3");
        // Fika button already pressed so no need to send message.
        if (cell.fikkaPressed) {
            println("hi4");
            var alert = UIAlertController(title: "You already said hi!", message: "Tap on the tab to start talking to " + cell.nameLabel.text! + "!", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
        // Fika button not yet pressed
        } else {
            cell.fikkaPressed = true; // Set to true so next run doesn't execute

            // Create data that is passed through push notification
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var DateInFormat = dateFormatter.stringFromDate(NSDate());
            var text:String! = defaults.stringForKey(Constants.ConstantStrings.fikkaText) as String!;
            var name:String = profile["Name"] as! String
            let data = [
                "alert":name + ": Hi, nice to meet you. I'm interested in what you're doing, and I'd love to get a Fika sometime soon. Let me know when you're free!",
                "id":profile["ID"] as! String,
                "date": DateInFormat,
                "name":name,
            ]

            // Send push notification with message
            let push = PFPush();
            var innerQuery : PFQuery = PFUser.query()!
            innerQuery.whereKey("objectId", equalTo: defaults.objectForKey(Constants.SelectedUserKeys.selectedIdKey)!)
            var pushQuery = PFInstallation.query()
            pushQuery!.whereKey("user", matchesQuery: innerQuery)
            push.setQuery(pushQuery) // Set our Installation query
            push.setData(data);
            push.sendPushInBackgroundWithBlock {
                (succeeded, error) -> Void in
                if (succeeded) {
                    // Saves message to load for conversation
                    var message = PFObject(className: "Message");
                    message["Sender"] = PFUser.currentUser()?.objectId;
                    message["Date"] = self.dateFromString(DateInFormat, format: "yyyy-MM-dd HH:mm:ss");
                    message["Text"] = Constants.ConstantStrings.fikkaText;
                    message["Recipient"] = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey);
                    message.saveInBackground();
                    self.performSegueWithIdentifier("toMessageView", sender: self)
                } else {
                    println(error);
                }
            }
        }
    }
    
    func formatImage(var profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! HomeTableViewCell
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        var profile: AnyObject = profileList[indexPath.row];
        defaults.setObject(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey);
        defaults.setObject(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey);
        defaults.setObject(profile["Username"], forKey: Constants.SelectedUserKeys.selectedUsernameKey);
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
