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
    let defaults:UserDefaults = UserDefaults.standard
    
    // Sets up pull to refresh
    var refreshControl:UIRefreshControl! = UIRefreshControl()
    
    @IBAction func sortByDistance(_ sender: UIButton) {
        if byDist == false {
            byDist = true
            let currentFont = distanceButton.titleLabel!.font
            distanceButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: (currentFont?.pointSize)!)
            
            let otherCurrentFont = alphabeticalButton.titleLabel!.font
            alphabeticalButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: (otherCurrentFont?.pointSize)!)

            loadAndRefreshData()
        }
    }
    
    @IBAction func sortByAlphabet(_ sender: UIButton) {
        if byDist == true {
            byDist = false
            
            let currentFont = distanceButton.titleLabel!.font
            distanceButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: (currentFont?.pointSize)!)

            let otherCurrentFont = alphabeticalButton.titleLabel!.font
            alphabeticalButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: (otherCurrentFont?.pointSize)!)

            loadAndRefreshData()
        }
    }
    
    
    
    
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(FinderViewController.loadAndRefreshData), name: NSNotification.Name(rawValue: "loadAndRefreshData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FinderViewController.phoneVibrate), name: NSNotification.Name(rawValue: "phoneVibrate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FinderViewController.selectProfileVC), name: NSNotification.Name(rawValue: "selectProfileVC"), object: nil)
        self.tableView.tableFooterView = UIView()
                
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: toggleView.frame.size.height - width, width:  toggleView.frame.size.width, height: toggleView.frame.size.height)
        border.borderWidth = width
        toggleView.layer.addSublayer(border)
        toggleView.layer.masksToBounds = true
        
        byDist = true
        self.tabBarController?.navigationItem.leftBarButtonItem = nil

        // Sets up the row height of Table View Cells
        self.tableView.rowHeight = 75.0
        self.tabBarController?.navigationItem.title = "FINDER"
        let confirmed = defaults.bool(forKey: Constants.TempKeys.confirmed)
        // Go to confirmation page if not confirmed
        if (!confirmed) {
            self.performSegue(withIdentifier: "toConfirmationPage", sender: self)
        }
        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.performSegue(withIdentifier: "toUserLogin", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If the user logged out, empty the tableView and perform segue to User Login
        self.tabBarController?.navigationItem.title = "FINDER"
        let appearance = UITabBarItem.appearance()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let font:UIFont = UIFont(name: "OpenSans", size: 18)!
        let attributes = [NSFontAttributeName:font]
        appearance.setTitleTextAttributes(attributes, for: UIControlState())
        if (!self.userLoggedIn()) {
            profileList = NSArray()
            tableView.reloadData()
            self.performSegue(withIdentifier: "toUserLogin", sender: self)
            return
        } else {
            // Sets up core location manager
            locationManager.distanceFilter = 50.0
            locationManager.activityType = CLActivityType.automotiveNavigation
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // Request auth to use location in background and then start updating location
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            // Sets up refresh control on pull down so that it calls findUsersInRange
            refreshControl.addTarget(self, action: #selector(FinderViewController.loadAndRefreshData), for: UIControlEvents.valueChanged)
            
            tableView.addSubview(self.refreshControl)
            
            // Notes whether or not user was just created
            let fromNew = defaults.bool(forKey: Constants.TempKeys.fromNew)
            
            // Since view appears, if the user is logged in for the first time, segue to Onboarding
            if (fromNew) {
                self.performSegue(withIdentifier: "toOnboardingPage", sender: nil)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let screenWidth = Constants.ScreenDimensions.screenWidth
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        let imageHeight = screenHeight / 7.0
        let midHeight = (screenHeight - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!) * 0.5 - imageHeight * 0.7
        
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
            backgroundLabel.textAlignment = NSTextAlignment.left
            backgroundLabel.sizeToFit()
            backgroundView.addSubview(backgroundLabel)
            
            backgroundView.backgroundColor = Utilities().UIColorFromHex(0xFBFBFB, alpha: 1.0)
            self.tableView.backgroundView = backgroundView

            
        } else {
            backgroundLabel.isHidden = true
            backgroundImage.isHidden = true
            self.tableView.backgroundView?.isHidden = true
        }
        return profileList.count
    }
    
    // Return the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! HomeTableViewCell
        manageiOSModelTypeCellLabels(cell)
        formatLabels(cell)
        imageList = [UIImage?](repeating: nil, count: profileList.count)
        if (profileList.count > 0) {
            let profile: AnyObject = profileList[(indexPath as NSIndexPath).row] as AnyObject
            let dist: AnyObject = distList[(indexPath as NSIndexPath).row] as AnyObject
            
            cell.name.text = profile["Name"] as? String
            cell.experience.text = profile["Experience"] as? String
            cell.selectedUserId = (profile["ID"] as? String)!
            cell.dist.text = String(stringInterpolationSegment: dist) + "km"
            cell.experience.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.experience.sizeToFit()
            var image = PFFile()
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile
                image.getDataInBackground {
                    (imageData, error) -> Void in
                    if (error == nil) {
                        cell.profileImage.image = UIImage(data:imageData!)
                        Utilities().formatImage(cell.profileImage)
                        self.imageList[(indexPath as NSIndexPath).row] = UIImage(data:imageData!)
                    }
                    else {
                        print(error)
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "selectImage")!
                self.imageList[(indexPath as NSIndexPath).row] = nil
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).row == 0) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.bounds.width);
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (profileList.count > 0) {
            let profile: AnyObject = profileList[(indexPath as NSIndexPath).row] as AnyObject
            let dist: AnyObject = distList[(indexPath as NSIndexPath).row] as AnyObject
            let image: UIImage! = imageList[(indexPath as NSIndexPath).row] as UIImage!
            
            if ((image) != nil) {
                self.nextImage = image
            } else {
                self.nextImage = nil
            }
            
            // Sets values for selected user
            prepareDataStore(profile as! PFObject)
            defaults.set(dist, forKey: Constants.SelectedUserKeys.selectedDistanceKey)
            self.performSegue(withIdentifier: "toProfileView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toProfileView" {
            let destinationVC = segue.destination.childViewControllers.first as! SelectedProfileViewController
            destinationVC.image = self.nextImage
            destinationVC.fromMessage = false
        }
    }


    
    /*-------------------------------- LOCATION MANAGER METHODS ------------------------------------*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                currentLocation = locationManager.location!
        }
        defaults.set(currentLocation.coordinate.longitude, forKey: Constants.UserKeys.longitudeKey)
        defaults.set(currentLocation.coordinate.latitude, forKey: Constants.UserKeys.latitudeKey)
        
        
        if userLoggedIn() && defaults.string(forKey: Constants.UserKeys.latitudeKey) != nil {
            let query = PFQuery(className:"Profile")
            let currentID = PFUser.current()!.objectId
            query.whereKey("ID", equalTo:currentID!)
            
            query.getFirstObjectInBackground {
                (profile: PFObject?, error: Error?) -> Void in
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    private func locationManager(_ manager: CLLocationManager!, error: NSError!) {
        print("Error while updating location " + error.localizedDescription)
    }
    

    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.current()
        if ((currentUser) != nil) {
            return true
        }
        return false
    }
    
    func selectProfileVC() {
        self.tabBarController?.selectedIndex = 3
    }
    
    func manageiOSModelTypeCellLabels(_ cell: HomeTableViewCell) {
        if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_4_HEIGHT) {
            cell.name.font = cell.name.font.withSize(14.0)
            cell.experience.font = cell.experience.font.withSize(10.0)
            cell.dist.font = cell.dist.font.withSize(10.0)
            
            return
        } else if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_5_HEIGHT) {
            cell.name.font = cell.name.font.withSize(14.0)
            cell.experience.font = cell.experience.font.withSize(10.0)
            cell.dist.font = cell.dist.font.withSize(10.0)
            
            return
        } else if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_6_HEIGHT) {
            return // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_6_PLUS_HEIGHT) {
            cell.name.font = cell.name.font.withSize(22.0)
            cell.experience.font = cell.experience.font.withSize(13.0)
            cell.dist.font = cell.dist.font.withSize(13.0)
            return
        }
        
    }
    
    // Takes in a few parameters and returns a list of users that are available and within range
    func findUsersInRange() {
        let longitude = defaults.double(forKey: Constants.UserKeys.longitudeKey)
        let distance = defaults.integer(forKey: Constants.UserKeys.distanceKey)
        let latitude = defaults.double(forKey: Constants.UserKeys.latitudeKey)

        // Wipes away old profiles in data stored
        // Might be useless, may remove key in near future
        PFCloud.callFunction(inBackground: "findUsers", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result, error) -> Void in
            if error == nil {
                self.profileList = result as! NSArray
                self.findDistList(longitude, latitude: latitude, distance: distance)
            } else {
                print(error)
            }
        }
    }
   
    
    // Takes in geopoint + currentID and finds distances of users in range
    func findDistList(_ longitude: Double, latitude: Double, distance: Int) {
        PFCloud.callFunction(inBackground: "findDistances", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result, error) -> Void in
            if error == nil {
                self.distList = result as! NSArray
                if (self.byDist == true) {
                    var byDistDict:Dictionary = Dictionary<PFObject, Double>()
                    let byDistList:NSMutableArray = NSMutableArray()
                    let sortedDistances:NSMutableArray = NSMutableArray()
                    for i in 0..<self.profileList.count {
                        byDistDict[self.profileList[i] as! PFObject] = Double((self.distList[i] as AnyObject).doubleValue)
                    }
                    for (k,v) in (Array(byDistDict).sorted(by: {$0.1 < $1.1})) {
                        byDistList.add(k)
                        sortedDistances.add(Double(round(100*v)/100))
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
        let currentID = PFUser.current()!.objectId
        query.whereKey("ID", equalTo:currentID!)
        
        // Gets current geopoint of the user and saves it
        let latitude = self.defaults.double(forKey: Constants.UserKeys.latitudeKey)
        let longitude = self.defaults.double(forKey: Constants.UserKeys.longitudeKey)
        let point:PFGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        
        query.getFirstObjectInBackground {
            (profile: PFObject?, error: Error?) -> Void in
            if error != nil || profile == nil {
                print(error)
            } else if let profile = profile {
                profile["Location"] = point
                profile.saveInBackground {
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
    func prepareDataStore(_ profile: PFObject) {
        defaults.set(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey)
        defaults.set(profile["InterestsList"], forKey: Constants.SelectedUserKeys.selectedInterestsKey)
        defaults.set(profile["About"], forKey: Constants.SelectedUserKeys.selectedAboutKey)
        defaults.set(profile["Experience"], forKey: Constants.SelectedUserKeys.selectedExperienceKey)
        defaults.set(profile["Looking"], forKey: Constants.SelectedUserKeys.selectedLookingForKey)
        defaults.set(profile["Available"], forKey: Constants.SelectedUserKeys.selectedAvailableKey)
        defaults.set(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey)

    }

    // formats labels for each cell
    func formatLabels(_ cell: HomeTableViewCell) {
        // If run out of room, go to next line so it doesn't go off page
        cell.experience.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.experience.sizeToFit()
        cell.name.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.name.sizeToFit()
        cell.dist.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.dist.sizeToFit()
    }
    
    // Vibrates the phone when receives message
    func phoneVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}


