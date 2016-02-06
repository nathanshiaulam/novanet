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
    
    var selectedEvent:PFObject!;
    
    @IBOutlet weak var descField: UITextView!

    @IBAction func goBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var goingButton: EventAttendanceButton!
    @IBOutlet weak var maybeButton: EventAttendanceButton!
    @IBOutlet weak var notGoingButton: EventAttendanceButton!
    
    @IBOutlet weak var goingCount: UIButton!
    @IBOutlet weak var interestedCount: UIButton!
    @IBOutlet weak var notGoingCount: UIButton!

    
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

    }

    override func viewDidLoad() {
        tableView.allowsSelection = false;
        descField.editable = false;
        prepareView()
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
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
            dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle;
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
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        
//    }
    
    
}
