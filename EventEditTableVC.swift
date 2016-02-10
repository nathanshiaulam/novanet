//
//  EventCreateTableVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/5/15.
//  Copyright © 2015 Nova. All rights reserved.
//


import Foundation
import Bolts
import Parse
import AddressBookUI
import GoogleMaps

class EventEditTableVC: TableViewController, UITextViewDelegate {
    
    
    var marker:GMSMarker!;
    var selectedDate:NSDate!;
    
    let defaults = NSUserDefaults.standardUserDefaults();
    
    var selectedEvent:PFObject!;
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var addressCell: UITableViewCell!
    @IBOutlet weak var eventField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    @IBAction func deleteEvent(sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Event", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.deleteEvent()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func deleteEvent() {
        
        selectedEvent.deleteInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if (succeeded) {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("eventDeleted", object: nil);                
            } else {
                print(error)
            }
        }
    }
    @IBAction func editEvent(sender: AnyObject) {
        
        if (titleField.text?.characters.count > 0 && dateField.text?.characters.count > 0 && descField.text.characters.count > 0 && addressField.text!.characters.count > 0 && descField.textColor != UIColor.lightGrayColor()) {
            let point:PFGeoPoint = PFGeoPoint(latitude: marker.position.latitude, longitude: marker.position.longitude);
            
            selectedEvent["Title"] = titleField.text;
            selectedEvent["Description"] = descField.text;
            selectedEvent["Creator"] = PFUser.currentUser()?.objectId;
            selectedEvent["CreatorName"] = defaults.objectForKey(Constants.UserKeys.nameKey);
            selectedEvent["Date"] = selectedDate;
            selectedEvent["Position"] = point;
            selectedEvent["EventName"] = marker.title;
            selectedEvent["Local"] = true;

            selectedEvent.saveInBackground();
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
        } else {
            let alert = UIAlertController(title: "Submission Failure", message: "Please fill out all fields before creating an event.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }
    }
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: "endEditing:"));
        tableView.allowsSelection = false;
        
        prepareView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveNewLocation:", name: "saveNewLocation", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if marker == nil {
            addressCell.hidden = true;
        }
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func dateFieldPressed(sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        if (sender.text?.characters.count > 0) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
            dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle;
            let currDate = dateFormatter.dateFromString(sender.text!);
            datePickerView.date = currDate!;
        }
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        handleDatePicker(datePickerView);
        
    }
    
    func saveNewLocation(notification: NSNotification?) {
        marker = notification?.valueForKey("object") as? GMSMarker;
        self.eventField.text = marker!.title;
        let lat = marker.position.latitude;
        let lon = marker.position.longitude;
        
        let location = CLLocation(latitude: lat, longitude: lon);
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            } else if let marks = placemarks {
                let pm = marks[0] as CLPlacemark;
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, true);
                self.addressField.text = address;
                self.addressCell.hidden = false;
            }
        })
        
    }
    
    func prepareView() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle;
        selectedDate = selectedEvent["Date"] as? NSDate
        let dateString = dateFormatter.stringFromDate(selectedDate!);
        dateField.text = dateString;
        
        descField.text = selectedEvent["Description"] as? String
        titleField.text = selectedEvent["Title"] as? String
        
        let point:PFGeoPoint = (selectedEvent["Position"] as? PFGeoPoint)!
        let lat = point.latitude
        let lon = point.longitude
        marker = GMSMarker()
        marker.title = selectedEvent["EventName"] as? String
        marker.position.latitude = lat
        marker.position.longitude = lon
        eventField.text = selectedEvent["EventName"] as? String
        let location = CLLocation(latitude: lat, longitude: lon)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            } else if let marks = placemarks {
                let pm = marks[0] as CLPlacemark;
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, true);
                self.addressField.text = address;
                self.addressCell.hidden = false;
            }
        })
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle;
        
        let dateString = dateFormatter.stringFromDate((sender.date))
        selectedDate = sender.date;
        dateField.text = dateString;
    }
    
    /* TABLEVIEW DELEGATE METHODS*/
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 3 && descField.textColor != UIColor.lightGrayColor(){
            return descField.frame.height + 20;
        } else {
            return self.tableView.rowHeight;
        }
        
    }
    /* TEXTVIEW DELEGATE METHODS*/
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.ConstantStrings.placeHolderDesc;
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
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
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder();
        return true;
    }
    
    // Moves to next field when hits enter
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        // Create a new variable to store the instance of PlayerTableViewController
        if (segue.identifier == "toMapView") {
            let navVC = segue.destinationViewController as! UINavigationController;
            let destinationVC = navVC.viewControllers.first as! EventsLocationFinder;
            if let location = marker {
                destinationVC.selectedLocation = location;
            }
        }
    }
    
}