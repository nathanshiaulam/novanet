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
    
    @IBOutlet weak var toggleView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var alphabeticalButton: UIButton!
    
    // Creates array of Profiles to pass data
    var nextImage:UIImage? = UIImage()
    var profileList:NSArray = NSArray()
    var distList:NSArray = NSArray()
    var imageList = [UIImage?]()
    var byDist:Bool!
    let backgroundLabel = UILabel()
    let backgroundView = UIView()
    var backgroundImage = UIImageView()
    
    // Sets up CLLocationManager and Local Data Store
    let locationManager = CLLocationManager()
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // Sets up pull to refresh
    var refreshControl:UIRefreshControl! = UIRefreshControl()
    
    @IBAction func sortByDistance(sender: UIButton) {
        if byDist == false {
            byDist = true
            let currentFont = distanceButton.titleLabel!.font
            distanceButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: currentFont.pointSize)
            
            let otherCurrentFont = alphabeticalButton.titleLabel!.font
            alphabeticalButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: otherCurrentFont.pointSize)

            loadAndRefreshData()
        }
    }
    
    @IBAction func sortByAlphabet(sender: UIButton) {
        if byDist == true {
            byDist = false
            
            let currentFont = distanceButton.titleLabel!.font
            distanceButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: currentFont.pointSize)

            let otherCurrentFont = alphabeticalButton.titleLabel!.font
            alphabeticalButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: otherCurrentFont.pointSize)

            loadAndRefreshData()
        }
    }
    
    
    
    
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinderViewController.loadAndRefreshData), name: "loadAndRefreshData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinderViewController.phoneVibrate), name: "phoneVibrate", object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinderViewController.selectProfileVC), name: "selectProfileVC", object: nil)
        
        byDist = true
        self.tabBarController?.navigationItem.leftBarButtonItem = nil

        // Sets up the row height of Table View Cells
        self.tableView.rowHeight = 75.0
        self.tabBarController?.navigationItem.title = "FINDER"
        
        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // If the user logged out, empty the tableView and perform segue to User Login
        self.tabBarController?.navigationItem.title = "FINDER"
        let appearance = UITabBarItem.appearance()
        let font:UIFont = UIFont(name: "OpenSans", size: 18)!
        let attributes = [NSFontAttributeName:font]
        appearance.setTitleTextAttributes(attributes, forState: .Normal)
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
            refreshControl.addTarget(self, action: #selector(FinderViewController.loadAndRefreshData), forControlEvents: UIControlEvents.ValueChanged)
            
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
        let screenWidth = Constants.ScreenDimensions.screenWidth
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        let midHeight = (screenHeight - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!) * 0.5 + self.toggleView.frame.height
        let imageHeight = screenHeight / 7.0
        
        var fontSize:CGFloat = 13.0
        if (Constants.ScreenDimensions.screenHeight >= Constants.ScreenDimensions.IPHONE_6_HEIGHT) {
            fontSize = 15.0
        }
        
        if (self.profileList.count == 0) {
            
            let imageName = "about_map.png"
            let image = UIImage(named: imageName)
            backgroundImage = UIImageView(image: image!)
            let aspectRatio = backgroundImage.bounds.width / backgroundImage.bounds.height
            backgroundImage.frame = CGRect(x: screenWidth * 0.5 - imageHeight * aspectRatio * 1.3, y: midHeight, width: imageHeight * aspectRatio, height: imageHeight)
            backgroundView.addSubview(backgroundImage)
            
            backgroundLabel.text = "Can’t see anyone here? Pull down to refresh and find more Novas around you."
            backgroundLabel.font = UIFont(name: "OpenSans", size: fontSize)
            backgroundLabel.textColor = Utilities().UIColorFromHex(0x3A4A49, alpha: 1.0)
            backgroundLabel.frame = CGRect(x: screenWidth * 0.5, y: midHeight, width:imageHeight * aspectRatio * 1.5 , height: imageHeight)
            backgroundLabel.numberOfLines = 0
            backgroundLabel.textAlignment = NSTextAlignment.Left
            backgroundLabel.sizeToFit()
            backgroundView.addSubview(backgroundLabel)
            
            self.tableView.backgroundView = backgroundView

            
        } else {
            backgroundLabel.hidden = true
            backgroundImage.hidden = true
            self.tableView.backgroundView?.hidden = true
        }
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
            Utilities().formatImage(cell.profileImage)
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
    
    func selectProfileVC() {
        self.tabBarController?.selectedIndex = 3
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
                    for i in 0..<self.profileList.count {
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


