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
    
    var userName = "";
    var selectedUsername = "";
    var messages = [JSQMessage]();
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/244, alpha: 1.0));
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor());
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
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
        
        self.messages = [JSQMessage]();
        if let payload: AnyObject = defaults.objectForKey(Constants.TempKeys.notificationPayloadKey) {
            self.title = payload["name"] as? String;
            self.selectedUsername = payload["id"]as! String;
        }
        self.userName = PFUser.currentUser()!.objectId!;
        
        automaticallyScrollsToMostRecentMessage = true;
        inputToolbar.contentView.leftBarButtonItem = nil;
        
        // User IDs are used as sender/recipient tags
        self.senderDisplayName = defaults.stringForKey(Constants.UserKeys.nameKey);
        self.senderId = self.userName;
        
        // Generates queries based off of both users to load messages
        var query1 = PFQuery(className: "Message");
        query1.whereKey("Sender", equalTo: senderId);
        query1.whereKey("Recipient", equalTo: selectedUsername);
        
        var query2 = PFQuery(className: "Message");
        query2.whereKey("Sender", equalTo: selectedUsername);
        query2.whereKey("Recipient", equalTo:senderId);
        
        var queryAll = PFQuery.orQueryWithSubqueries([query1, query2]);
        queryAll.orderByAscending("Date");
        queryAll.findObjectsInBackgroundWithBlock {
            (NSArray messages, NSError error) -> Void in
            if (error != nil || messages == nil) {
                println(error);
            } else if let messages = messages as? [PFObject]{
                for message in messages { // Adds in all messages
                    var text = message["Text"] as! String;
                    var sender = message["Sender"] as! String;
                    var date = message["Date"] as! NSDate;
                    var fullmessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date, text: text);
                    self.messages += [fullmessage];
                }
                self.collectionView.reloadData(); // Reloads all messages in page
                
                // Update own counters if the conversation has begun so the number of messages
                // read matches the number of messages in client
                if (messages.count > 0) {
                    self.updateConversation(nil);
                }
            }
        }
    }
    
    // Sends message when message button pressed. Creates JSQMessage and adds to queue.
    func sendMessage(text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text);
        
        // Format message payload for push notification
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var DateInFormat = dateFormatter.stringFromDate(date);
        var name:String = defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey)!;
        var ownName:String = defaults.stringForKey(Constants.UserKeys.nameKey)!;
        var fulltext:String! = ownName + ": " + text as String;
        let data = [
            "alert":fulltext,
            "id": PFUser.currentUser()?.objectId,
            "date": DateInFormat,
            "name": name,
//            "badge": "Increment",
        ]
        
        // Create push notification and push message and updates conversation counters
        sendPush(text, senderId: senderId, date: date, data: data, newMessage: newMessage);
    }
    
    // Creates and sends push notification while saving message to backend
    func sendPush(text: String!, senderId: String!, date: NSDate!, data: [NSObject:AnyObject]!, newMessage: JSQMessage) {
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
                println(senderId);
                message["Sender"] = senderId;
                message["Date"] = date;
                message["Text"] = text;
                message["Recipient"] = self.defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey);
                message.saveInBackgroundWithBlock {
                    (succeded, error) -> Void in
                    if error == nil {
                        // If there are no messages and the conversation has just started, create a new conversation
                        if self.messages.count == 0 {
                            self.createConversation(date);
                        }
                        // Otherwise, there already exists a conversation between the two. Query for the conversation and update counters
                        else {
                            self.updateConversation(date);
                        }
                        
                        // Add in message and reload new data/send message
                        self.messages += [newMessage];
                        self.collectionView.reloadData();
                        self.finishSendingMessage();
                    } else {
                        let errorString = error!.userInfo!["error"] as! NSString;
                        var alert = UIAlertController(title: "Message not sent.", message: errorString as String, preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: nil));
                    }
                }
            }
        }
        
    }
    
    // Creates a conversation if first message sent
    func createConversation(date: NSDate!) {
        var ownID = PFUser.currentUser()?.objectId;
        var otherID = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey);
        
        var conversationParticipantSelf = PFObject(className: "ConversationParticipant");
        conversationParticipantSelf["ReadMessageCount"] = 1;
        conversationParticipantSelf["User"] = ownID;
        conversationParticipantSelf["OtherUser"] = otherID;
        conversationParticipantSelf.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (error == nil) {
                var conversationParticipantOther = PFObject(className: "ConversationParticipant");
                conversationParticipantOther["ReadMessageCount"] = 0;
                conversationParticipantOther["User"] = otherID;
                conversationParticipantOther["OtherUser"] = ownID;
                conversationParticipantOther.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (error == nil) {
                        var conversation = PFObject(className: "Conversation");
                        var participants = [ownID, otherID];
                        participants = participants.sorted {$0!.localizedCaseInsensitiveCompare($1!) == NSComparisonResult.OrderedAscending}
                        conversation["FirstParticipant"] = participants[0];
                        conversation["SecondParticipant"] = participants[1];
                        conversation["MessageCount"] = 1;
                        if (date != nil) {
                            conversation["MostRecent"] = date;
                        }
                        conversation.saveInBackgroundWithBlock {
                            (success, error)  -> Void in
                            if (error == nil) {
                                conversationParticipantSelf["ConversationID"] = conversation.objectId;
                                conversationParticipantOther["ConversationID"] = conversation.objectId;
                                conversationParticipantOther.saveInBackground();
                                conversationParticipantSelf.saveInBackground();
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Modifies conversation by adding in message and incrementing counters properly
    func updateConversation(date: NSDate!) {
        
        var ownID = PFUser.currentUser()?.objectId;
        var otherID = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey);
        
        var participants = [ownID, otherID];
        participants = participants.sorted {$0!.localizedCaseInsensitiveCompare($1!) == NSComparisonResult.OrderedAscending}
        
        var query = PFQuery(className: "Conversation");
        query.whereKey("FirstParticipant", equalTo: participants[0]!);
        query.whereKey("SecondParticipant", equalTo: participants[1]!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (conversation: PFObject?, error: NSError?) -> Void in
            if (error != nil || conversation == nil) {
                println(error);
            } else if let conversation = conversation {
                println("hi");
                var conversationID = conversation.objectId;

                conversation["MessageCount"] = self.messages.count;
                if (date != nil) {
                    conversation["MostRecent"] = date;
                }
                conversation.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (error == nil) {
                        var query = PFQuery(className: "ConversationParticipant");
                        query.whereKey("User", equalTo: ownID!);
                        query.whereKey("ConversationID", equalTo: conversationID!)
                        query.getFirstObjectInBackgroundWithBlock {
                            (convPart: PFObject?, error: NSError?) -> Void in
                            if (error != nil || convPart == nil) {
                                println(error);
                            } else if let convPart = convPart {
                                convPart["ReadMessageCount"] = self.messages.count;
                            }
                            convPart?.saveInBackground();
                        }
                    }
                }
            }
        }
    }
    
    /*-------------------------------- JSQMessager DELEGATE METHODS ------------------------------------*/
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        var data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var data = self.messages[indexPath.row]
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
        sendMessage(text, senderId: senderId, senderDisplayName: senderDisplayName, date: date);
    }
    override func didPressAccessoryButton(sender: UIButton!) {
        
        self.inputToolbar.contentView.textView.text = Constants.ConstantStrings.fikaText;
        println(self.inputToolbar.toggleSendButtonEnabled());
    }
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "loadData", object: nil);
        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);
        self.title = defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey);
        
        println(self.messages.count);
        let image = UIImage(named: "fika");
        
        inputToolbar.contentView.leftBarButtonItem.setImage(image, forState: .Normal)
        automaticallyScrollsToMostRecentMessage = true;
        
        // User IDs are used as sender/recipient tags
        self.senderDisplayName = defaults.stringForKey(Constants.UserKeys.nameKey);
        
        self.senderId = PFUser.currentUser()!.objectId;
        self.selectedUsername = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey)!;
        // Generates queries based off of both users to load messages
        var query1 = PFQuery(className: "Message");
        query1.whereKey("Sender", equalTo: senderId);
        query1.whereKey("Recipient", equalTo:selectedUsername);
        
        var query2 = PFQuery(className: "Message");
        query2.whereKey("Sender", equalTo: selectedUsername);
        query2.whereKey("Recipient", equalTo:senderId);
        
        var queryAll = PFQuery.orQueryWithSubqueries([query1, query2]);
        queryAll.orderByAscending("Date");
        
        queryAll.findObjectsInBackgroundWithBlock {
            (NSArray messages, NSError error) -> Void in
            if (error != nil || messages == nil) {
                println(error);
            } else if let messages = messages as? [PFObject]{
                for message in messages {
                    var text = message["Text"] as! String;
                    var sender = message["Sender"] as! String;
                    var date = message["Date"] as! NSDate;
                    var fullmessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date, text: text);
                    self.messages += [fullmessage];
                }
                self.collectionView.reloadData();
                
                // Update own counters if the conversation has begun so the number of messages
                // read matches the number of messages in client
                if (messages.count > 0) {
                    self.updateConversation(nil);
                }
            }
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        self.automaticallyScrollsToMostRecentMessage = true;
        
        self.collectionView.reloadData();
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    
    
    
    
}
