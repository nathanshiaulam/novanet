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
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    // Sets up conversation lists to load in later
    var conversationList:NSArray!
    var conversationParticipantList:NSArray!
    var otherProfileList:NSArray!
    var imageList:[UIImage?]!
    var nextImage:UIImage!
    var formattedImages:[UIImage?] = [UIImage]()
    var backgroundLabel = UILabel()
    var backgroundView = UIView()
    var backgroundImage = UIImageView()
    let button = UIButton(type: UIButtonType.System) as UIButton
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    override func viewDidLoad() {
        super.viewDidLoad()
        conversationList = NSArray()
        conversationParticipantList = NSArray()
        otherProfileList = NSArray()
        imageList = [UIImage?]()
        nextImage = UIImage()
        
        self.tableView.rowHeight = 75.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationListTableViewController.loadConversations), name: "loadConversations", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationListTableViewController.phoneVibrate), name: "phoneVibrate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationListTableViewController.goToMessageVC), name: "goToMessageVC", object: nil)

        self.tableView.tableFooterView = UIView()
        let refreshControl = UIRefreshControl()
        self.tabBarController?.navigationItem.title = "MESSAGES"
        loadConversations()

        // Sets up refresh control on pull down so that it calls findUsersInRange
        refreshControl.addTarget(self, action: #selector(ConversationListTableViewController.loadConversations), forControlEvents:UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!self.userLoggedIn()) {
            conversationList = NSArray()
            conversationParticipantList = NSArray()
            otherProfileList = NSArray()
            tableView.reloadData()

            // Go to login page if no user logged in
            self.tabBarController?.selectedIndex = 0
            super.viewDidAppear(true)
            return
        }
        else {
            self.tabBarController?.navigationItem.title = "MESSAGES"
            loadConversations()
        }
        
        super.viewDidAppear(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toMessageVC" {
            let destinationVC = segue.destinationViewController.childViewControllers.first as! MessagerViewController
            destinationVC.nextImage = self.nextImage
        }
    }
    
    
    func switchToFinder(sender:UIButton!) {
        let tb:UITabBarController! = self.navigationController?.parentViewController as! UITabBarController
        tb.selectedIndex = 0
    }
    
    
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let screenWidth = Constants.ScreenDimensions.screenWidth
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
        let midHeight = (screenHeight - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!) * 0.5
        let imageHeight = screenHeight / 7.0
        let buttonHeight:CGFloat = 44.0
        let buttonWidth = screenWidth * 0.7
        var fontSize:CGFloat = 13.0
        if (Constants.ScreenDimensions.screenHeight >= Constants.ScreenDimensions.IPHONE_6_HEIGHT) {
            fontSize = 15.0
        }

        if (self.conversationList.count == 0) {
            let imageName = "about_chat_bubbles.png"
            let image = UIImage(named: imageName)
            backgroundImage = UIImageView(image: image!)
            let aspectRatio = backgroundImage.bounds.width / backgroundImage.bounds.height
            backgroundImage.frame = CGRect(x: screenWidth * 0.5 - imageHeight * aspectRatio * 1.2, y: midHeight, width: imageHeight * aspectRatio, height: imageHeight)
            backgroundView.addSubview(backgroundImage)
            
            backgroundLabel.text = "Don’t have any messages yet? Find Novas and get started!"
            backgroundLabel.font = UIFont(name: "OpenSans", size: fontSize)
            backgroundLabel.textColor = Utilities().UIColorFromHex(0x3A4A49, alpha: 1.0)
            backgroundLabel.frame = CGRect(x: screenWidth * 0.5, y: midHeight, width:imageHeight * aspectRatio * 1.4, height: imageHeight)
            backgroundLabel.numberOfLines = 0
            backgroundLabel.textAlignment = NSTextAlignment.Left
            backgroundLabel.sizeToFit()
            backgroundView.addSubview(backgroundLabel)

            button.frame = CGRect(x: screenWidth * 0.5 - buttonWidth * 0.5, y: midHeight * 1.5, width: buttonWidth, height: buttonHeight)
            button.backgroundColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            button.setTitle("FIND NOVAS", forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.layer.cornerRadius = 5
            button.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: 18.0)
            button.addTarget(self, action: #selector(ConversationListTableViewController.switchToFinder(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            backgroundView.addSubview(button)
            
            backgroundView.backgroundColor = Utilities().UIColorFromHex(0xFBFBFB, alpha: 1.0)

            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            tableView.backgroundView = backgroundView
        } else {

            backgroundLabel.hidden = true
            backgroundImage.hidden = true
            tableView.backgroundView?.hidden = true
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }

        return conversationList.count
    }
    
    // Return the number of sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chatCellIdentifier:String = "ChatCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(chatCellIdentifier, forIndexPath: indexPath) as! ConversationTableViewCell
        manageiOSModelTypeCellLabels(cell)
        imageList = [UIImage?](count: otherProfileList.count, repeatedValue: nil)
        if (conversationList.count > 0) {

            let conversationParticipant: AnyObject = conversationParticipantList[indexPath.row]
            let conversation: AnyObject = conversationList[indexPath.row]
            let profile:AnyObject = otherProfileList[indexPath.row]
            

            // Stores variables to mark unread messages and most recent message
            let readConversationCount:Int = conversationParticipant["ReadMessageCount"] as! Int
            let conversationCount:Int = conversation["MessageCount"] as! Int
            var recentDate:NSDate = NSDate()
            var recentMessage=""
            if let message:String = conversation["RecentMessage"] as? String {
                recentMessage = message
                recentDate = conversation["MostRecent"] as! NSDate
            }
            cell.nameLabel.text = profile["Name"] as? String
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d|h:mm a"
            
            let dateString = dateFormatter.stringFromDate(recentDate)
            let dateComponents = dateString.characters.split{$0 == "|"}.map(String.init)
            
            if ((NSDate().hoursFrom(recentDate)) > 24) {
                cell.timeString.text = dateComponents[0]
            } else {
                cell.timeString.text = dateComponents[1]
            }
            if readConversationCount < conversationCount {
                cell.nameLabel.font = UIFont(name: "OpenSans-Bold", size: (cell.nameLabel.font?.pointSize)!)
                cell.timeString.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            } else {
                cell.timeString.textColor = Utilities().UIColorFromHex(0x53585F, alpha: 1.0)
            }
            cell.recentMessageLabel.text = recentMessage
            cell.recentMessageLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            cell.recentMessageLabel.sizeToFit()

            var image = PFFile()
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile
                image.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if (error == nil) {
                        cell.profileImage.image = UIImage(data:imageData!)
                        Utilities().formatImage(cell.profileImage)
                        self.imageList[indexPath.row] = UIImage(data:imageData!)
                    }
                    else {
                        print(error)
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "selectImage")!
                self.imageList[indexPath.row] = UIImage(named: "selectImage")!
            }
            
            cell.profileImage.hidden = false
            cell.recentMessageLabel.hidden = false
            cell.nameLabel.hidden = false
        } else {
                cell.profileImage.hidden = true
                cell.recentMessageLabel.hidden = true
                cell.nameLabel.hidden = true
        }
        
        return cell
    }
    func manageiOSModelTypeCellLabels(cell: ConversationTableViewCell) {
        if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_4_HEIGHT) {
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(12.0)
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.fontWithSize(10.0)
            return
        } else if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_5_HEIGHT) {
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(14.0)
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.fontWithSize(10.0)
            return
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            cell.nameLabel.font = cell.nameLabel.font.fontWithSize(20.0)
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.fontWithSize(14.0)
            return
        }
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profile: PFObject = otherProfileList[indexPath.row] as! PFObject
        let image: UIImage! = imageList[indexPath.row] as UIImage!
        if ((image) != nil) {
            self.nextImage = image
        } else {
            self.nextImage = UIImage(named: "selectImage")!
        }
        
        // Sets values for selected user
        prepareDataStore(profile)
        self.performSegueWithIdentifier("toMessageVC", sender: self)
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
    
    // Vibrates the phone when receives message
    func phoneVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
    
    func goToMessageVC() {
        self.performSegueWithIdentifier("toMessageVC", sender: self)
    }

    // Calls main helper functions to load all conversations
    func loadConversations() {
        findConversationParticipants()
    }
    
    // Finds the list of IDs of the other conversation participants in the area
    func findOtherProfiles() {
        let otherIDs:NSMutableArray = NSMutableArray()
        for i in 0..<conversationParticipantList.count {
            let participant = conversationParticipantList[i] as! PFObject
            otherIDs.addObject(participant["OtherUser"]!)
        }
        let query = PFQuery(className: "Profile")
        query.whereKey("ID", containedIn: otherIDs as [AnyObject])
        query.orderByDescending("MostRecent")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.otherProfileList = objects!
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            } else {
                print(error)
            }
        }
    }
    
    // Finds all conversations initiated in background sorted by date of most recent message
    func findConversations() {
        PFCloud.callFunctionInBackground("findConversations", withParameters: [:]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.conversationList = result as! NSArray
                self.findOtherProfiles()
            } else {
                print(error)
            }
        }
    }
    
    // Finds all conversations initiated in background sorted by date of most recent message
    func findConversationParticipants() {
        
        PFCloud.callFunctionInBackground("findConversationParticipants", withParameters: [:]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error == nil {
                self.conversationParticipantList = result as! NSArray
                self.findConversations()
            } else {
                print(error)
            }
        }
    }

}
