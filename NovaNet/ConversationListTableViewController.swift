//
//  ConversationListTableViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/15/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//  Include that when you logout, it clears the list here as well

import UIKit
import Parse
import Bolts
import CoreLocation
import AudioToolbox

class ConversationListTableViewController: TableViewController {
    // Sets up Local Data Store
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    // Sets up conversation lists to load in later
    var conversationList:NSArray = NSArray();
    var conversationParticipantList:NSArray = NSArray();
    var otherProfileList:NSArray = NSArray();
    var imageList = [UIImage?]();
    var nextImage:UIImage? = UIImage();
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    override func viewDidLoad() {
        
        super.viewDidLoad();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadConversations", name: "loadConversations", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "phoneVibrate", name: "phoneVibrate", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMostRecent", name: "updateMostRecent", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goToMessageVC", name: "goToMessageVC", object: nil);

        let refreshControl = UIRefreshControl()
        self.tabBarController?.navigationItem.title = "Messages";

        // Sets up the row height of Table View Cells
        manageiOSModelType();
        
        // Sets up refresh control on pull down so that it calls findUsersInRange
        refreshControl.addTarget(self, action: Selector("loadConversations"), forControlEvents:UIControlEvents.ValueChanged);
        self.refreshControl = refreshControl;

    }
    
    override func viewDidAppear(animated: Bool) {
        if (!self.userLoggedIn()) {
            conversationList = NSArray();
            conversationParticipantList = NSArray();
            otherProfileList = NSArray();
            tableView.reloadData()
            self.tabBarController?.navigationItem.title = "Messages";

            // Go to login page if no user logged in
            self.tabBarController?.selectedIndex = 0;
            super.viewDidAppear(true);
            return;
        }
        else {
            loadConversations();
        }
        
        super.viewDidAppear(true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toMessageVC" {
            let destinationVC = segue.destinationViewController.childViewControllers.first as! MessagerViewController
            print("SecondImage: ");
            print(self.nextImage);
            destinationVC.nextImage = self.nextImage;
        }
    }
    
    
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationList.count;
    }
    
    // Return the number of sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chatCellIdentifier:String = "ChatCell";
        let cell = tableView.dequeueReusableCellWithIdentifier(chatCellIdentifier, forIndexPath: indexPath) as! ConversationTableViewCell
        manageiOSModelTypeCellLabels(cell);
        imageList = [UIImage?](count: otherProfileList.count, repeatedValue: nil);
        if (conversationList.count > 0) {

            let conversationParticipant: AnyObject = conversationParticipantList[indexPath.row];
            let conversation: AnyObject = conversationList[indexPath.row];
            let profile:AnyObject = otherProfileList[indexPath.row];

            // Stores variables to mark unread messages and most recent message
            let readConversationCount:Int = conversationParticipant["ReadMessageCount"] as! Int;
            let conversationCount:Int = conversation["MessageCount"] as! Int;
            var recentMessage="";
            if let message:String = conversation["RecentMessage"] as? String {
                recentMessage = message;
            }
            cell.nameLabel.text = profile["Name"] as? String;
            if readConversationCount < conversationCount {
                cell.unreadMessageMark.hidden = false;
            } else {
                cell.unreadMessageMark.hidden = true;
            }
            cell.recentMessageLabel.text = recentMessage;
            cell.recentMessageLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            cell.recentMessageLabel.sizeToFit();

            var image = PFFile();
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile;
                print("yes");
                image.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if (error == nil) {
                        print("hello");
                        print(UIImage(data:imageData!));
                        cell.profileImage.image = UIImage(data:imageData!);
                        self.imageList[indexPath.row] = UIImage(data:imageData!);
                    }
                    else {
                        print(error);
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "selectImage")!;
                self.imageList[indexPath.row] = UIImage(named: "selectImage")!;
            }
            formatImage(cell.profileImage);
            cell.profileImage.hidden = false;
            cell.recentMessageLabel.hidden = false;
            cell.nameLabel.hidden = false;
        } else {
                cell.profileImage.hidden = true;
                cell.recentMessageLabel.hidden = true;
                cell.nameLabel.hidden = true;
                cell.unreadMessageMark.hidden = true;
            }
        return cell;
    }
    func manageiOSModelTypeCellLabels(cell: ConversationTableViewCell) {
        
        if (Constants.ScreenDimensions.screenHeight == 480) {
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(16.0);
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.fontWithSize(12.0)
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(19.0);
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.fontWithSize(13.0)
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(22.0);
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.fontWithSize(13.0)
            return;
        }
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profile: PFObject = otherProfileList[indexPath.row] as! PFObject;
        let image: UIImage! = imageList[indexPath.row] as UIImage!;
        if ((image) != nil) {
            self.nextImage = image;
        } else {
            self.nextImage = UIImage(named: "selectImage")!;
        }
        
        // Sets values for selected user
        prepareDataStore(profile);
        self.performSegueWithIdentifier("toMessageVC", sender: self);
    }
    
    
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/

    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
    
    
    func manageiOSModelType() {
        
        if (Constants.ScreenDimensions.screenHeight == 480) {
            self.tableView.rowHeight = 65.0;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            self.tableView.rowHeight = 70.0;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            self.tableView.rowHeight = 75.0;
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            self.tableView.rowHeight = 75.0;
            return;
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
    func formatImage( profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    
    // Vibrates the phone when receives message
    func phoneVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // Sets up local datastore
    func prepareDataStore(profile: PFObject) {
        defaults.setObject(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey);
        defaults.setObject(profile["InterestsList"], forKey: Constants.SelectedUserKeys.selectedInterestsKey);
        defaults.setObject(profile["About"], forKey: Constants.SelectedUserKeys.selectedAboutKey);
        defaults.setObject(profile["Experience"], forKey: Constants.SelectedUserKeys.selectedExperienceKey);
        defaults.setObject(profile["Looking"], forKey: Constants.SelectedUserKeys.selectedLookingForKey);
        defaults.setObject(profile["Available"], forKey: Constants.SelectedUserKeys.selectedAvailableKey);
        defaults.setObject(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey);
        
        
    }
    
    func goToMessageVC() {
        self.performSegueWithIdentifier("toMessageVC", sender: self);
    }
    
    // Helper methods to save images into local datastore from Parse
    func documentsPathForFileName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let path = paths[0];
        let fullPath = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name)
        
        return String(fullPath);
    }
    func saveOtherImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path = self.documentsPathForFileName(relativePath)
        imageData!.writeToFile(path, atomically: true)
        NSUserDefaults.standardUserDefaults().setObject(relativePath, forKey: Constants.SelectedUserKeys.selectedProfileImageKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    // Calls main helper functions to load all conversations
    func loadConversations() {
        findConversationParticipants();
    }
    
    // Finds the list of IDs of the other conversation participants in the area
    func findOtherProfiles() {
        let otherIDs:NSMutableArray = NSMutableArray();
        for (var i = 0; i < conversationParticipantList.count; i++){
            let participant = conversationParticipantList[i] as! PFObject;
            otherIDs.addObject(participant["OtherUser"]!);
        }
        let query = PFQuery(className: "Profile");
        query.whereKey("ID", containedIn: otherIDs as [AnyObject]);
        query.orderByDescending("MostRecent");
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.otherProfileList = objects!;
                self.tableView.reloadData();
                self.refreshControl?.endRefreshing();
            } else {
                print(error);
            }
        }
    }
    
    // Finds all conversations initiated in background sorted by date of most recent message
    func findConversations() {
        PFCloud.callFunctionInBackground("findConversations", withParameters: [:]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.conversationList = result as! NSArray;
                self.findOtherProfiles();
            } else {
                print(error);
            }
        };
    }
    
    // Finds all conversations initiated in background sorted by date of most recent message
    func findConversationParticipants() {
        
        PFCloud.callFunctionInBackground("findConversationParticipants", withParameters: [:]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.conversationParticipantList = result as! NSArray;
                self.findConversations()
            } else {
                print(error);
            }
        };
    }

}
