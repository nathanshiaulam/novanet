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
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var userName = ""
    var selectedId = ""
    var messages = [JSQMessage]()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: Utilities().UIColorFromHex(0xAAAAAA, alpha: 1.0))
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: Utilities().UIColorFromHex(0xFC6706, alpha: 0.95))
    
    let defaults:UserDefaults = UserDefaults.standard
    
    var nextImage:UIImage? = UIImage()
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    func moveToProfile(_ button: UIButton) {
        self.performSegue(withIdentifier: "toSelectedProfile", sender: self)
    }
    
    func receivedMessagePressed(_ sender: UIBarButtonItem) {
        showTypingIndicator = !showTypingIndicator
        scrollToBottom(animated: true)
    }

    // Gets an NSDate from a string of specific format
    func dateFromString(_ date: String, format: String) -> Date {
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.date(from: date)!
    }
    
    // Loads data for message when remote push notification sent
    func loadData() {
        var recentDate:Date = Date()
        var recentText:String = String()
        // Loads payload information
        if let payload: AnyObject = defaults.object(forKey: Constants.TempKeys.notificationPayloadKey) as AnyObject? {
            self.title = payload["name"] as? String
            self.selectedId = payload["id"] as! String
            recentDate = dateFromString(payload["date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            recentText = payload["text"] as! String
        }
        
        // Adds in the new message from the push notification
        let fullmessage = JSQMessage(senderId: selectedId, senderDisplayName: selectedId, date: recentDate, text: recentText)
        if (!self.messages.contains(fullmessage!)) {
            self.messages += [fullmessage!] as [JSQMessage]
        }
        
        self.collectionView!.reloadData()
        
        updateConversation(recentDate, text: recentText)
    }
    
    
    // Find all previous messages when needed to load messages
    func findMessages(_ senderId: String!, selectedId: String!) {
        // Generates queries based off of both users to load messages
        let query1 = PFQuery(className: "Message")
        query1.whereKey("Sender", equalTo: senderId)
        query1.whereKey("Recipient", equalTo: selectedId)
        
        let query2 = PFQuery(className: "Message")
        query2.whereKey("Sender", equalTo: selectedId)
        query2.whereKey("Recipient", equalTo: senderId)
        
        let queryAll = PFQuery.orQuery(withSubqueries: [query1, query2])
        queryAll.order(byAscending: "Date")
        queryAll.limit = 1000
        
        queryAll.findObjectsInBackground {
            (messages, error) -> Void in
            if (error != nil || messages == nil) {
                print(error)
            } else if let messages = messages as? [PFObject]{
                var recentDate:Date = Date()
                var recentText:String = String()
                var sender:String = String()
                
               // Adds in all messages and reloads messages
                for message in messages {
                    recentText = message["Text"] as! String
                    sender = message["Sender"] as! String
                    recentDate = message["Date"] as! Date
                    let fullmessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: recentDate, text: recentText)
                    self.messages += [fullmessage!] as [JSQMessage]
                }
                self.collectionView!.reloadData()
                
                // Update own counters if the conversation has begun so the number of messages
                // read matches the number of messages in client
                if (messages.count > 0) {
                    self.updateConversation(recentDate, text: recentText)
                }
                if (messages.count == 0) {
                    let name = self.defaults.string(forKey: Constants.SelectedUserKeys.selectedNameKey)
                    let firstName = name!.components(separatedBy: ",")[0]
                    let textView = self.inputToolbar!.contentView.textView!

                    textView.text = "Hey " + firstName + "! " + self.defaults.string(forKey: Constants.UserKeys.greetingKey)!
                    NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: textView)
                    textView.becomeFirstResponder()
                    self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
                }
            }
        }

    }
    // Sends message when message button pressed. Creates JSQMessage and adds to queue.
    func sendMessage(_ text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        
        // Format date for push notification
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let DateInFormat = dateFormatter.string(from: date)
        
        // Formats text and payload for push notification
        let ownName:String = defaults.string(forKey: Constants.UserKeys.nameKey)!
        let fulltext:String! = ownName + ": " + text as String
        if let id = PFUser.current()?.objectId {
            let data = [
                "alert":fulltext,
                "text": text,
                "id": id,
                "date": DateInFormat,
                "name": ownName,
            ] as [String : Any]
            
            // Create push notification and push message and updates conversation counters
            sendPush(text, senderId: senderId, date: date, data: data, newMessage: newMessage!)
        }
    }
    
    
    // Creates and sends push notification while saving message to backend
    func sendPush(_ text: String!, senderId: String!, date: Date!, data: [AnyHashable: Any]!, newMessage: JSQMessage) {
        let push = PFPush()
        let selectedId = defaults.string(forKey: Constants.SelectedUserKeys.selectedIdKey)
        // Creates inner query to send push to right user
        let innerQuery : PFQuery = PFUser.query()!
        innerQuery.whereKey("objectId", equalTo: selectedId!)
        
        // Set our Installation query
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", matchesQuery: innerQuery)
        push.setQuery(pushQuery)
        push.setData(data)
        push.sendInBackground {
            (succeeded, error) -> Void in
            if (succeeded) {

                // Saves message to load for conversation
                let message = PFObject(className: "Message")

                message["Sender"] = senderId
                message["Date"] = date
                message["Text"] = text
                message["Recipient"] = selectedId
                
                message.saveInBackground {
                    (succeded, error) -> Void in
                    if error == nil {
                        // If there are no messages and the conversation has just started, create a new conversation
                        if self.messages.count == 0 {
                            self.messages += [newMessage] // Need to include on the inside so the initial conditions are met for no. of messages
                            self.createConversation(date, text: text)
                        }
                        // Otherwise, there already exists a conversation between the two. Query for the conversation and update counters
                        else {
                            self.messages += [newMessage] // Need to include on the inside so the initial conditions are met for no. of messages
                            self.updateConversation(date, text: text)
                        }
                        
                        // Add in message and reload new data/send message
                        self.collectionView!.reloadData()
                        self.finishSendingMessage()
                    } else {
                        print("fail")

                        let errorString = (error as! NSError).userInfo["error"] as! NSString
                        let alert = UIAlertController(title: "Message not sent.", message: errorString as String, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil))
                    }
                }
            }
        }
        
    }
    
    // Create conversation participants for each conversation
    func createConversationParticipant(_ conversation: PFObject!, date: Date!) {
        // Creates Conversation Participant object for self
        let conversationParticipantSelf = PFObject(className: "ConversationParticipant")
        conversationParticipantSelf["ReadMessageCount"] = 1
        conversationParticipantSelf["User"] = self.senderId
        conversationParticipantSelf["OtherUser"] = self.selectedId
        conversationParticipantSelf["ConversationID"] = conversation.objectId
        conversationParticipantSelf.saveInBackground()
        
        // Creates Conversation Participant object for recipient
        let conversationParticipantOther = PFObject(className: "ConversationParticipant")
        conversationParticipantOther["ReadMessageCount"] = 0 // Set to zero if recipient hasn't read message yet
        conversationParticipantOther["User"] = self.selectedId
        conversationParticipantOther["OtherUser"] = self.senderId
        conversationParticipantOther["ConversationID"] = conversation.objectId
        conversationParticipantOther.saveInBackground()
    }
    
    // Creates a conversation if first message sent
    func createConversation(_ date: Date!, text: String!) {
        
        // Sort IDs so there's order for future queries
        var participants = [senderId, selectedId]
        participants = participants.sorted(by: {$0!.localizedCaseInsensitiveCompare($1!) == ComparisonResult.orderedAscending})
        
        // Creates Conversation object if both are created successfully
        let conversation = PFObject(className: "Conversation")
        conversation["FirstParticipant"] = participants[0]
        conversation["SecondParticipant"] = participants[1]
        conversation["MessageCount"] = 1
        if (date != nil) {
            conversation["MostRecent"] = date
            conversation["RecentMessage"] = text
        }
        conversation.saveInBackground {
            (success, error) -> Void in
             if (error == nil) {
                self.createConversationParticipant(conversation, date: date)
                self.updateProfileDates(date)
            }
        }
    }
    
    // Update dates for each user's profile so that the conversations are sorted accordingly
    func updateProfileDates(_ date: Date!) {
        // Queries for sender's profile to update date
        let senderProfileQuery = PFQuery(className: "Profile")
        senderProfileQuery.whereKey("ID", equalTo: self.senderId)
        
        senderProfileQuery.getFirstObjectInBackground {
            (profile: AnyObject?, error: Error?) -> Void in
            if error == nil {
                let prof1:PFObject = profile as! PFObject
                let profDate:Date! = prof1["MostRecent"] as? Date
                if (profDate != nil) {
                    if date.timeIntervalSince(profDate) > 0 {
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
        let selectedProfileQuery = PFQuery(className: "Profile")
        selectedProfileQuery.whereKey("ID", equalTo: self.selectedId)
        
        selectedProfileQuery.getFirstObjectInBackground {
            (profile: AnyObject?, error: Error?) -> Void in
            if error == nil {
                let prof2:PFObject = profile as! PFObject
                
                prof2["MostRecent"] = date
                prof2.saveInBackground()
            }
        }
    }
    
    // Update conversation participant of current user
    func updateConversationParticipant(_ conversation: PFObject!, date: Date!) {
        let query = PFQuery(className: "ConversationParticipant")
        query.whereKey("User", equalTo: self.senderId)
        query.whereKey("ConversationID", equalTo: conversation.objectId!)
        query.getFirstObjectInBackground {
            (convPart: PFObject?, error: Error?) -> Void in
            if (error != nil || convPart == nil) {
                print(error)
            } else if let convPart = convPart {
                convPart["ReadMessageCount"] = self.messages.count
                if (date != nil) {
                    convPart["MostRecent"] = date
                }
                convPart.saveInBackground()
            }
        }
    }

    // Modifies conversation by adding in message and incrementing counters properly
    func updateConversation(_ date: Date!, text: String!) {
        
        let ownID = PFUser.current()?.objectId
        let otherID = defaults.string(forKey: Constants.SelectedUserKeys.selectedIdKey)
        
        var participants = [ownID, otherID]
        participants = participants.sorted(by: {$0!.localizedCaseInsensitiveCompare($1!) == ComparisonResult.orderedAscending})
        
        let query = PFQuery(className: "Conversation")
        query.whereKey("FirstParticipant", equalTo: participants[0]!)
        query.whereKey("SecondParticipant", equalTo: participants[1]!)
        
        query.getFirstObjectInBackground {
            (conversation: PFObject?, error: Error?) -> Void in
            if (error != nil || conversation == nil) {
                print(error)
            } else if let conversation = conversation {
                conversation["MessageCount"] = self.messages.count
                if (date != nil) {
                    conversation["MostRecent"] = date
                    conversation["RecentMessage"] = text
                }
                conversation.saveInBackground {
                    (success, error) -> Void in
                    if (error == nil) {
                        self.updateConversationParticipant(conversation, date: date)
                        self.updateProfileDates(date)
                    }
                }
            }
        }
    }
    
    /*-------------------------------- JSQMessager DELEGATE METHODS ------------------------------------*/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.inputToolbar!.contentView!.textView!.text.characters.count == 0) {
            self.inputToolbar!.contentView!.rightBarButtonItem!.isEnabled = false
        } else {
            self.inputToolbar!.contentView!.rightBarButtonItem!.isEnabled = true
        }
        self.view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = self.messages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text, senderId: senderId, senderDisplayName: senderDisplayName, date: Date())
        button.isEnabled = false
    }
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
//        self.inputToolbar!.contentView!.textView!.text = Constants.ConstantStrings.fikaText
    }
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        
        // Ensures that it loads the data when you receive a message while in view
        NotificationCenter.default.addObserver(self, selector: #selector(MessagerViewController.loadData), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        let button =  UIButton(type: UIButtonType.custom) as UIButton
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40) as CGRect
        button.titleLabel?.font = UIFont(name: "BrandonGrotesque-Bold", size: 18)
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitle(defaults.string(forKey: Constants.SelectedUserKeys.selectedNameKey), for: UIControlState())
        button.addTarget(self, action: #selector(MessagerViewController.moveToProfile(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.titleView = button
        
        inputToolbar!.contentView!.leftBarButtonItem = nil
        self.inputToolbar!.contentView!.textView!.delegate = self
        self.automaticallyScrollsToMostRecentMessage = false
        inputToolbar.contentView.rightBarButtonItem.setTitle("SEND", for: UIControlState())
        inputToolbar.contentView.rightBarButtonItem.titleLabel!.font = UIFont(name: "BrandonGrotesque-Bold", size: 14.0)
        inputToolbar.contentView.rightBarButtonItem.setTitleColor(Utilities().UIColorFromHex(0xFC6706, alpha: 1.0), for: UIControlState())

        // User IDs are used as sender/recipient tags
        self.senderDisplayName = defaults.string(forKey: Constants.UserKeys.nameKey)
        
        self.senderId = PFUser.current()!.objectId
        self.selectedId = defaults.string(forKey: Constants.SelectedUserKeys.selectedIdKey)!
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Generates queries based off of both users to load messages
        findMessages(senderId, selectedId: selectedId)
        collectionView!.collectionViewLayout.springinessEnabled = true
        self.automaticallyScrollsToMostRecentMessage = true
        self.collectionView!.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toSelectedProfile" {
            let destinationVC = segue.destination as! SelectedProfileViewController
            destinationVC.image = self.nextImage
            destinationVC.fromMessage = true
        }
    }
    
    
    
    
    
}
