//
//  MessagerViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/23/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//
//  Need to add "Read By" functionality for where the user loads in data
//  of the message that was recently loaded from the server.
//
//  Also need to add in functionality for the Home View Controller where
//  it queries all conversations and compares the counters so that it always
//  returns what's needed
import UIKit
import Parse
import Bolts
import CoreLocation

class MessagerViewController: JSQMessagesViewController {
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    var userName = "";
    var selectedId = "";
    var messages = [JSQMessage]();
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/244, alpha: 1.0));
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor());
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    var nextImage:UIImage? = UIImage();
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    func moveToProfile(button: UIButton) {
        self.performSegueWithIdentifier("toSelectedProfile", sender: self);
    }
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        showTypingIndicator = !showTypingIndicator;
        scrollToBottomAnimated(true);
    }
    
    // Converts to RGB from Hex
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // Gets an NSDate from a string of specific format
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    
    // Loads data for message when remote push notification sent
    func loadData() {
        var recentDate:NSDate = NSDate();
        var recentText:String = String();
        // Loads payload information
        if let payload: AnyObject = defaults.objectForKey(Constants.TempKeys.notificationPayloadKey) {
            self.title = payload["name"] as? String;
            self.selectedId = payload["id"] as! String;
            recentDate = dateFromString(payload["date"] as! String, format: "yyyy-MM-dd HH:mm:ss");
            recentText = payload["text"] as! String;
        }
        
        // Adds in the new message from the push notification
        let fullmessage = JSQMessage(senderId: selectedId, senderDisplayName: selectedId, date: recentDate, text: recentText);
        if (!self.messages.contains(fullmessage)) {
            self.messages += [fullmessage];
        }
        
        self.collectionView!.reloadData();
        
        updateConversation(recentDate, text: recentText);
    }
    
    
    // Find all previous messages when needed to load messages
    func findMessages(senderId: String!, selectedId: String!) {
        // Generates queries based off of both users to load messages
        let query1 = PFQuery(className: "Message");
        query1.whereKey("Sender", equalTo: senderId);
        query1.whereKey("Recipient", equalTo: selectedId);
        
        let query2 = PFQuery(className: "Message");
        query2.whereKey("Sender", equalTo: selectedId);
        query2.whereKey("Recipient", equalTo: senderId);
        
        let queryAll = PFQuery.orQueryWithSubqueries([query1, query2]);
        queryAll.orderByAscending("Date");
        queryAll.limit = 1000;
        
        queryAll.findObjectsInBackgroundWithBlock {
            (messages, error) -> Void in
            if (error != nil || messages == nil) {
                print(error);
            } else if let messages = messages as? [PFObject]{
                var recentDate:NSDate = NSDate();
                var recentText:String = String();
                var sender:String = String();
                
               // Adds in all messages and reloads messages
                for message in messages {
                    recentText = message["Text"] as! String;
                    sender = message["Sender"] as! String;
                    recentDate = message["Date"] as! NSDate;
                    let fullmessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: recentDate, text: recentText);
                    self.messages += [fullmessage];
                }
                self.collectionView!.reloadData();
                
                // Update own counters if the conversation has begun so the number of messages
                // read matches the number of messages in client
                if (messages.count > 0) {
                    self.updateConversation(recentDate, text: recentText);
                }
                if (messages.count == 0) {
                    let name = self.defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey);
                    let firstName = name!.componentsSeparatedByString(",")[0];
                    self.inputToolbar!.contentView!.textView!.text = "Hey " + firstName + "!, " + self.defaults.stringForKey(Constants.UserKeys.greetingKey)!;
                }
            }
        }

    }
    // Sends message when message button pressed. Creates JSQMessage and adds to queue.
    func sendMessage(text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text);
        
        // Format date for push notification
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let DateInFormat = dateFormatter.stringFromDate(date);
        
        // Formats text and payload for push notification
        let ownName:String = defaults.stringForKey(Constants.UserKeys.nameKey)!;
        let fulltext:String! = ownName + ": " + text as String;
        let data = [
            "alert":fulltext,
            "text": text,
            "id": PFUser.currentUser()?.objectId,
            "date": DateInFormat,
            "name": ownName,
        ]
        
        // Create push notification and push message and updates conversation counters
        sendPush(text, senderId: senderId, date: date, data: data, newMessage: newMessage);
    }
    
    
    // Creates and sends push notification while saving message to backend
    func sendPush(text: String!, senderId: String!, date: NSDate!, data: [NSObject:AnyObject]!, newMessage: JSQMessage) {
        let push = PFPush();
        let selectedId = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey);
        // Creates inner query to send push to right user
        let innerQuery : PFQuery = PFUser.query()!
        innerQuery.whereKey("objectId", equalTo: selectedId!);
        
        // Set our Installation query
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", matchesQuery: innerQuery)
        push.setQuery(pushQuery)
        push.setData(data);
        
        push.sendPushInBackgroundWithBlock {
            (succeeded, error) -> Void in
            if (succeeded) {
                
                // Saves message to load for conversation
                let message = PFObject(className: "Message");

                message["Sender"] = senderId;
                message["Date"] = date;
                message["Text"] = text;
                message["Recipient"] = selectedId;
                
                message.saveInBackgroundWithBlock {
                    (succeded, error) -> Void in
                    if error == nil {
                        // If there are no messages and the conversation has just started, create a new conversation
                        if self.messages.count == 0 {
                            self.messages += [newMessage]; // Need to include on the inside so the initial conditions are met for no. of messages
                            self.createConversation(date, text: text);
                        }
                        // Otherwise, there already exists a conversation between the two. Query for the conversation and update counters
                        else {
                            self.messages += [newMessage]; // Need to include on the inside so the initial conditions are met for no. of messages
                            self.updateConversation(date, text: text);
                        }
                        
                        // Add in message and reload new data/send message
                        self.collectionView!.reloadData();
                        self.finishSendingMessage();
                    } else {
                        let errorString = error!.userInfo["error"] as! NSString;
                        let alert = UIAlertController(title: "Message not sent.", message: errorString as String, preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: nil));
                    }
                }
            }
        }
        
    }
    
    // Create conversation participants for each conversation
    func createConversationParticipant(conversation: PFObject!, date: NSDate!) {
        // Creates Conversation Participant object for self
        let conversationParticipantSelf = PFObject(className: "ConversationParticipant");
        conversationParticipantSelf["ReadMessageCount"] = 1;
        conversationParticipantSelf["User"] = self.senderId;
        conversationParticipantSelf["OtherUser"] = self.selectedId;
        conversationParticipantSelf["ConversationID"] = conversation.objectId;
        conversationParticipantSelf.saveInBackground();
        
        // Creates Conversation Participant object for recipient
        let conversationParticipantOther = PFObject(className: "ConversationParticipant");
        conversationParticipantOther["ReadMessageCount"] = 0; // Set to zero if recipient hasn't read message yet
        conversationParticipantOther["User"] = self.selectedId;
        conversationParticipantOther["OtherUser"] = self.senderId;
        conversationParticipantOther["ConversationID"] = conversation.objectId;
        conversationParticipantOther.saveInBackground();
    }
    
    // Creates a conversation if first message sent
    func createConversation(date: NSDate!, text: String!) {
        
        // Sort IDs so there's order for future queries
        var participants = [senderId, selectedId];
        participants = participants.sort({$0!.localizedCaseInsensitiveCompare($1!) == NSComparisonResult.OrderedAscending});
        
        // Creates Conversation object if both are created successfully
        let conversation = PFObject(className: "Conversation");
        conversation["FirstParticipant"] = participants[0];
        conversation["SecondParticipant"] = participants[1];
        conversation["MessageCount"] = 1;
        if (date != nil) {
            conversation["MostRecent"] = date;
            conversation["RecentMessage"] = text;
        }
        conversation.saveInBackgroundWithBlock {
            (success, error) -> Void in
             if (error == nil) {
                self.createConversationParticipant(conversation, date: date)
                self.updateProfileDates(date);
            }
        }
    }
    
    // Update dates for each user's profile so that the conversations are sorted accordingly
    func updateProfileDates(date: NSDate!) {
        // Queries for sender's profile to update date
        let senderProfileQuery = PFQuery(className: "Profile");
        senderProfileQuery.whereKey("ID", equalTo: self.senderId);
        
        senderProfileQuery.getFirstObjectInBackgroundWithBlock {
            (profile: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                let prof1:PFObject = profile as! PFObject;
                let profDate:NSDate! = prof1["MostRecent"] as? NSDate
                if (profDate != nil) {
                    if date.timeIntervalSinceDate(profDate) > 0 {
                        prof1["MostRecent"] = date
                        prof1.saveInBackground()
                    }
                } else {
                    prof1["MostRecent"] = date
                    prof1.saveInBackground()
                }
               
            }
        }
        
        // Queries for recipient's profile to update date
        let selectedProfileQuery = PFQuery(className: "Profile");
        selectedProfileQuery.whereKey("ID", equalTo: self.selectedId);
        
        selectedProfileQuery.getFirstObjectInBackgroundWithBlock {
            (profile: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                let prof2:PFObject = profile as! PFObject;
                
                prof2["MostRecent"] = date;
                prof2.saveInBackground();
            }
        }
    }
    
    // Update conversation participant of current user
    func updateConversationParticipant(conversation: PFObject!, date: NSDate!) {
        let query = PFQuery(className: "ConversationParticipant");
        query.whereKey("User", equalTo: self.senderId);
        query.whereKey("ConversationID", equalTo: conversation.objectId!)
        query.getFirstObjectInBackgroundWithBlock {
            (convPart: PFObject?, error: NSError?) -> Void in
            if (error != nil || convPart == nil) {
                print(error);
            } else if let convPart = convPart {
                convPart["ReadMessageCount"] = self.messages.count;
                if (date != nil) {
                    convPart["MostRecent"] = date;
                }
                convPart.saveInBackground()
            }
        }
    }

    // Modifies conversation by adding in message and incrementing counters properly
    func updateConversation(date: NSDate!, text: String!) {
        
        let ownID = PFUser.currentUser()?.objectId;
        let otherID = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey);
        
        var participants = [ownID, otherID];
        participants = participants.sort({$0!.localizedCaseInsensitiveCompare($1!) == NSComparisonResult.OrderedAscending});
        
        let query = PFQuery(className: "Conversation");
        query.whereKey("FirstParticipant", equalTo: participants[0]!);
        query.whereKey("SecondParticipant", equalTo: participants[1]!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (conversation: PFObject?, error: NSError?) -> Void in
            if (error != nil || conversation == nil) {
                print(error);
            } else if let conversation = conversation {
                conversation["MessageCount"] = self.messages.count;
                if (date != nil) {
                    conversation["MostRecent"] = date;
                    conversation["RecentMessage"] = text;
                }
                conversation.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (error == nil) {
                        self.updateConversationParticipant(conversation, date: date);
                        self.updateProfileDates(date);
                    }
                }
            }
        }
    }
    
    /*-------------------------------- JSQMessager DELEGATE METHODS ------------------------------------*/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (self.inputToolbar!.contentView!.textView!.text.characters.count == 0) {
            self.inputToolbar!.contentView!.rightBarButtonItem!.enabled = false;
        } else {
            self.inputToolbar!.contentView!.rightBarButtonItem!.enabled = true;
        }
        self.view.endEditing(true);
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = self.messages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count;
    }
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound();
        sendMessage(text, senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate());
        button.enabled = false;
    }
    override func didPressAccessoryButton(sender: UIButton!) {
        
//        self.inputToolbar!.contentView!.textView!.text = Constants.ConstantStrings.fikaText;
    }
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad();
        

        self.navigationController?.navigationBar.barTintColor = UIColorFromHex(0xFC6706, alpha: 1.0)
        
        // Ensures that it loads the data when you receive a message while in view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagerViewController.loadData), name: "loadData", object: nil);
        let button =  UIButton(type: UIButtonType.Custom) as UIButton;
        button.frame = CGRectMake(0, 0, 100, 40) as CGRect
        button.titleLabel?.font = UIFont(name: "OpenSans", size: 18)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        button.setTitle(defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(MessagerViewController.moveToProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.titleView = button
        
        inputToolbar!.contentView!.leftBarButtonItem = nil;
        self.inputToolbar!.contentView!.textView!.delegate = self;
        self.automaticallyScrollsToMostRecentMessage = true
        inputToolbar.contentView.rightBarButtonItem.setTitle("SEND", forState: UIControlState.Normal)
        inputToolbar.contentView.rightBarButtonItem.titleLabel!.font = UIFont(name: "OpenSans", size: 14.0)
        inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColorFromHex(0xFC6706, alpha: 1.0), forState: UIControlState.Normal)

        // User IDs are used as sender/recipient tags
        self.senderDisplayName = defaults.stringForKey(Constants.UserKeys.nameKey)
        
        self.senderId = PFUser.currentUser()!.objectId;
        self.selectedId = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey)!;
        
        // Generates queries based off of both users to load messages
        findMessages(senderId, selectedId: selectedId)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        
        collectionView!.collectionViewLayout.springinessEnabled = true
        self.automaticallyScrollsToMostRecentMessage = true
        self.collectionView!.reloadData();
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toSelectedProfile" {
            let destinationVC = segue.destinationViewController as! SelectedProfileViewController
            destinationVC.image = self.nextImage;
            destinationVC.fromMessage = true;
        }
    }
    
    
    
    
    
}
