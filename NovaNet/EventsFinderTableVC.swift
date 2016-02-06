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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var memberEventButton: UIButton!
    @IBOutlet weak var localEventButton: UIButton!
    @IBOutlet weak var addEventButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    

    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.tableView.addSubview(eventHeaderView);
            self.tableView.frame =
                CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height + 30)
            refreshControl.removeTarget(self, action: Selector("findSavedEvents"), forControlEvents: UIControlEvents.ValueChanged)
            refreshControl.addTarget(self, action: Selector("findAllEvents"), forControlEvents: UIControlEvents.ValueChanged)
            findAllEvents();
            
        } else {
            eventHeaderView.removeFromSuperview()
            self.tableView.frame =
                CGRectMake(0, 0 - eventHeaderView.frame.height, self.tableView.frame.width, self.tableView.frame.height + 30)
            refreshControl.removeTarget(self, action: Selector("findAllEvents"), forControlEvents: UIControlEvents.ValueChanged)
            refreshControl.addTarget(self, action: Selector("findSavedEvents"), forControlEvents: UIControlEvents.ValueChanged)
            findSavedEvents();
            
        }
        
    }
    @IBAction func findLocalEvents(sender: UIButton) {
        if localEvents == false {
            localEvents = true;
            let currentFont = localEventButton.titleLabel!.font
            localEventButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: currentFont.pointSize)
            
            let otherCurrentFont = memberEventButton.titleLabel!.font
            memberEventButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: otherCurrentFont.pointSize)
            
        }
    }
    
    @IBAction func findMemberEvents(sender: UIButton) {
        if localEvents == true {
            localEvents = false;
            let currentFont = localEventButton.titleLabel!.font
            localEventButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: currentFont.pointSize)
            
            let otherCurrentFont = memberEventButton.titleLabel!.font
            memberEventButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: otherCurrentFont.pointSize)
            
            
        }
    }
    
    override func viewDidLoad() {

        localEvents = true;
        
        eventsList = NSArray();
        distList = NSArray();
        
        self.tableView.rowHeight = 100.0;
        
        
        refreshControl = UIRefreshControl();
        
        segmentControl.selectedSegmentIndex = 0;
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.navigationItem.title = "Events";
        self.tabBarController!.navigationItem.leftBarButtonItem = addEventButton;
        self.oldTitleView = self.tabBarController!.navigationItem.titleView
        self.tabBarController!.navigationItem.titleView = segmentControl;
        
        tableView.addSubview(self.refreshControl)
        if segmentControl.selectedSegmentIndex == 0 {
            findAllEvents();
            refreshControl.removeTarget(self, action: Selector("findSavedEvents"), forControlEvents: UIControlEvents.ValueChanged)
            refreshControl.addTarget(self, action: Selector("findAllEvents"), forControlEvents: UIControlEvents.ValueChanged)
            
        } else {
            findSavedEvents();
            self.tableView.frame =
                CGRectMake(0, 0 - eventHeaderView.frame.height, self.tableView.frame.width, self.tableView.frame.height + 30)
            refreshControl.removeTarget(self, action: Selector("findAllEvents"), forControlEvents: UIControlEvents.ValueChanged)
            refreshControl.addTarget(self, action: Selector("findSavedEvents"), forControlEvents: UIControlEvents.ValueChanged)
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
        
        PFCloud.callFunctionInBackground("findAllEvents", withParameters: ["lat": lat, "lon": lon, "dist":dist, "local":localEvents]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                self.eventsList = result as! NSArray;
                self.findDistList(lon, lat:lat, dist:dist, local:self.localEvents, all:true);
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
                print(result)
                self.eventsList = result as! NSArray;
                self.findDistList(lon, lat:lat, dist:dist, local: self.localEvents, all:false);
            }
        }
        
    }
    
    func findDistList(lon: Double, lat: Double, dist: Int, local: Bool, all:Bool) {
        PFCloud.callFunctionInBackground("findEventsDist", withParameters: ["lat":lat, "lon":lon, "dist":dist, "local":localEvents, "all":all]) {
            (result: AnyObject?, error:NSError?) -> Void in
            if error != nil {
                print(error);
            } else if let result = result {
                print(result)
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
            
            sender.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = event["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Maybe"] = arr;
                event.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
                maybeButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            if (notGoingButton.selected) {
                var arr:[String]! = event["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["NotGoing"] = arr;
                event.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
                notGoingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            var arr:[String]! = event["Going"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            event["Going"] = arr;
            event.saveInBackground();
            sender.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
            
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
            
            sender.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        } else  {
            if (goingButton.selected) {
                var arr:[String]! = event["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Going"] = arr;
                event.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
                goingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            if (notGoingButton.selected) {
                var arr:[String]! = event["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["NotGoing"] = arr;
                event.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
                notGoingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            var arr:[String]! = event["Maybe"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            event["Maybe"] = arr;
            event.saveInBackground();
            sender.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
            
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
            
            sender.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = event["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Maybe"] = arr;
                event.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
                maybeButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            if (goingButton.selected) {
                var arr:[String]! = event["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                event["Going"] = arr;
                event.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
                goingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            var arr:[String]! = event["NotGoing"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            event["NotGoing"] = arr;
            event.saveInBackground();
            sender.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
        }
        sender.selected = !sender.selected;
    }
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        cell.goingButton.addTarget(self, action: "goingPressed:", forControlEvents: UIControlEvents.TouchUpInside);
        cell.maybeButton.addTarget(self, action: "maybePressed:", forControlEvents: UIControlEvents.TouchUpInside);
        cell.notGoingButton.addTarget(self, action: "notGoingPressed:", forControlEvents: UIControlEvents.TouchUpInside);

        
        
        dist = Double(round(100 * dist)/100);
        formatTableViewCell(event, cell: cell, dist: dist);
        cell.layoutIfNeeded();
        
        
        return cell;
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (eventsList.count > 0) {
            self.selectedEvent = eventsList[indexPath.row] as! PFObject;
            
            self.performSegueWithIdentifier("toEventDescription", sender: self);
        }
        
    }
    
    
    func formatTableViewCell(event: PFObject, cell: EventCell, dist: Double) {
        let date:NSDate = event["Date"] as! NSDate;
        let title:String = event["Title"] as! String;
        let creator:String = event["CreatorName"] as! String;
        let locationName:String = event["EventName"] as! String;
        
        let goingList:[String] = event["Going"] as! [String];
        let maybeList:[String] = event["Maybe"] as! [String];
        let notGoingList:[String] = event["NotGoing"] as! [String];
        
        if goingList.contains(PFUser.currentUser()!.objectId!) {
            cell.goingButton.selected = true;
            cell.goingButton.highlighted = true;
            cell.goingButton.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
        } else {
            cell.goingButton.selected = false;
            cell.goingButton.highlighted = false
            cell.goingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        }
        
        if maybeList.contains(PFUser.currentUser()!.objectId!) {
            cell.maybeButton.selected = true;
            cell.maybeButton.highlighted = true;
            cell.maybeButton.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
        } else {
            cell.maybeButton.selected = false;
            cell.maybeButton.highlighted = false
            cell.maybeButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        }
        
        if notGoingList.contains(PFUser.currentUser()!.objectId!) {
            cell.notGoingButton.selected = true;
            cell.notGoingButton.highlighted = true;
            cell.notGoingButton.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
        } else {
            cell.notGoingButton.selected = false;
            cell.notGoingButton.highlighted = false
            cell.notGoingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        }
        
        
        let components = NSCalendar.currentCalendar().components([.Hour, .Minute, .Month, .Day, .Year], fromDate: date)
        
        let day = components.day;
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.stringFromDate(date);
        
        cell.eventDay.text = String(day);
        cell.eventMonth.text = month;
        cell.eventTime.text = time;
        cell.eventTitle.text = title;
        cell.eventLocation.text = locationName;
        cell.eventOrganizer.text = "Organized by " + creator;
        cell.eventDistance.text = String(dist);
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toEventDescription" {
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! EventDescriptionTableVC
            destinationVC.selectedEvent = self.selectedEvent;
        }
    }
    
    
    
   }
