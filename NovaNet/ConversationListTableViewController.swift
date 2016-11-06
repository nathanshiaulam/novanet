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
    let defaults:UserDefaults = UserDefaults.standard

    // Sets up conversation lists to load in later
    var conversationList:[PFObject]!
    var conversationParticipantList:[PFObject]!
    var otherProfileList:[PFObject]!
    var imageList:[UIImage?]!
    var nextImage:UIImage!
    var formattedImages:[UIImage?] = [UIImage]()
    var backgroundLabel = UILabel()
    var backgroundView = UIView()
    var backgroundImage = UIImageView()
    let button = UIButton(type: UIButtonType.system) as UIButton
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    override func viewDidLoad() {
        super.viewDidLoad()
        conversationList = [PFObject]()
        conversationParticipantList = [PFObject]()
        otherProfileList = [PFObject]()
        imageList = [UIImage?]()
        nextImage = UIImage()

        self.tableView.rowHeight = 75.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationListTableViewController.loadConversations), name: NSNotification.Name(rawValue: "loadConversations"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationListTableViewController.phoneVibrate), name: NSNotification.Name(rawValue: "phoneVibrate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationListTableViewController.goToMessageVC), name: NSNotification.Name(rawValue: "goToMessageVC"), object: nil)

        self.tableView.tableFooterView = UIView()
        let refreshControl = UIRefreshControl()
        self.tabBarController?.navigationItem.title = "MESSAGES"
        loadConversations()

        // Sets up refresh control on pull down so that it calls findUsersInRange
        refreshControl.addTarget(self, action: #selector(ConversationListTableViewController.loadConversations), for:UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!self.userLoggedIn()) {
            conversationList = [PFObject]()
            conversationParticipantList = [PFObject]()
            otherProfileList = [PFObject]()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toMessageVC" {
            let destinationVC = segue.destination.childViewControllers.first as! MessagerViewController
            destinationVC.nextImage = self.nextImage
        }
    }
    
    
    func switchToFinder(_ sender:UIButton!) {
        let tb:UITabBarController! = self.parent as! UITabBarController
        tb.selectedIndex = 0
    }
    
    
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let screenWidth = Constants.ScreenDimensions.screenWidth
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
       
        let imageHeight = screenHeight / 7.0
        let buttonHeight:CGFloat = 44.0
        let buttonWidth = screenWidth * 0.7
        var fontSize:CGFloat = 13.0
        let midHeight = (screenHeight - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!) * 0.5 - imageHeight * 0.7
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
            backgroundLabel.frame = CGRect(x: screenWidth * 0.5, y: midHeight, width:imageHeight * aspectRatio * 1.2, height: imageHeight)
            backgroundLabel.numberOfLines = 0
            backgroundLabel.textAlignment = NSTextAlignment.left
            backgroundLabel.sizeToFit()
            backgroundView.addSubview(backgroundLabel)

            button.frame = CGRect(x: screenWidth * 0.5 - buttonWidth * 0.5, y: midHeight * 1.6, width: buttonWidth, height: buttonHeight)
            button.backgroundColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            button.setTitle("FIND NOVAS", for: UIControlState())
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.layer.cornerRadius = 5
            button.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: 18.0)
            button.addTarget(self, action: #selector(ConversationListTableViewController.switchToFinder(_:)), for: UIControlEvents.touchUpInside)
            backgroundView.addSubview(button)
            
            backgroundView.backgroundColor = Utilities().UIColorFromHex(0xFBFBFB, alpha: 1.0)

            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            tableView.backgroundView = backgroundView
        } else {

            backgroundLabel.isHidden = true
            backgroundImage.isHidden = true
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        }

        return conversationList.count
    }
    
    // Return the number of sections.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatCellIdentifier:String = "ChatCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCellIdentifier, for: indexPath) as! ConversationTableViewCell
        manageiOSModelTypeCellLabels(cell)
        imageList = [UIImage?](repeating: nil, count: otherProfileList.count)
        if (conversationList.count > 0) {

            let conversationParticipant: AnyObject = conversationParticipantList[indexPath.row]
            let conversation: AnyObject = conversationList[indexPath.row]
            let profile:AnyObject = otherProfileList[indexPath.row]
            

            // Stores variables to mark unread messages and most recent message
            let readConversationCount:Int = conversationParticipant["ReadMessageCount"] as! Int
            let conversationCount:Int = conversation["MessageCount"] as! Int
            var recentDate:Date = Date()
            var recentMessage=""
            if let message:String = conversation["RecentMessage"] as? String {
                recentMessage = message
                recentDate = conversation["MostRecent"] as! Date
            }
            cell.nameLabel.text = profile["Name"] as? String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d|h:mm a"
            
            let dateString = dateFormatter.string(from: recentDate)
            let dateComponents = dateString.characters.split{$0 == "|"}.map(String.init)
            
            if ((Date().hoursFrom(recentDate)) > 24) {
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
            cell.recentMessageLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            cell.recentMessageLabel.sizeToFit()

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
                self.imageList[(indexPath as NSIndexPath).row] = UIImage(named: "selectImage")!
            }
            
            cell.profileImage.isHidden = false
            cell.recentMessageLabel.isHidden = false
            cell.nameLabel.isHidden = false
        } else {
                cell.profileImage.isHidden = true
                cell.recentMessageLabel.isHidden = true
                cell.nameLabel.isHidden = true
        }
        
        return cell
    }
    func manageiOSModelTypeCellLabels(_ cell: ConversationTableViewCell) {
        if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_4_HEIGHT) {
            cell.nameLabel.font = cell.nameLabel.font.withSize(12.0)
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.withSize(10.0)
            return
        } else if (Constants.ScreenDimensions.screenHeight == Constants.ScreenDimensions.IPHONE_5_HEIGHT) {
            cell.nameLabel.font = cell.nameLabel.font.withSize(14.0)
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.withSize(10.0)
            return
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            cell.nameLabel.font = cell.nameLabel.font.withSize(20.0)
            cell.recentMessageLabel.font = cell.recentMessageLabel.font.withSize(14.0)
            return
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile: PFObject = otherProfileList[(indexPath as NSIndexPath).row] 
        let image: UIImage! = imageList[(indexPath as NSIndexPath).row] as UIImage!
        if ((image) != nil) {
            self.nextImage = image
        } else {
            self.nextImage = UIImage(named: "selectImage")!
        }
        
        // Sets values for selected user
        prepareDataStore(profile)
        self.performSegue(withIdentifier: "toMessageVC", sender: self)
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
    
    // Vibrates the phone when receives message
    func phoneVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
    
    func goToMessageVC() {
        self.performSegue(withIdentifier: "toMessageVC", sender: self)
    }

    // Calls main helper functions to load all conversations
    func loadConversations() {
        findConversationParticipants()
    }
    
    // Finds the list of IDs of the other conversation participants in the area
    func findOtherProfiles() {
        let otherIDs:NSMutableArray = NSMutableArray()
        for i in 0..<conversationParticipantList.count {
            let participant = conversationParticipantList[i] 
            otherIDs.add(participant["OtherUser"]!)
        }
        let query = PFQuery(className: "Profile")
        query.whereKey("ID", containedIn: otherIDs as [AnyObject])
        query.order(byDescending: "MostRecent")
        
        query.findObjectsInBackground(block: {
            (objects, error) -> Void in
            if error == nil {
                self.otherProfileList = objects as! [PFObject]!
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            } else {
                print(error)
            }
        })
    }
    
    // Finds all conversations initiated in background sorted by date of most recent message
    func findConversations() {
        PFCloud.callFunction(inBackground: "findConversations", withParameters: [:]) {
            (result, error) -> Void in
            if error == nil {
                self.conversationList = result as! [PFObject]!
                self.findOtherProfiles()
            } else {
                print(error)
            }
        }
    }
    
    // Finds all conversations initiated in background sorted by date of most recent message
    func findConversationParticipants() {
        
        PFCloud.callFunction(inBackground: "findConversationParticipants", withParameters: [:]) {
            (result, error) -> Void in
            if error == nil {
                self.conversationParticipantList = result as! [PFObject]
                self.findConversations()
            } else {
                print(error)
            }
        }
    }

}
