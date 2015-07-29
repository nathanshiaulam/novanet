//
//  MessagerViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/23/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//
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
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationController?.navigationBar.barTintColor = UIColorFromHex(0x555555, alpha: 1.0);
        self.title = defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey);
        
        self.userName = PFUser.currentUser()!.objectId!;
        self.selectedUsername = defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey)!;
        
        automaticallyScrollsToMostRecentMessage = true;
        inputToolbar.contentView.leftBarButtonItem = nil;
        
        // User IDs are used as sender/recipient tags
        self.senderDisplayName = defaults.stringForKey(Constants.UserKeys.nameKey);
        self.senderId = self.userName;
        
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
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        showTypingIndicator = !showTypingIndicator;
        scrollToBottomAnimated(true);
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
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count;
    }
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound();
        sendMessage(text, senderId: senderId, senderDisplayName: senderDisplayName, date: date);
    }
    
    func sendMessage(text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text);
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var DateInFormat = dateFormatter.stringFromDate(date);
        println("hialsdkhglsad");

        var name:String = defaults.stringForKey(Constants.SelectedUserKeys.selectedNameKey)!;
        println("hidadsfdsafalsdkhglsad");

        let data = [
            "alert":text,
            "id": PFUser.currentUser()?.objectId,
            "date": DateInFormat,
            "name": name,
        ]
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
                message["Sender"] = senderId;
                message["Date"] = date;
                message["Text"] = text;
                message["Recipient"] = self.defaults.stringForKey(Constants.SelectedUserKeys.selectedIdKey);
                message.saveInBackgroundWithBlock {
                    (succeded, error) -> Void in
                    if error == nil {
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
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }

    

}
