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
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    var selectedEvent:PFObject!;
    
    
    @IBAction func notGoingPressed(sender: AnyObject) {
    }
    @IBAction func maybePressed(sender: AnyObject) {
    }
    @IBAction func goingPressed(sender: AnyObject) {
    }

    override func viewDidLoad() {
        prepareView();
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
            
            let creator = event["Creator"] as? String
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
            dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle;
            let dateString = dateFormatter.stringFromDate(date)
            
            titleField.text = event["Title"] as? String
            timeLabel.text = dateString;
            descField.text = event["Description"] as? String
            organizerLabel.text = "Organized by " + creator!
        }
    }
    /* TABLEVIEW DELEGATE METHODS*/
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return descField.frame.height + 20;
        } else {
            return self.tableView.rowHeight;
        }
        
    }
    
    /* TEXTVIEW DELEGATE METHODS*/
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
    
}
