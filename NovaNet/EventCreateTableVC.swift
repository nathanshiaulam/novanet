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


class EventCreateTableVC: TableViewController, UITextViewDelegate {
    var marker:GMSMarker!
    var selectedDate:Date!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var addressCell: UITableViewCell!
    @IBOutlet weak var eventField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    @IBAction func createEvent(_ sender: AnyObject) {
        if (titleField.text?.characters.count > 0 && dateField.text?.characters.count > 0 && descField.text.characters.count > 0 && addressField.text!.characters.count > 0 && descField.textColor != UIColor.lightGray) {
            let confirmEventAlert = UIAlertController(title: "Confirm Event Information", message: "Is all your information correct? A notification will be sent to all NovaNet members around the event once you press Ok.", preferredStyle: UIAlertControllerStyle.alert)
            let confirmEventButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                action -> Void in self.createEventAction()
            }
            let cancelEventButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
            confirmEventAlert.addAction(confirmEventButton)
            confirmEventAlert.addAction(cancelEventButton)
            self.present(confirmEventAlert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Submission Failure", message: "Please fill out all fields before creating an event.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxtext = 130
        //If the text is larger than the maxtext, the return is false
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }
    
    func createEventAction() {
        let point:PFGeoPoint = PFGeoPoint(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        let newEvent = PFObject(className: "Event")
        newEvent["Title"] = titleField.text
        newEvent["Description"] = descField.text
        newEvent["Creator"] = PFUser.current()?.objectId
        newEvent["CreatorName"] = defaults.object(forKey: Constants.UserKeys.nameKey)
        newEvent["Date"] = selectedDate
        newEvent["Position"] = point
        newEvent["EventName"] = marker.title
        newEvent["Local"] = true
        newEvent["Going"] = [(PFUser.current()?.objectId)!] as [String]
        newEvent["Maybe"] = [String]()
        newEvent["NotGoing"] = [String]()
        
        newEvent.saveInBackground( block: {
            (success: Bool, error: Error?) -> Void in
            if error == nil {
                self.sendEventsNotification(self.titleField.text!, latitude: point.latitude, longitude: point.longitude)
            }
        })
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func sendEventsNotification(_ eventName: String, latitude: Double, longitude: Double) {
        let distance = defaults.integer(forKey: Constants.UserKeys.distanceKey)
        
        PFCloud.callFunction(inBackground: "findUsers", withParameters:["lat": latitude, "lon": longitude, "dist":distance]) {
            (result, error) -> Void in
            if error == nil {
                let profileList:[PFObject] = result as! [PFObject]
                let ownName = self.defaults.string(forKey: Constants.UserKeys.nameKey)
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateInFormat = dateFormatter.string(from: date)
                
                var idList:[String] = [String]()
                for profile in profileList {
                    idList.append(profile["ID"] as! String)
                }
                
                let data:[String: Any] = [
                    "alert": "Events: " + ownName! + " has created an event in your area - " + eventName,
                    "id": (PFUser.current()?.objectId)!,
                    "date": dateInFormat,
                    "name": ownName!,
                    ] as [String : Any]
                
                let push = PFPush()
                let innerQuery : PFQuery = PFUser.query()!
                innerQuery.whereKey("objectId", containedIn: idList)
                let pushQuery = PFInstallation.query()
                pushQuery!.whereKey("user", matchesQuery: innerQuery)
                push.setQuery(pushQuery)
                push.setData(data)
                push.sendInBackground {
                    (succeeded, error) -> Void in
                    if (succeeded) {
                    } else {
                        print(error)
                    }
                }
            } else {
                print(error)
            }
        }
        
    }

    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        tableView.allowsSelection = false
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        titleField.autocapitalizationType = UITextAutocapitalizationType.words
        descField.autocapitalizationType = UITextAutocapitalizationType.sentences
        descField.text = Constants.ConstantStrings.placeHolderDesc
        descField.textColor = UIColor.lightGray

        NotificationCenter.default.addObserver(self, selector: #selector(EventCreateTableVC.saveNewLocation(_:)), name: NSNotification.Name(rawValue: "saveNewLocation"), object: nil)
        if marker == nil {
            addressCell.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if marker == nil {
            addressCell.isHidden = true
        }
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateFieldPressed(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        if (sender.text?.characters.count > 0) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.long
            dateFormatter.timeStyle = DateFormatter.Style.short
            let currDate = dateFormatter.date(from: sender.text!)
            datePickerView.date = currDate!
        }
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EventCreateTableVC.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        handleDatePicker(datePickerView)
        
    }
    
    func saveNewLocation(_ notification: Notification?) {
        marker = notification?.object as? GMSMarker
        let placeName = marker!.title
        let placeTokens = placeName?.characters.split{$0 == ","}.map(String.init)
        
        self.eventField.text = placeTokens?[0]
        let lat = marker.position.latitude
        let lon = marker.position.longitude
        
        let location = CLLocation(latitude: lat, longitude: lon)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
        
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            } else if let marks = placemarks {
                let pm = marks[0] as CLPlacemark
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, true)
                self.addressField.text = address
                self.addressCell.isHidden = false
            }
        })
        
    }

    func handleDatePicker(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let dateString = dateFormatter.string(from: (sender.date))
        selectedDate = sender.date
        dateField.text = dateString
    }
    
    /* TABLEVIEW DELEGATE METHODS*/
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && descField.textColor != UIColor.lightGray{
            return descField.frame.height + 20
        } else {
            return self.tableView.rowHeight
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
            textView.text = Constants.ConstantStrings.placeHolderDesc
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // Moves to next field when hits enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Sets the character limit of each text field
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false
        }
        
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        if (textField == titleField) {
            return newLength <= 20
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        // Create a new variable to store the instance of PlayerTableViewController
        if (segue.identifier == "toMapView") {
            let navVC = segue.destination as! UINavigationController
            let destinationVC = navVC.viewControllers.first as! EventsLocationFinder
            if let location = marker {
                destinationVC.selectedLocation = location
            }
        }
    }
    
  }
