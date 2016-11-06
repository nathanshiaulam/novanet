//
//  EventsFinderTableVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/3/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse
import AudioToolbox

class EventsFinderTableVC: ViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate   {
    
    let defaults:UserDefaults = UserDefaults.standard;
    
    // Sets up pull to refresh
    var refreshControl:UIRefreshControl!
    var eventsList:NSArray!;
    var distList:NSArray!;
    var localEvents:Bool!;
    var oldTitleView:UIView!;
    var selectedEvent:PFObject!;
    
    @IBOutlet weak var eventHeaderView: UIView!

    @IBOutlet weak var memberEventButton: UIButton!
    @IBOutlet weak var localEventButton: UIButton!
    @IBOutlet weak var addEventButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func findLocalEvents(_ sender: UIButton) {
        if localEvents == false {
            localEvents = true;
            let currentFont = localEventButton.titleLabel!.font
            localEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: (currentFont?.pointSize)!)
            
            let otherCurrentFont = memberEventButton.titleLabel!.font
            memberEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: (otherCurrentFont?.pointSize)!)
            
            findAllEvents();
            refreshControl.removeTarget(self, action: #selector(EventsFinderTableVC.findSavedEvents), for: UIControlEvents.valueChanged)
            refreshControl.addTarget(self, action: #selector(EventsFinderTableVC.findAllEvents), for: UIControlEvents.valueChanged)
        }
    }
    
    @IBAction func findMyEvents(_ sender: UIButton) {
        if localEvents == true {
            localEvents = false;
            let currentFont = localEventButton.titleLabel!.font
            localEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: (currentFont?.pointSize)!)
            
            let otherCurrentFont = memberEventButton.titleLabel!.font
            memberEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: (otherCurrentFont?.pointSize)!)
            
            findSavedEvents();
            refreshControl.removeTarget(self, action: #selector(EventsFinderTableVC.findAllEvents), for: UIControlEvents.valueChanged)
            refreshControl.addTarget(self, action: #selector(EventsFinderTableVC.findSavedEvents), for: UIControlEvents.valueChanged)
        }
    }
    // Vibrates the phone when receives message
    func phoneVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    override func viewDidLoad() {
        localEvents = true
        
        eventsList = NSArray()
        distList = NSArray()
        self.tableView.rowHeight = 100.0
        self.tabBarController!.navigationItem.title = "MEETUPS"
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationListTableViewController.phoneVibrate), name: NSNotification.Name(rawValue: "phoneVibrate"), object: nil)
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: eventHeaderView.frame.size.height - width, width:  eventHeaderView.frame.size.width, height: eventHeaderView.frame.size.height)
        border.borderWidth = width
        eventHeaderView.layer.addSublayer(border)
        eventHeaderView.layer.masksToBounds = true
        
        refreshControl = UIRefreshControl()
        self.tableView.tableFooterView = UIView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController!.navigationItem.title = "MEETUPS";
        self.tabBarController!.navigationItem.leftBarButtonItem = addEventButton;
        self.oldTitleView = self.tabBarController!.navigationItem.titleView

        tableView.addSubview(self.refreshControl)
        if localEvents == true {
            findAllEvents();
            refreshControl.removeTarget(self, action: #selector(EventsFinderTableVC.findSavedEvents), for: UIControlEvents.valueChanged)
            refreshControl.addTarget(self, action: #selector(EventsFinderTableVC.findAllEvents), for: UIControlEvents.valueChanged)
            
        } else {
            findSavedEvents();
            refreshControl.removeTarget(self, action: #selector(EventsFinderTableVC.findAllEvents), for: UIControlEvents.valueChanged)
            refreshControl.addTarget(self, action: #selector(EventsFinderTableVC.findSavedEvents), for: UIControlEvents.valueChanged)
        }
        super.viewDidAppear(true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController!.navigationItem.titleView = oldTitleView;
        self.tabBarController!.navigationItem.leftBarButtonItem = nil;
    }
    
    
    
    
    // Find all events within range and with "Local" = true
    // Create a method to parse through each event and return a dict with all the necessary fields
    // List events in time order
    // For each event that you find, check whether or not any of the buttons contain current ID
    // Each of the buttons should only contain one of the ID, so we'll need a method to add in the button pressed and remove the other two

    func findAllEvents() {
        let lat = defaults.double(forKey: Constants.UserKeys.latitudeKey);
        let lon = defaults.double(forKey: Constants.UserKeys.longitudeKey);
        let dist = Constants.DISCOVERY_RADIUS;
        
        PFCloud.callFunction(inBackground: "findAllEvents", withParameters: ["lat": lat, "lon": lon, "dist":dist]) {
            (result, error) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                self.eventsList = result as! NSArray;
                self.findDistList(lon, lat:lat, dist:dist, all:true);
            }
        }
    }
    
    func findSavedEvents() {
        let lat = defaults.double(forKey: Constants.UserKeys.latitudeKey);
        let lon = defaults.double(forKey: Constants.UserKeys.longitudeKey);
        let dist = Constants.DISCOVERY_RADIUS;
        
        PFCloud.callFunction(inBackground: "findSavedEvents", withParameters: [:]) {
            (result, error) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                self.eventsList = result as! NSArray;
                self.findDistList(lon, lat:lat, dist:dist, all:false);
            }
        }
        
    }
    
    func findDistList(_ lon: Double, lat: Double, dist: Int, all:Bool) {
        PFCloud.callFunction(inBackground: "findEventsDist", withParameters: ["lat":lat, "lon":lon, "dist":dist, "all":all]) {
            (result, error) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                self.distList = result as! NSArray;
                self.tableView.reloadData();
                self.refreshControl.endRefreshing();
            }
        }
    }
    
    
    func goingPressed(_ sender: EventAttendanceButton) {
        let maybeButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag + 1) as! EventAttendanceButton
        let notGoingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag + 2)  as! EventAttendanceButton
        
        let event:PFObject! = eventsList[(sender.tag - 100) / 3] as! PFObject;
        
        if (sender.isSelected) {
            var arr:[String]! = event["Going"] as! [String];
            arr = arr.filter() {$0 != PFUser.current()!.objectId};
            event["Going"] = arr;
            event.saveInBackground();
            
        } else  {
            if (maybeButton.isSelected) {
                var arr:[String]! = event["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                event["Maybe"] = arr;
                event.saveInBackground();
                maybeButton.isHighlighted = false;
                maybeButton.isSelected = false;
            }
            if (notGoingButton.isSelected) {
                var arr:[String]! = event["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                event["NotGoing"] = arr;
                event.saveInBackground();
                notGoingButton.isHighlighted = false;
                notGoingButton.isSelected = false;
            }
            var arr:[String]! = event["Going"] as! [String];
            if !arr.contains(PFUser.current()!.objectId!) {
                arr.append(PFUser.current()!.objectId!);
            }
            event["Going"] = arr;
            event.saveInBackground();
            
        }

        sender.isSelected = !sender.isSelected;
    }
    
    func maybePressed(_ sender: EventAttendanceButton) {
        let goingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag - 1) as! EventAttendanceButton
        let notGoingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag + 1)  as! EventAttendanceButton
        
        let event:PFObject! = eventsList[(sender.tag - 100 - 1) / 3] as! PFObject;

        if (sender.isSelected) {
            var arr:[String]! = event["Maybe"] as! [String];
            arr = arr.filter() {$0 != PFUser.current()!.objectId};
            event["Maybe"] = arr;
            event.saveInBackground();
            
        } else  {
            if (goingButton.isSelected) {
                var arr:[String]! = event["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                event["Going"] = arr;
                event.saveInBackground();
                goingButton.isHighlighted = false;
                goingButton.isSelected = false;
            }
            if (notGoingButton.isSelected) {
                var arr:[String]! = event["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                event["NotGoing"] = arr;
                event.saveInBackground();
                notGoingButton.isHighlighted = false;
                notGoingButton.isSelected = false;
            }
            var arr:[String]! = event["Maybe"] as! [String];
            if !arr.contains(PFUser.current()!.objectId!) {
                arr.append(PFUser.current()!.objectId!);
            }
            event["Maybe"] = arr;
            event.saveInBackground();
            
        }
        sender.isSelected = !sender.isSelected;
    }

    func notGoingPressed(_ sender: EventAttendanceButton) {
        let maybeButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag - 1) as! EventAttendanceButton
        let goingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag - 2)  as! EventAttendanceButton
        
        let event:PFObject! = eventsList[(sender.tag - 100 - 2) / 3] as! PFObject;
        
        if (sender.isSelected) {
            var arr:[String]! = event["NotGoing"] as! [String];
            arr = arr.filter() {$0 != PFUser.current()!.objectId};
            event["NotGoing"] = arr;
            event.saveInBackground();
            
        } else  {
            if (maybeButton.isSelected) {
                var arr:[String]! = event["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                event["Maybe"] = arr;
                event.saveInBackground();
                maybeButton.isHighlighted = false;
                maybeButton.isSelected = false;
            }
            if (goingButton.isSelected) {
                var arr:[String]! = event["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                event["Going"] = arr;
                event.saveInBackground();
                goingButton.isHighlighted = false;
                goingButton.isSelected = false;
            }
            var arr:[String]! = event["NotGoing"] as! [String];
            if !arr.contains(PFUser.current()!.objectId!) {
                arr.append(PFUser.current()!.objectId!);
            }
            event["NotGoing"] = arr;
            event.saveInBackground();
        }
        sender.isSelected = !sender.isSelected;
    }
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let backgroundLabel = UILabel()
        let backgroundView = UIView()
        var backgroundImage = UIImageView()
        let button = UIButton(type: UIButtonType.system) as UIButton

        let screenWidth = Constants.ScreenDimensions.screenWidth
        let screenHeight = Constants.ScreenDimensions.screenHeight
        
        
        let imageHeight = screenHeight / 7.0
        let buttonHeight:CGFloat = 44.0
        let buttonWidth = screenWidth * 0.7
        var fontSize:CGFloat = 13.0
        let midHeight = (screenHeight - (self.tabBarController?.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!) * 0.5 - imageHeight * 0.7;
        if (Constants.ScreenDimensions.screenHeight >= Constants.ScreenDimensions.IPHONE_6_HEIGHT) {
            fontSize = 15.0
        }
        
        if (self.eventsList.count == 0) {
            
            let imageName = "about_event.png"
            let image = UIImage(named: imageName)
            backgroundImage = UIImageView(image: image!)
            let aspectRatio = backgroundImage.bounds.width / backgroundImage.bounds.height
            backgroundImage.frame = CGRect(x: screenWidth * 0.5 - imageHeight * aspectRatio * 1.5, y: midHeight, width: imageHeight * aspectRatio, height: imageHeight)
            backgroundView.addSubview(backgroundImage)
            
            backgroundLabel.text = "There are no current meetups in your area. Want to create one?"
            backgroundLabel.font = UIFont(name: "OpenSans", size: fontSize)
            backgroundLabel.textColor = Utilities().UIColorFromHex(0x3A4A49, alpha: 1.0)
            backgroundLabel.frame = CGRect(x: screenWidth * 0.5, y: midHeight, width: imageHeight * aspectRatio * 1.8, height: imageHeight)
            backgroundLabel.numberOfLines = 0
            backgroundLabel.textAlignment = NSTextAlignment.left
            backgroundLabel.sizeToFit()
            backgroundView.addSubview(backgroundLabel)
            
            button.frame = CGRect(x: screenWidth * 0.5 - buttonWidth * 0.5, y: midHeight * 1.6, width: buttonWidth, height: buttonHeight)
            button.backgroundColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            button.setTitle("CREATE MEETUP", for: UIControlState())
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.layer.cornerRadius = 5
            button.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: 18.0)
            button.addTarget(self, action: #selector(EventsFinderTableVC.toCreateEvent(_:)), for: UIControlEvents.touchUpInside)
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
        return eventsList.count
    }
    
    // Return the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        let event = eventsList[(indexPath as NSIndexPath).row] as! PFObject;
        var dist = distList[(indexPath as NSIndexPath).row] as! Double;
        
        cell.goingButton.tag = 100 + (indexPath as NSIndexPath).row * 3
        cell.maybeButton.tag = 100 + (indexPath as NSIndexPath).row * 3 + 1
        cell.notGoingButton.tag = 100 + (indexPath as NSIndexPath).row * 3 + 2
       
        cell.goingButton.titleLabel!.font = UIFont(name: "OpenSans", size: 12.0)
        cell.maybeButton.titleLabel?.font = UIFont(name: "OpenSans", size: 12.0)
        cell.notGoingButton.titleLabel!.font = UIFont(name: "OpenSans", size: 12.0)
        
        cell.goingButton.addTarget(self, action: #selector(EventsFinderTableVC.goingPressed(_:)), for: UIControlEvents.touchUpInside);
        cell.maybeButton.addTarget(self, action: #selector(EventsFinderTableVC.maybePressed(_:)), for: UIControlEvents.touchUpInside);
        cell.notGoingButton.addTarget(self, action: #selector(EventsFinderTableVC.notGoingPressed(_:)), for: UIControlEvents.touchUpInside);

        
        
        dist = Double(round(100 * dist)/100);
        formatTableViewCell(event, cell: cell, dist: dist);
        cell.layoutIfNeeded();
        
        let leftLine:UIView = UIView(frame: CGRect(x: 1, y: 2.0, width: 0.5, height: cell.maybeButton.frame.size.height - 5.0))
        let rightLine:UIView = UIView(frame: CGRect(x: cell.maybeButton.frame.size.width - 1.0, y: 2.0, width: 1.5, height: cell.maybeButton.frame.size.height - 5.0))
        
        leftLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
        rightLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)

        cell.maybeButton.addSubview(leftLine)
        cell.maybeButton.addSubview(rightLine)
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (eventsList.count > 0) {
            self.selectedEvent = eventsList[(indexPath as NSIndexPath).row] as! PFObject;
            
            self.performSegue(withIdentifier: "toEventDescription", sender: self);
        }
        
    }
    
    
    func formatTableViewCell(_ event: PFObject, cell: EventCell, dist: Double) {
        let date:Date = event["Date"] as! Date
        let title:String = event["Title"] as! String
        let creator:String = event["CreatorName"] as! String
        let locationName:String = event["EventName"] as! String
        
        let goingList:[String] = event["Going"] as! [String]
        let maybeList:[String] = event["Maybe"] as! [String]
        let notGoingList:[String] = event["NotGoing"] as! [String]
        
        if goingList.contains(PFUser.current()!.objectId!) {

            cell.goingButton.isSelected = true
            cell.goingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        } else {
            
            cell.goingButton.isSelected = false
            cell.goingButton.isHighlighted = false
        }
        
        if maybeList.contains(PFUser.current()!.objectId!) {
            cell.maybeButton.isSelected = true
            cell.maybeButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        } else {
            cell.maybeButton.isSelected = false
            cell.maybeButton.isHighlighted = false
        }
        
        if notGoingList.contains(PFUser.current()!.objectId!) {

            cell.notGoingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            cell.notGoingButton.isSelected = true

        } else {

            cell.notGoingButton.isSelected = false
            cell.notGoingButton.isHighlighted = false
        }
        
        
        let components = (Calendar.current as NSCalendar).components([.hour, .minute, .month, .day, .year], from: date)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date);
        
        let locationArr = locationName.characters.split{$0 == ","}.map(String.init)
        cell.eventDay.text = String(describing: day);
        cell.eventMonth.text = month;
        cell.eventTime.text = time;
        cell.eventTitle.text = title;
        cell.eventLocation.text = locationArr[0];
        cell.eventOrganizer.text = "Organized by " + creator;
        cell.eventDistance.text = String(dist) + " km";
        
    }
    func toCreateEvent(_ sender:UIButton!) {
        performSegue(withIdentifier: "toCreateEvent", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toEventDescription" {
            let destinationVC = segue.destination.childViewControllers[0] as! EventDescriptionTableVC
            destinationVC.selectedEvent = self.selectedEvent;
        }
    }
    
    
    
   }
