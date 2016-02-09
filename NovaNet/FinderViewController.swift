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



class FinderViewController:  ViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate  {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var alphabeticalButton: UIButton!
    
    // Creates array of Profiles to pass data
    var nextImage:UIImage? = UIImage()
    var profileList:NSArray = NSArray()
    var distList:NSArray = NSArray()
    var imageList = [UIImage?]()
    var byDist:Bool!
    
    // Sets up CLLocationManager and Local Data Store
    let locationManager = CLLocationManager()
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // Sets up pull to refresh
    var refreshControl:UIRefreshControl! = UIRefreshControl()
    
    
    @IBAction func sortByDistance(sender: UIButton) {
        if byDist == false {
            byDist = true
            let currentFont = distanceButton.titleLabel!.font
            distanceButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: currentFont.pointSize)
            
            let otherCurrentFont = alphabeticalButton.titleLabel!.font
            alphabeticalButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: otherCurrentFont.pointSize)

            loadAndRefreshData()
        }
    }
    
    @IBAction func sortByAlphabet(sender: UIButton) {
        if byDist == true {
            byDist = false
            let currentFont = distanceButton.titleLabel!.font
            print(distanceButton.titleLabel!.font)

            distanceButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: currentFont.pointSize)

            let otherCurrentFont = alphabeticalButton.titleLabel!.font
            print(distanceButton.titleLabel!.font)

            alphabeticalButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: otherCurrentFont.pointSize)

            loadAndRefreshData()
        }
    }
    
    
    
    
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadAndRefreshData", name: "loadAndRefreshData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "phoneVibrate", name: "phoneVibrate", object: nil)
        byDist = true
        self.tabBarController?.navigationItem.leftBarButtonItem = nil

        // Sets up the row height of Table View Cells
        manageiOSModelType()
        self.tabBarController?.navigationItem.title = "Finder"

        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // If the user logged out, empty the tableView and perform segue to User Login
        self.tabBarController?.navigationItem.title = "Finder"

        if (!self.userLoggedIn()) {
            profileList = NSArray()
            tableView.reloadData()
            self.performSegueWithIdentifier("toUserLogin", sender: self)
            return
        } else {
            // Sets up core location manager
            locationManager.distanceFilter = 50.0
            locationManager.activityType = CLActivityType.AutomotiveNavigation
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // Request auth to use location in background and then start updating location
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            // Sets up refresh control on pull down so that it calls findUsersInRange
            refreshControl.addTarget(self, action: Selector("loadAndRefreshData"), forControlEvents: UIControlEvents.ValueChanged)
            
            tableView.addSubview(self.refreshControl)
            
            // Notes whether or not user was just created
            let fromNew = defaults.boolForKey(Constants.TempKeys.fromNew)
            
            // Since view appears, if the user is logged in for the first time, segue to Onboarding
            if (fromNew) {
                self.performSegueWithIdentifier("toOnboardingPage", sender: nil)
            }
            // If the user successfully completes onboarding, found the user's current location, save it, and call findUsersInRange
            else {
                locationManager.startUpdatingLocation()
                loadAndRefreshData()
            }
        }
        super.viewDidAppear(true)
        
    }
    
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return profileList.count
    }
    
    // Return the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! HomeTableViewCell
        manageiOSModelTypeCellLabels(cell)
        formatLabels(cell)
        imageList = [UIImage?](count: profileList.count, repeatedValue: nil)
        if (profileList.count > 0) {
            let profile: AnyObject = profileList[indexPath.row]
            let dist: AnyObject = distList[indexPath.row]
            
            cell.name.text = profile["Name"] as? String
            cell.experience.text = profile["Experience"] as? String
            cell.selectedUserId = (profile["ID"] as? String)!
            cell.dist.text = String(stringInterpolationSegment: dist) + "km"
            cell.experience.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.experience.sizeToFit()
            var image = PFFile()
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile
                image.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if (error == nil) {
                        cell.profileImage.image = UIImage(data:imageData!)
                        self.imageList[indexPath.row] = UIImage(data:imageData!)
                    }
                    else {
                        print(error)
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "selectImage")!
                self.imageList[indexPath.row] = nil

            }
            // Formats image into circle
            formatImage(cell.profileImage)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (profileList.count > 0) {
            let profile: AnyObject = profileList[indexPath.row]
            let dist: AnyObject = distList[indexPath.row]
            let image: UIImage! = imageList[indexPath.row] as UIImage!
            
            if ((image) != nil) {
                self.nextImage = image
            } else {
                self.nextImage = nil
            }
            // Sets values for selected user
            prepareDataStore(profile as! PFObject)
            defaults.setObject(dist, forKey: Constants.SelectedUserKeys.selectedDistanceKey)
            self.performSegueWithIdentifier("toProfileView", sender: self)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toProfileView" {
            let destinationVC = segue.destinationViewController.childViewControllers.first as! SelectedProfileViewController
            destinationVC.image = self.nextImage
            destinationVC.fromMessage = false
        }
    }


    
    /*-------------------------------- LOCATION MANAGER METHODS ------------------------------------*/
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                currentLocation = locationManager.location!
        }
        defaults.setObject(currentLocation.coordinate.longitude, forKey: Constants.UserKeys.longitudeKey)
        defaults.setObject(currentLocation.coordinate.latitude, forKey: Constants.UserKeys.latitudeKey)
        
        
        if userLoggedIn() && defaults.stringForKey(Constants.UserKeys.latitudeKey) != nil {
            let query = PFQuery(className:"Profile")
            let currentID = PFUser.currentUser()!.objectId
            query.whereKey("ID", equalTo:currentID!)
            
            query.getFirstObjectInBackgroundWithBlock {
                (profile: PFObject?, error: NSError?) -> Void in
                if error != nil || profile == nil {
                    print(error)
                } else if let profile = profile {
                    let point:PFGeoPoint = PFGeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                    profile["Location"] = point
                    profile.saveInBackground()
                }
            }
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager!, error: NSError!) {
        print("Error while updating location " + error.localizedDescription)
    }
    

    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.currentUser()
        if ((currentUser) != nil) {
            return true
        }
        return false
    }
    
    func manageiOSModelTypeCellLabels(cell: HomeTableViewCell) {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            cell.name.font = cell.name.font.fontWithSize(16.0)
            cell.experience.font = cell.experience.font.fontWithSize(12.0)
            cell.dist.font = cell.dist.font.fontWithSize(12.0)
            
            return
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            cell.name.font = cell.name.font.fontWithSize(19.0)
            cell.experience.font = cell.experience.font.fontWithSize(13.0)
            cell.dist.font = cell.dist.font.fontWithSize(13.0)
            
            return
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            cell.name.font = cell.name.font.fontWithSize(22.0)
            cell.experience.font = cell.experience.font.fontWithSize(13.0)
            cell.dist.font = cell.dist.font.fontWithSize(13.0)
            return
        }
        
    }
    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            self.tableView.rowHeight = 65.0
            return
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            self.tableView.rowHeight = 70.0
            return
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            self.tableView.rowHeight = 75.0
            return // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            self.tableView.rowHeight = 80.0
            return
        }
    }
  
    
    // Takes in a few parameters and returns a list of users that are available and within range
    func findUsersInRange() {
        let longitude = defaults.doubleForKey(Constants.UserKeys.longitudeKey)
        let distance = defaults.integerForKey(Constants.UserKeys.distanceKey)
        let latitude = defaults.doubleForKey(Constants.UserKeys.latitudeKey)

        // Wipes away old profiles in data stored
        // Might be useless, may remove key in near future
        PFCloud.callFunctionInBackground("findUsers", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.profileList = result as! NSArray
                
                self.findDistList(longitude, latitude: latitude, distance: distance)
            } else {
                print(error)
            }
        }
    }
   
    
    // Takes in geopoint + currentID and finds distances of users in range
    func findDistList(longitude: Double, latitude: Double, distance: Int) {
        PFCloud.callFunctionInBackground("findDistances", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.distList = result as! NSArray
                if (self.byDist == true) {
                    var byDistDict:Dictionary = Dictionary<PFObject, Double>()
                    let byDistList:NSMutableArray = NSMutableArray()
                    let sortedDistances:NSMutableArray = NSMutableArray()
                    for (var i = 0; i < self.profileList.count; i++) {
                        byDistDict[self.profileList[i] as! PFObject] = Double(self.distList[i].doubleValue)
                    }
                    for (k,v) in (Array(byDistDict).sort({$0.1 < $1.1})) {
                        byDistList.addObject(k)
                        sortedDistances.addObject(Double(round(100*v)/100))
                    }
                    self.profileList = byDistList.copy() as! NSArray
                    self.distList = sortedDistances.copy() as! NSArray
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                } else {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }

            } else {
                print(error)
            }
        }

    }
    
    // Loads the users and distances into the tableview list
    func loadAndRefreshData() {
        let query = PFQuery(className:"Profile")
        let currentID = PFUser.currentUser()!.objectId
        query.whereKey("ID", equalTo:currentID!)
        
        // Gets current geopoint of the user and saves it
        let latitude = self.defaults.doubleForKey(Constants.UserKeys.latitudeKey)
        let longitude = self.defaults.doubleForKey(Constants.UserKeys.longitudeKey)
        let point:PFGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                print(error)
            } else if let profile = profile {
                profile["Location"] = point
                profile.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                        self.findUsersInRange()
                    } else {
                        print(error)
                    }
                }
            }
        }
    }

    
    // Sets up local datastore
    func prepareDataStore(profile: PFObject) {
        defaults.setObject(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey)
        defaults.setObject(profile["InterestsList"], forKey: Constants.SelectedUserKeys.selectedInterestsKey)
        defaults.setObject(profile["About"], forKey: Constants.SelectedUserKeys.selectedAboutKey)
        defaults.setObject(profile["Experience"], forKey: Constants.SelectedUserKeys.selectedExperienceKey)
        defaults.setObject(profile["Looking"], forKey: Constants.SelectedUserKeys.selectedLookingForKey)
        defaults.setObject(profile["Available"], forKey: Constants.SelectedUserKeys.selectedAvailableKey)
        defaults.setObject(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey)

    }
    

    
    // Formats image into circle if the image is a square *should probably crop to square first*
    func formatImage( profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }

    // formats labels for each cell
    func formatLabels(cell: HomeTableViewCell) {
        
        // If run out of room, go to next line so it doesn't go off page
        cell.experience.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.experience.sizeToFit()
        cell.name.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.name.sizeToFit()
        cell.dist.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.dist.sizeToFit()

    }
    
    // Vibrates the phone when receives message
    func phoneVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}


