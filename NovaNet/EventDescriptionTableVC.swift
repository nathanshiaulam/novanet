//
//  EventDescriptionTableVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/5/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse
import GoogleMaps
import AddressBookUI

class EventDescriptionTableVC: TableViewController, UITextViewDelegate {

    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var selectedEvent:PFObject!
    var userList: [PFObject]!
    
    @IBOutlet weak var descField: UITextView!

    @IBAction func goBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func editEvent(sender: AnyObject) {
        self.performSegueWithIdentifier("toEventEdit", sender: self)
    }
    
    @IBAction func goingCountClicked(sender: UIButton) {
        goToUserList("Going")

    }
    @IBAction func interestedCountClicked(sender: UIButton) {
        goToUserList("Maybe")
    }
    @IBAction func notGoingClicked(sender: UIButton) {
        goToUserList("NotGoing")
    }
    
    func goToUserList(status: String) {
        let list = selectedEvent[status] as! [String]
        let query:PFQuery = PFQuery(className: "Profile")
        query.whereKey("ID", containedIn: list)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.userList = objects as? [PFObject]
                print(self.userList)
                self.performSegueWithIdentifier("toUserList", sender: self)
            } else {
                print(error)
            }
        }
    }
    
    
    @IBOutlet weak var goingButton: EventAttendanceButton!
    @IBOutlet weak var maybeButton: EventAttendanceButton!
    @IBOutlet weak var notGoingButton: EventAttendanceButton!
    
    @IBOutlet weak var goingCount: UIButton!
    @IBOutlet weak var interestedCount: UIButton!
    @IBOutlet weak var notGoingCount: UIButton!

    @IBAction func goToAppleMaps(sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title: "Find Location", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let mapsAction = UIAlertAction(title: "Open in Maps", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openMaps()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alert.addAction(mapsAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func openMaps() -> Void {
        let geoPoint = selectedEvent["Position"] as? PFGeoPoint
        var venueName = selectedEvent["EventName"] as! String
        var array:[String]!
        do {
            //Create a reggae and replace "," with any following spaces with just a comma
            let regex = try NSRegularExpression(pattern: ", +", options: NSRegularExpressionOptions.CaseInsensitive)
            venueName = regex.stringByReplacingMatchesInString(venueName, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, venueName.characters.count), withTemplate: ",")
            array = venueName.characters.split { $0 == ","}.map(String.init)
        } catch {
            //Bad regex created
        }
        let eventName = array[0]
        print(eventName)
        
        let lat1 = geoPoint?.latitude
        let lng1 = geoPoint?.longitude
        let latitute:CLLocationDegrees =  lat1!
        let longitute:CLLocationDegrees =  lng1!
        
        let regionDistance:CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(eventName)"
        mapItem.openInMapsWithLaunchOptions(options)

    }
    
    @IBAction func notGoingPressed(sender: EventAttendanceButton) {
        if (sender.selected) {
            var arr:[String]! = selectedEvent["NotGoing"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            selectedEvent["NotGoing"] = arr;
            selectedEvent.saveInBackground();
            
            sender.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = selectedEvent["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Maybe"] = arr;
                selectedEvent.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
                maybeButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            if (goingButton.selected) {
                var arr:[String]! = selectedEvent["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Going"] = arr;
                selectedEvent.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
                goingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            var arr:[String]! = selectedEvent["NotGoing"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            selectedEvent["NotGoing"] = arr;
            selectedEvent.saveInBackground();
            sender.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
        }
        sender.selected = !sender.selected;
        goingCount.setTitle(String(selectedEvent["Going"]!.count), forState: UIControlState.Normal);
        goingCount.setTitle(String(selectedEvent["Going"]!.count), forState: UIControlState.Selected);
        interestedCount.setTitle(String(selectedEvent["Maybe"]!.count), forState: UIControlState.Normal);
        interestedCount.setTitle(String(selectedEvent["Maybe"]!.count), forState: UIControlState.Selected);
        notGoingCount.setTitle(String(selectedEvent["NotGoing"]!.count), forState: UIControlState.Normal);
        notGoingCount.setTitle(String(selectedEvent["NotGoing"]!.count), forState: UIControlState.Selected);
        
    }
    @IBAction func maybePressed(sender: EventAttendanceButton) {
        if (sender.selected) {
            var arr:[String]! = selectedEvent["Maybe"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            selectedEvent["Maybe"] = arr;
            selectedEvent.saveInBackground();
            
            sender.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        } else  {
            if (goingButton.selected) {
                var arr:[String]! = selectedEvent["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Going"] = arr;
                selectedEvent.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
                goingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            if (notGoingButton.selected) {
                var arr:[String]! = selectedEvent["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["NotGoing"] = arr;
                selectedEvent.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
                notGoingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            var arr:[String]! = selectedEvent["Maybe"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            selectedEvent["Maybe"] = arr;
            selectedEvent.saveInBackground();
            sender.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
            
        }
        sender.selected = !sender.selected;
        goingCount.setTitle(String(selectedEvent["Going"]!.count), forState: UIControlState.Normal);
        goingCount.setTitle(String(selectedEvent["Going"]!.count), forState: UIControlState.Selected);
        interestedCount.setTitle(String(selectedEvent["Maybe"]!.count), forState: UIControlState.Normal);
        interestedCount.setTitle(String(selectedEvent["Maybe"]!.count), forState: UIControlState.Selected);
        notGoingCount.setTitle(String(selectedEvent["NotGoing"]!.count), forState: UIControlState.Normal);
        notGoingCount.setTitle(String(selectedEvent["NotGoing"]!.count), forState: UIControlState.Selected);
        
    }
    @IBAction func goingPressed(sender: EventAttendanceButton) {
        if (sender.selected) {
            var arr:[String]! = selectedEvent["Going"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            selectedEvent["Going"] = arr;
            selectedEvent.saveInBackground();
            
            sender.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = selectedEvent["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Maybe"] = arr;
                selectedEvent.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
                maybeButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            if (notGoingButton.selected) {
                var arr:[String]! = selectedEvent["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["NotGoing"] = arr;
                selectedEvent.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
                notGoingButton.backgroundColor = Utilities().UIColorFromHex(0xf6f7f8, alpha: 1.0);
            }
            var arr:[String]! = selectedEvent["Going"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            selectedEvent["Going"] = arr;
            selectedEvent.saveInBackground();
            sender.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
        }
        sender.selected = !sender.selected;
        
        goingCount.setTitle(String(selectedEvent["Going"]!.count), forState: UIControlState.Normal);
        goingCount.setTitle(String(selectedEvent["Going"]!.count), forState: UIControlState.Selected);
        interestedCount.setTitle(String(selectedEvent["Maybe"]!.count), forState: UIControlState.Normal);
        interestedCount.setTitle(String(selectedEvent["Maybe"]!.count), forState: UIControlState.Selected);
        notGoingCount.setTitle(String(selectedEvent["NotGoing"]!.count), forState: UIControlState.Normal);
        notGoingCount.setTitle(String(selectedEvent["NotGoing"]!.count), forState: UIControlState.Selected);
    }

    override func viewDidLoad() {
        tableView.allowsSelection = false;
        descField.editable = false;
        prepareView()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let id:String? = selectedEvent.objectId;
        let query = PFQuery(className: "Event")
        query.whereKey("objectId", equalTo: id!);
        
        query.getFirstObjectInBackgroundWithBlock {
            (event:PFObject?, error: NSError?) -> Void in
            if error != nil || event == nil {
                print(error)
            } else if let event = event {
                self.selectedEvent = event;
                self.prepareView();
            }
        }
        
        super.viewDidAppear(true);
    }
    
    
    func prepareView() {
        if let event = selectedEvent {
            
            let date:NSDate! = event["Date"] as! NSDate
            let position:PFGeoPoint = event["Position"] as! PFGeoPoint
            let lat = position.latitude;
            let lon = position.longitude;
            let eventLocName = event["EventName"] as? String;
            
            let location = CLLocation(latitude: lat, longitude: lon);
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, true);
                    let fullAddress = eventLocName! + ", " + address;
                    self.addressLabel.text = fullAddress;
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
            
            let creator = event["CreatorName"] as? String
            
            let id:String? = event["Creator"] as? String
            if id != PFUser.currentUser()!.objectId {
                self.navigationItem.rightBarButtonItem = nil;
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle;
            let dateString = dateFormatter.stringFromDate(date)
            
            titleField.text = event["Title"] as? String
            timeLabel.text = dateString;
            
            
            descField.text = event["Description"] as? String
            
            organizerLabel.text = "Organized by " + creator!
            
            let goingList:[String] = selectedEvent["Going"] as! [String];
            let maybeList:[String] = selectedEvent["Maybe"] as! [String];
            let notGoingList:[String] = selectedEvent["NotGoing"] as! [String];
            
            
            if goingList.contains(PFUser.currentUser()!.objectId!) {
                goingButton.selected = true;
                goingButton.highlighted = true;
                goingButton.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
            }
            
            if maybeList.contains(PFUser.currentUser()!.objectId!) {
                maybeButton.selected = true;
                maybeButton.highlighted = true;
                maybeButton.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
            }
            
            if notGoingList.contains(PFUser.currentUser()!.objectId!) {
                notGoingButton.selected = true;
                notGoingButton.highlighted = true;
                notGoingButton.backgroundColor = Utilities().UIColorFromHex(0xBFBFBF, alpha: 1.0);
            }
            
            goingCount.setTitle(String(goingList.count), forState: UIControlState.Normal)
            goingCount.setTitle(String(goingList.count), forState: UIControlState.Selected)
            interestedCount.setTitle(String(maybeList.count), forState: UIControlState.Normal)
            interestedCount.setTitle(String(maybeList.count), forState: UIControlState.Selected)
            notGoingCount.setTitle(String(notGoingList.count), forState: UIControlState.Normal)
            notGoingCount.setTitle(String(notGoingList.count), forState: UIControlState.Selected)
        }
    }
    /* TABLEVIEW DELEGATE METHODS*/
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 65
            }
            if indexPath.row == 1 {
                return 50
            }
            if indexPath.row == 2 {
                return 70
            }
            if indexPath.row == 3 || indexPath.row == 4 {
                return 40
            }
        } else if indexPath.section == 1 {
            return descField.frame.height;
        }
        return self.tableView.rowHeight;
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toEventEdit" {
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! EventEditTableVC
            destinationVC.selectedEvent = self.selectedEvent;
        } else if segue.identifier == "toUserList" {
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! EventAttendanceVC
            destinationVC.userList = self.userList;
        }
    }
    
    
}
