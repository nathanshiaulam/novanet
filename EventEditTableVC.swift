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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EventEditTableVC: TableViewController, UITextViewDelegate {
    
    
    var marker:GMSMarker!;
    var selectedDate:Date!;
    
    let defaults = UserDefaults.standard;
    
    var selectedEvent:PFObject!;
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var addressCell: UITableViewCell!
    @IBOutlet weak var eventField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    @IBAction func deleteEvent(_ sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Event", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.deleteEvent()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deleteEvent() {
        
        selectedEvent.deleteInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if (succeeded) {
                self.navigationController?.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "eventDeleted"), object: nil);                
            } else {
                print(error)
            }
        }
    }
    @IBAction func editEvent(_ sender: AnyObject) {
        
        if (titleField.text?.characters.count > 0 && dateField.text?.characters.count > 0 && descField.text.characters.count > 0 && addressField.text!.characters.count > 0 && descField.textColor != UIColor.lightGray) {
            let point:PFGeoPoint = PFGeoPoint(latitude: marker.position.latitude, longitude: marker.position.longitude);
            
            selectedEvent["Title"] = titleField.text;
            selectedEvent["Description"] = descField.text;
            selectedEvent["Creator"] = PFUser.current()?.objectId;
            selectedEvent["CreatorName"] = defaults.object(forKey: Constants.UserKeys.nameKey);
            selectedEvent["Date"] = selectedDate;
            selectedEvent["Position"] = point;
            selectedEvent["EventName"] = marker.title;
            selectedEvent["Local"] = true;

            selectedEvent.saveInBackground();
            self.navigationController?.dismiss(animated: true, completion: nil);
        } else {
            let alert = UIAlertController(title: "Submission Failure", message: "Please fill out all fields before creating an event.", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
            self.present(alert, animated: true, completion: nil);
            return;
        }
    }
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))));
        tableView.allowsSelection = false;
        titleField.autocapitalizationType = UITextAutocapitalizationType.words
        descField.autocapitalizationType = UITextAutocapitalizationType.sentences
        prepareView()

        NotificationCenter.default.addObserver(self, selector: #selector(EventEditTableVC.saveNewLocation(_:)), name: NSNotification.Name(rawValue: "saveNewLocation"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if marker == nil {
            addressCell.isHidden = true;
        }
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func dateFieldPressed(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        if (sender.text?.characters.count > 0) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.long;
            dateFormatter.timeStyle = DateFormatter.Style.long;
            let currDate = dateFormatter.date(from: sender.text!);
            datePickerView.date = currDate!;
        }
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EventEditTableVC.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        handleDatePicker(datePickerView);
        
    }
    
    func saveNewLocation(_ notification: Notification?) {
        marker = notification?.object as? GMSMarker;
        let lat = marker.position.latitude;
        let lon = marker.position.longitude;
        let placeName = marker!.title
        let placeTokens = placeName?.characters.split{$0 == ","}.map(String.init)
        
        self.eventField.text = placeTokens?[0]
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
                self.addressCell.isHidden = false;
            }
        })
        
    }
    
    func prepareView() {
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long;
        dateFormatter.timeStyle = DateFormatter.Style.long;
        selectedDate = selectedEvent["Date"] as? Date
        let dateString = dateFormatter.string(from: selectedDate!);
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
        
        let placeName = marker!.title
        let placeTokens = placeName?.characters.split{$0 == ","}.map(String.init)
        
        self.eventField.text = placeTokens?[0]
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
                self.addressCell.isHidden = false;
            }
        })
    }
    
    func handleDatePicker(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long;
        dateFormatter.timeStyle = DateFormatter.Style.long;
        
        let dateString = dateFormatter.string(from: (sender.date))
        selectedDate = sender.date;
        dateField.text = dateString;
    }
    
    /* TABLEVIEW DELEGATE METHODS*/
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && descField.textColor != UIColor.lightGray{
            return descField.frame.height + 20;
        } else {
            return self.tableView.rowHeight;
        }
        
    }
    /* TEXTVIEW DELEGATE METHODS*/
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.ConstantStrings.placeHolderDesc;
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder();
        return true;
    }
    
    // Moves to next field when hits enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        // Create a new variable to store the instance of PlayerTableViewController
        if (segue.identifier == "toMapView") {
            let navVC = segue.destination as! UINavigationController;
            let destinationVC = navVC.viewControllers.first as! EventsLocationFinder;
            if let location = marker {
                destinationVC.selectedLocation = location;
            }
        }
    }
    
}
