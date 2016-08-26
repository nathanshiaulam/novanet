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

class EventsFinderTableVC: ViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate   {
    
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
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
    
    @IBAction func findLocalEvents(sender: UIButton) {
        if localEvents == false {
            localEvents = true;
            let currentFont = localEventButton.titleLabel!.font
            localEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: currentFont.pointSize)
            
            let otherCurrentFont = memberEventButton.titleLabel!.font
            memberEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: otherCurrentFont.pointSize)
            
            findAllEvents();
            
        }
    }
    
    @IBAction func findMyEvents(sender: UIButton) {
        if localEvents == true {
            localEvents = false;
            let currentFont = localEventButton.titleLabel!.font
            localEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Thin", size: currentFont.pointSize)
            
            let otherCurrentFont = memberEventButton.titleLabel!.font
            memberEventButton.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: otherCurrentFont.pointSize)
            
            findSavedEvents();
        }
    }
    override func viewDidLoad() {
        localEvents = true
        
        eventsList = NSArray()
        distList = NSArray()
        
        self.tableView.rowHeight = 100.0
        self.tabBarController!.navigationItem.title = "EVENTS"
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: eventHeaderView.frame.size.height - width, width:  eventHeaderView.frame.size.width, height: eventHeaderView.frame.size.height)
        border.borderWidth = width
        eventHeaderView.layer.addSublayer(border)
        eventHeaderView.layer.masksToBounds = true
        
        refreshControl = UIRefreshControl()
        self.tableView.tableFooterView = UIView()

    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.navigationItem.title = "EVENTS";
        self.tabBarController!.navigationItem.leftBarButtonItem = addEventButton;
        self.oldTitleView = self.tabBarController!.navigationItem.titleView

        tableView.addSubview(self.refreshControl)
        if localEvents == true {
            findAllEvents();
            refreshControl.removeTarget(self, action: #selector(EventsFinderTableVC.findSavedEvents), forControlEvents: UIControlEvents.ValueChanged)
            refreshControl.addTarget(self, action: #selector(EventsFinderTableVC.findAllEvents), forControlEvents: UIControlEvents.ValueChanged)
            
        } else {
            findSavedEvents();
            refreshControl.removeTarget(self, action: #selector(EventsFinderTableVC.findAllEvents), forControlEvents: UIControlEvents.ValueChanged)
            refreshControl.addTarget(self, action: #selector(EventsFinderTableVC.findSavedEvents), forControlEvents: UIControlEvents.ValueChanged)
        }
        super.viewDidAppear(true);
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController!.navigationItem.titleView = oldTitleView;
        self.tabBarController!.navigationItem.leftBarButtonItem = nil;
    }
    
    
    
    
    // Find all events within range and with "Local" = true
    // Create a method to parse through each event and return a dict with all the necessary fields
    // List events in time order
    // For each event that you find, check whether or not any of the buttons contain current ID
    // Each of the buttons should only contain one of the ID, so we'll need a method to add in the button pressed and remove the other two

    func findAllEvents() {
        let lat = defaults.doubleForKey(Constants.UserKeys.latitudeKey);
        let lon = defaults.doubleForKey(Constants.UserKeys.longitudeKey);
        let dist = Constants.DISCOVERY_RADIUS;
        
        PFCloud.callFunctionInBackground("findAllEvents", withParameters: ["lat": lat, "lon": lon, "dist":dist]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                self.eventsList = result as! NSArray;
                self.findDistList(lon, lat:lat, dist:dist, all:true);
            }
        }
    }
    
    func findSavedEvents() {
        let lat = defaults.doubleForKey(Constants.UserKeys.latitudeKey);
        let lon = defaults.doubleForKey(Constants.UserKeys.longitudeKey);
        let dist = Constants.DISCOVERY_RADIUS;
        
        PFCloud.callFunctionInBackground("findSavedEvents", withParameters: [:]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                self.eventsList = result as! NSArray;
                self.findDistList(lon, lat:lat, dist:dist, all:false);
            }
        }
        
    }
    
    func findDistList(lon: Double, lat: Double, dist: Int, all:Bool) {
        PFCloud.callFunctionInBackground("findEventsDist", withParameters: ["lat":lat, "lon":lon, "dist":dist, "all":all]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                self.distList = result as! NSArray;
                self.tableView.reloadData();
                self.refreshControl.endRefreshing();
            }
        }
    }
    
    
    func goingPressed(sender: EventAttendanceButton) {
        let maybeButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag + 1) as! EventAttendanceButton
        let notGoingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag + 2)  as! EventAttendanceButton
        
        let event:PFObject! = eventsList[(sender.tag - 100) / 3] as! PFObject;
        
        if (sender.selected) {
            var arr:[String]! = event["Going"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            event["Going"] = arr;
            event.saveInBackground();
            
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = event["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Maybe"] = arr;
                event.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
            }
            if (notGoingButton.selected) {
                var arr:[String]! = event["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["NotGoing"] = arr;
                event.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
            }
            var arr:[String]! = event["Going"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            event["Going"] = arr;
            event.saveInBackground();
            
        }

        sender.selected = !sender.selected;
    }
    
    func maybePressed(sender: EventAttendanceButton) {
        let goingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag - 1) as! EventAttendanceButton
        let notGoingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag + 1)  as! EventAttendanceButton
        
        let event:PFObject! = eventsList[(sender.tag - 100 - 1) / 3] as! PFObject;

        if (sender.selected) {
            var arr:[String]! = event["Maybe"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            event["Maybe"] = arr;
            event.saveInBackground();
            
        } else  {
            if (goingButton.selected) {
                var arr:[String]! = event["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Going"] = arr;
                event.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
            }
            if (notGoingButton.selected) {
                var arr:[String]! = event["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["NotGoing"] = arr;
                event.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
            }
            var arr:[String]! = event["Maybe"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            event["Maybe"] = arr;
            event.saveInBackground();
            
        }
        sender.selected = !sender.selected;
    }

    func notGoingPressed(sender: EventAttendanceButton) {
        let maybeButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag - 1) as! EventAttendanceButton
        let goingButton:EventAttendanceButton = self.tableView.viewWithTag(sender.tag - 2)  as! EventAttendanceButton
        
        let event:PFObject! = eventsList[(sender.tag - 100 - 2) / 3] as! PFObject;
        
        if (sender.selected) {
            var arr:[String]! = event["NotGoing"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            event["NotGoing"] = arr;
            event.saveInBackground();
            
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = event["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Maybe"] = arr;
                event.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
            }
            if (goingButton.selected) {
                var arr:[String]! = event["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Going"] = arr;
                event.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
            }
            var arr:[String]! = event["NotGoing"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            event["NotGoing"] = arr;
            event.saveInBackground();
        }
        sender.selected = !sender.selected;
    }
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let backgroundLabel = UILabel()
        let backgroundView = UIView()
        var backgroundImage = UIImageView()
        let button = UIButton(type: UIButtonType.System) as UIButton

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
        
        if (self.eventsList.count == 0) {
            
            let imageName = "about_event.png"
            let image = UIImage(named: imageName)
            backgroundImage = UIImageView(image: image!)
            let aspectRatio = backgroundImage.bounds.width / backgroundImage.bounds.height
            backgroundImage.frame = CGRect(x: screenWidth * 0.5 - imageHeight * aspectRatio * 1.5, y: midHeight, width: imageHeight * aspectRatio, height: imageHeight)
            backgroundView.addSubview(backgroundImage)
            
            backgroundLabel.text = "There are no current events in your area. Want to create one?"
            backgroundLabel.font = UIFont(name: "OpenSans", size: fontSize)
            backgroundLabel.textColor = Utilities().UIColorFromHex(0x3A4A49, alpha: 1.0)
            backgroundLabel.frame = CGRect(x: screenWidth * 0.5, y: midHeight, width:imageHeight * aspectRatio * 1.8, height: imageHeight)
            backgroundLabel.numberOfLines = 0
            backgroundLabel.textAlignment = NSTextAlignment.Left
            backgroundLabel.sizeToFit()
            backgroundView.addSubview(backgroundLabel)
            
            button.frame = CGRect(x: screenWidth * 0.5 - buttonWidth * 0.5, y: midHeight * 1.5, width: buttonWidth, height: buttonHeight)
            button.backgroundColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            button.setTitle("CREATE EVENT", forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.layer.cornerRadius = 5
            button.titleLabel!.font = UIFont(name: "BrandonGrotesque-Medium", size: 18.0)
            button.addTarget(self, action: #selector(EventsFinderTableVC.toCreateEvent(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        return eventsList.count
    }
    
    // Return the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        let event = eventsList[indexPath.row] as! PFObject;
        var dist = distList[indexPath.row] as! Double;
        
        cell.goingButton.tag = 100 + indexPath.row * 3
        cell.maybeButton.tag = 100 + indexPath.row * 3 + 1
        cell.notGoingButton.tag = 100 + indexPath.row * 3 + 2
        
       
        cell.goingButton.titleLabel!.font = UIFont(name: "OpenSans", size: 12.0)
        cell.maybeButton.titleLabel?.font = UIFont(name: "OpenSans", size: 12.0)
        cell.notGoingButton.titleLabel!.font = UIFont(name: "OpenSans", size: 12.0)
        
        cell.goingButton.addTarget(self, action: #selector(EventsFinderTableVC.goingPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        cell.maybeButton.addTarget(self, action: #selector(EventsFinderTableVC.maybePressed(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        cell.notGoingButton.addTarget(self, action: #selector(EventsFinderTableVC.notGoingPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside);

        
        
        dist = Double(round(100 * dist)/100);
        formatTableViewCell(event, cell: cell, dist: dist);
        cell.layoutIfNeeded();
        
        let leftLine:UIView = UIView(frame: CGRectMake(1, 2.0, 0.5, cell.maybeButton.frame.size.height - 5.0))
        let rightLine:UIView = UIView(frame: CGRectMake(cell.maybeButton.frame.size.width - 1.0, 2.0, 1.5, cell.maybeButton.frame.size.height - 5.0))
        
        leftLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
        rightLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)

        
        cell.maybeButton.addSubview(leftLine)
        cell.maybeButton.addSubview(rightLine)
        
        return cell;
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (eventsList.count > 0) {
            self.selectedEvent = eventsList[indexPath.row] as! PFObject;
            
            self.performSegueWithIdentifier("toEventDescription", sender: self);
        }
        
    }
    
    
    func formatTableViewCell(event: PFObject, cell: EventCell, dist: Double) {
        let date:NSDate = event["Date"] as! NSDate
        let title:String = event["Title"] as! String
        let creator:String = event["CreatorName"] as! String
        let locationName:String = event["EventName"] as! String
        
        let goingList:[String] = event["Going"] as! [String]
        let maybeList:[String] = event["Maybe"] as! [String]
        let notGoingList:[String] = event["NotGoing"] as! [String]
        
        if goingList.contains(PFUser.currentUser()!.objectId!) {

            cell.goingButton.selected = true
            cell.goingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        } else {
            
            cell.goingButton.selected = false
            cell.goingButton.highlighted = false
        }
        
        if maybeList.contains(PFUser.currentUser()!.objectId!) {
            cell.maybeButton.selected = true
            cell.maybeButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        } else {
            cell.maybeButton.selected = false
            cell.maybeButton.highlighted = false
        }
        
        if notGoingList.contains(PFUser.currentUser()!.objectId!) {

            cell.notGoingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            cell.notGoingButton.selected = true

        } else {

            cell.notGoingButton.selected = false
            cell.notGoingButton.highlighted = false
        }
        
        
        let components = NSCalendar.currentCalendar().components([.Hour, .Minute, .Month, .Day, .Year], fromDate: date)
        
        let day = components.day;
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.stringFromDate(date);
        
        let locationArr = locationName.characters.split{$0 == ","}.map(String.init)
        cell.eventDay.text = String(day);
        cell.eventMonth.text = month;
        cell.eventTime.text = time;
        cell.eventTitle.text = title;
        cell.eventLocation.text = locationArr[0];
        cell.eventOrganizer.text = "Organized by " + creator;
        cell.eventDistance.text = String(dist) + " km";
        
    }
    func toCreateEvent(sender:UIButton!) {
        performSegueWithIdentifier("toCreateEvent", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toEventDescription" {
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! EventDescriptionTableVC
            destinationVC.selectedEvent = self.selectedEvent;
        }
    }
    
    
    
   }
