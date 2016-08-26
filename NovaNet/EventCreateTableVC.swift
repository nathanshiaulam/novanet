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

class EventCreateTableVC: TableViewController, UITextViewDelegate {

    
    var marker:GMSMarker!;
    var selectedDate:NSDate!;
    
    let defaults = NSUserDefaults.standardUserDefaults();
    
    
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var addressCell: UITableViewCell!
    @IBOutlet weak var eventField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    @IBAction func createEvent(sender: AnyObject) {
        
        if (titleField.text?.characters.count > 0 && dateField.text?.characters.count > 0 && descField.text.characters.count > 0 && addressField.text!.characters.count > 0 && descField.textColor != UIColor.lightGrayColor()) {
            let point:PFGeoPoint = PFGeoPoint(latitude: marker.position.latitude, longitude: marker.position.longitude);
            
            
            let newEvent = PFObject(className: "Event");
            newEvent["Title"] = titleField.text;
            newEvent["Description"] = descField.text;
            newEvent["Creator"] = PFUser.currentUser()?.objectId;
            newEvent["CreatorName"] = defaults.objectForKey(Constants.UserKeys.nameKey);
            newEvent["Date"] = selectedDate;
            newEvent["Position"] = point;
            newEvent["EventName"] = marker.title;
            newEvent["Local"] = true;
            newEvent["Going"] = [(PFUser.currentUser()?.objectId)!] as [String]
            newEvent["Maybe"] = [String]();
            newEvent["NotGoing"] = [String]();

            newEvent.saveInBackground();
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
        } else {
            let alert = UIAlertController(title: "Submission Failure", message: "Please fill out all fields before creating an event.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }
    }
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))));
        tableView.allowsSelection = false;
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        titleField.autocapitalizationType = UITextAutocapitalizationType.Words
        descField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        descField.text = Constants.ConstantStrings.placeHolderDesc;
        descField.textColor = UIColor.lightGrayColor()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventCreateTableVC.saveNewLocation(_:)), name: "saveNewLocation", object: nil)
        if marker == nil {
            addressCell.hidden = true;
        }
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
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle;
            let currDate = dateFormatter.dateFromString(sender.text!);
            datePickerView.date = currDate!;
        }
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EventCreateTableVC.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        handleDatePicker(datePickerView);
        
    }
    
    func saveNewLocation(notification: NSNotification?) {
        marker = notification?.valueForKey("object") as? GMSMarker
        let placeName = marker!.title
        let placeTokens = placeName.characters.split{$0 == ","}.map(String.init)
        
        self.eventField.text = placeTokens[0]
        let lat = marker.position.latitude
        let lon = marker.position.longitude
        
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
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle;
        
        let dateString = dateFormatter.stringFromDate((sender.date))
        selectedDate = sender.date;
        dateField.text = dateString;
    }
    
    /* TABLEVIEW DELEGATE METHODS*/
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && descField.textColor != UIColor.lightGrayColor(){
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
    
    // Sets the character limit of each text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false;
        }
        
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        if (textField == titleField) {
            return newLength <= 20;
        }
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
