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
import EventKit

class EventDescriptionTableVC: TableViewController, UITextViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var firstCell: UITableViewCell!
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var selectedEvent:PFObject!
    var userList: [PFObject]!
    var maybeList: [PFObject]!
    var notGoingList: [PFObject]!
    var email: String!
    @IBOutlet weak var descField: UITextView!

    @IBAction func contactOrganizer(sender: UIButton) {
        let email = self.email
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
    @IBAction func goBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func editEvent(sender: AnyObject) {
        self.performSegueWithIdentifier("toEventEdit", sender: self)
    }
    
    @IBAction func goingCountClicked(sender: UIButton) {
        goToUserList("Going")

    }
    
    func goToUserList(status: String) {
        let list = selectedEvent[status] as! [String]
        let query:PFQuery = PFQuery(className: "Profile")
        query.whereKey("ID", containedIn: list)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.userList = objects as? [PFObject]
                let maybeList = self.selectedEvent["Maybe"] as! [String]
                let maybeQuery:PFQuery = PFQuery(className: "Profile")
                maybeQuery.whereKey("ID", containedIn: maybeList)
                maybeQuery.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    if error == nil {
                        self.maybeList = objects as? [PFObject]
                        let notGoingList = self.selectedEvent["NotGoing"] as! [String]
                        let notGoingQuery:PFQuery = PFQuery(className: "Profile")
                        notGoingQuery.whereKey("ID", containedIn: notGoingList)
                        notGoingQuery.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            if error == nil {
                                self.notGoingList = objects as? [PFObject]
                                self.performSegueWithIdentifier("toUserList", sender: self)
                            } else {
                                print(error)
                            }
                        }
                    } else {
                        print(error)
                    }
                }
            } else {
                print(error)
            }
        }
        
        
    }
    
    
    @IBOutlet weak var goingButton: EventAttendanceButton!
    @IBOutlet weak var maybeButton: EventAttendanceButton!
    @IBOutlet weak var notGoingButton: EventAttendanceButton!
    
    @IBOutlet weak var goingCount: UIButton!

    @IBAction func goToCalendar(sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title: "Save Event", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let calendarAction = UIAlertAction(title: "Add to Calendar", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.insertEvent()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alert.addAction(calendarAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func insertEvent() {
        let eventStore : EKEventStore = EKEventStore()
        
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            (granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                var venueName = self.selectedEvent["EventName"] as! String
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
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                let startDate = (self.selectedEvent["Date"] as? NSDate)!
                let endDate = startDate.dateByAddingTimeInterval(60 * 60 * 2)
                event.title = eventName
                event.startDate = startDate
                event.endDate = endDate
                event.notes = (self.selectedEvent["Description"] as? String)!
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                } catch {
                }
                
                print("Saved Event") 
            } 
        })
    }
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
            
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = selectedEvent["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Maybe"] = arr;
                selectedEvent.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
            }
            if (goingButton.selected) {
                var arr:[String]! = selectedEvent["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Going"] = arr;
                selectedEvent.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
            }
            var arr:[String]! = selectedEvent["NotGoing"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            selectedEvent["NotGoing"] = arr;
            selectedEvent.saveInBackground();
        }
        sender.selected = !sender.selected;
        
    }
    @IBAction func maybePressed(sender: EventAttendanceButton) {
        if (sender.selected) {
            var arr:[String]! = selectedEvent["Maybe"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            selectedEvent["Maybe"] = arr;
            selectedEvent.saveInBackground();
            
        } else  {
            if (goingButton.selected) {
                var arr:[String]! = selectedEvent["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Going"] = arr;
                selectedEvent.saveInBackground();
                goingButton.highlighted = false;
                goingButton.selected = false;
            }
            if (notGoingButton.selected) {
                var arr:[String]! = selectedEvent["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["NotGoing"] = arr;
                selectedEvent.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
            }
            var arr:[String]! = selectedEvent["Maybe"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            selectedEvent["Maybe"] = arr;
            selectedEvent.saveInBackground();
            
        }
        sender.selected = !sender.selected;
        
    }
    @IBAction func goingPressed(sender: EventAttendanceButton) {
        if (sender.selected) {
            var arr:[String]! = selectedEvent["Going"] as! [String];
            arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
            selectedEvent["Going"] = arr;
            selectedEvent.saveInBackground();
            
        } else  {
            if (maybeButton.selected) {
                var arr:[String]! = selectedEvent["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["Maybe"] = arr;
                selectedEvent.saveInBackground();
                maybeButton.highlighted = false;
                maybeButton.selected = false;
            }
            if (notGoingButton.selected) {
                var arr:[String]! = selectedEvent["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.currentUser()!.objectId};
                selectedEvent["NotGoing"] = arr;
                selectedEvent.saveInBackground();
                notGoingButton.highlighted = false;
                notGoingButton.selected = false;
            }
            var arr:[String]! = selectedEvent["Going"] as! [String];
            if !arr.contains(PFUser.currentUser()!.objectId!) {
                arr.append(PFUser.currentUser()!.objectId!);
            }
            selectedEvent["Going"] = arr;
            selectedEvent.saveInBackground()
        }
        sender.selected = !sender.selected
      
    }

    override func viewDidLoad() {
        tableView.allowsSelection = false
        descField.editable = false;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventDescriptionTableVC.eventDeleted), name: "eventDeleted", object: nil)
        firstCell.layoutIfNeeded()
        super.viewDidLoad()
    }
    
    func eventDeleted() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            
            let location = CLLocation(latitude: lat, longitude: lon);
            let mapLoc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let eventLocName = event["EventName"] as? String;
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapLoc
            annotation.title = eventLocName
            
            mapView.centerCoordinate = mapLoc
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                      500 * 2.0, 500 * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
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
            let id:String? = event["Creator"] as? String
            
            let creator:String!
            if id != PFUser.currentUser()!.objectId {
                self.navigationItem.rightBarButtonItem = nil;
                creator = event["CreatorName"] as? String
                let query : PFQuery = PFUser.query()!
                query.whereKey("objectId", equalTo: creator)
                query.getFirstObjectInBackgroundWithBlock {
                    (user: PFObject?, error: NSError?) -> Void in
                    if error != nil || user == nil {
                        print(error);
                    }
                    else {
                        let creator_user = user as! PFUser
                        self.email = creator_user.email
                    }
                }

            }
            else {
                creator = "you!"
                self.email = PFUser.currentUser()?.email
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
            
            goingButton.titleLabel!.font = UIFont(name: "OpenSans", size: 12.0)
            maybeButton.titleLabel?.font = UIFont(name: "OpenSans", size: 12.0)
            notGoingButton.titleLabel!.font = UIFont(name: "OpenSans", size: 12.0)
            
            let leftLine:UIView = UIView(frame: CGRectMake(1, 2.5, 1.5, maybeButton.frame.size.height - 5.0))
            let rightLine:UIView = UIView(frame: CGRectMake(maybeButton.frame.size.width - 1, 2.5, 1.5, maybeButton.frame.size.height - 5.0))
            
            leftLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
            rightLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
            
            maybeButton.addSubview(leftLine)
            maybeButton.addSubview(rightLine)
            
            if goingList.contains(PFUser.currentUser()!.objectId!) {
                goingButton.selected = true;
                goingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            }
            
            if maybeList.contains(PFUser.currentUser()!.objectId!) {
                maybeButton.selected = true;
                maybeButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            }
            
            if notGoingList.contains(PFUser.currentUser()!.objectId!) {
                notGoingButton.selected = true;
                notGoingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
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
                descField.sizeToFit()
                descField.layoutIfNeeded()
                return 100 + descField.frame.height
            }
            if indexPath.row >= 1 && indexPath.row <= 4 {
                return 40
            }
            if indexPath.row == 5 {
                return Constants.ScreenDimensions.screenWidth
            }
        }
        return self.tableView.rowHeight;
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toEventEdit" {
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! EventEditTableVC
            destinationVC.selectedEvent = self.selectedEvent
        } else if segue.identifier == "toUserList" {
            let destinationVC = segue.destinationViewController.childViewControllers[0] as! EventAttendanceVC
            destinationVC.goingList = self.userList
            destinationVC.maybeList = self.maybeList
            destinationVC.notGoingList = self.notGoingList
        }
    }
    
    
}
