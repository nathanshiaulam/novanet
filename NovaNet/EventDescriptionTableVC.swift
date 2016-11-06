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

    @IBAction func contactOrganizer(_ sender: UIButton) {
        if let email = self.email {
            let url = URL(string: "mailto:\(email)")
            UIApplication.shared.openURL(url!)
        }
    }
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func editEvent(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toEventEdit", sender: self)
    }
    
    @IBAction func goingCountClicked(_ sender: UIButton) {
        goToUserList("Going")

    }
    
    func goToUserList(_ status: String) {
        let list = selectedEvent[status] as! [String]
        let query:PFQuery = PFQuery(className: "Profile")
        query.whereKey("ID", containedIn: list)
        query.findObjectsInBackground {
            (objects, error) -> Void in
            if error == nil {
                self.userList = objects as? [PFObject]
                let maybeList = self.selectedEvent["Maybe"] as! [String]
                let maybeQuery:PFQuery = PFQuery(className: "Profile")
                maybeQuery.whereKey("ID", containedIn: maybeList)
                maybeQuery.findObjectsInBackground {
                    (objects, error) -> Void in
                    if error == nil {
                        self.maybeList = objects as? [PFObject]
                        let notGoingList = self.selectedEvent["NotGoing"] as! [String]
                        let notGoingQuery:PFQuery = PFQuery(className: "Profile")
                        notGoingQuery.whereKey("ID", containedIn: notGoingList)
                        notGoingQuery.findObjectsInBackground {
                            (objects, error) -> Void in
                            if error == nil {
                                self.notGoingList = objects as? [PFObject]
                                self.performSegue(withIdentifier: "toUserList", sender: self)
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

    @IBAction func goToCalendar(_ sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title: "Save Event", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let calendarAction = UIAlertAction(title: "Add to Calendar", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.insertEvent()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.cancel) {
            UIAlertAction in
        }

        alert.addAction(calendarAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func insertEvent() {
        let eventStore : EKEventStore = EKEventStore()
        
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (granted, error) in
            
            if (granted) && (error == nil) {
                var venueName = self.selectedEvent["Title"] as! String
                var array:[String]!
                do {
                    //Create a reggae and replace "," with any following spaces with just a comma
                    let regex = try NSRegularExpression(pattern: ", +", options: NSRegularExpression.Options.caseInsensitive)
                    venueName = regex.stringByReplacingMatches(in: venueName, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, venueName.characters.count), withTemplate: ",")
                    array = venueName.characters.split { $0 == ","}.map(String.init)
                } catch {
                    //Bad regex created
                }
                let eventName = array[0]
                let event:EKEvent = EKEvent(eventStore: eventStore)
                let startDate = (self.selectedEvent["Date"] as? Date)!
                let endDate = startDate.addingTimeInterval(60 * 60 * 2)
                event.title = eventName
                event.startDate = startDate
                event.endDate = endDate
                event.notes = (self.selectedEvent["Description"] as? String)!
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: EKSpan.thisEvent, commit: true)
                } catch {
                }
            } 
        })
    }
    @IBAction func goToAppleMaps(_ sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title: "Find Location", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let mapsAction = UIAlertAction(title: "Open in Maps", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openMaps()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        alert.addAction(mapsAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openMaps() -> Void {
        let geoPoint = selectedEvent["Position"] as? PFGeoPoint
        var venueName = selectedEvent["EventName"] as! String
        var array:[String]!
        do {
            //Create a reggae and replace "," with any following spaces with just a comma
            let regex = try NSRegularExpression(pattern: ", +", options: NSRegularExpression.Options.caseInsensitive)
            venueName = regex.stringByReplacingMatches(in: venueName, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, venueName.characters.count), withTemplate: ",")
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
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(eventName)"
        mapItem.openInMaps(launchOptions: options)

    }
    
    @IBAction func notGoingPressed(_ sender: EventAttendanceButton) {
        if (sender.isSelected) {
            var arr:[String]! = selectedEvent["NotGoing"] as! [String];
            arr = arr.filter() {$0 != PFUser.current()!.objectId};
            selectedEvent["NotGoing"] = arr;
            selectedEvent.saveInBackground();
            
        } else  {
            if (maybeButton.isSelected) {
                var arr:[String]! = selectedEvent["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                selectedEvent["Maybe"] = arr;
                selectedEvent.saveInBackground();
                maybeButton.isHighlighted = false;
                maybeButton.isSelected = false;
            }
            if (goingButton.isSelected) {
                var arr:[String]! = selectedEvent["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                selectedEvent["Going"] = arr;
                selectedEvent.saveInBackground();
                goingButton.isHighlighted = false;
                goingButton.isSelected = false;
            }
            var arr:[String]! = selectedEvent["NotGoing"] as! [String];
            if !arr.contains(PFUser.current()!.objectId!) {
                arr.append(PFUser.current()!.objectId!);
            }
            selectedEvent["NotGoing"] = arr;
            selectedEvent.saveInBackground();
        }
        sender.isSelected = !sender.isSelected;
        
    }
    @IBAction func maybePressed(_ sender: EventAttendanceButton) {
        if (sender.isSelected) {
            var arr:[String]! = selectedEvent["Maybe"] as! [String];
            arr = arr.filter() {$0 != PFUser.current()!.objectId};
            selectedEvent["Maybe"] = arr;
            selectedEvent.saveInBackground();
            
        } else  {
            if (goingButton.isSelected) {
                var arr:[String]! = selectedEvent["Going"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                selectedEvent["Going"] = arr;
                selectedEvent.saveInBackground();
                goingButton.isHighlighted = false;
                goingButton.isSelected = false;
            }
            if (notGoingButton.isSelected) {
                var arr:[String]! = selectedEvent["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                selectedEvent["NotGoing"] = arr;
                selectedEvent.saveInBackground();
                notGoingButton.isHighlighted = false;
                notGoingButton.isSelected = false;
            }
            var arr:[String]! = selectedEvent["Maybe"] as! [String];
            if !arr.contains(PFUser.current()!.objectId!) {
                arr.append(PFUser.current()!.objectId!);
            }
            selectedEvent["Maybe"] = arr;
            selectedEvent.saveInBackground();
            
        }
        sender.isSelected = !sender.isSelected;
        
    }
    @IBAction func goingPressed(_ sender: EventAttendanceButton) {
        if (sender.isSelected) {
            var arr:[String]! = selectedEvent["Going"] as! [String];
            arr = arr.filter() {$0 != PFUser.current()!.objectId};
            selectedEvent["Going"] = arr;
            selectedEvent.saveInBackground();
            
        } else  {
            if (maybeButton.isSelected) {
                var arr:[String]! = selectedEvent["Maybe"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                selectedEvent["Maybe"] = arr;
                selectedEvent.saveInBackground();
                maybeButton.isHighlighted = false;
                maybeButton.isSelected = false;
            }
            if (notGoingButton.isSelected) {
                var arr:[String]! = selectedEvent["NotGoing"] as! [String];
                arr = arr.filter() {$0 != PFUser.current()!.objectId};
                selectedEvent["NotGoing"] = arr;
                selectedEvent.saveInBackground();
                notGoingButton.isHighlighted = false;
                notGoingButton.isSelected = false;
            }
            var arr:[String]! = selectedEvent["Going"] as! [String];
            if !arr.contains(PFUser.current()!.objectId!) {
                arr.append(PFUser.current()!.objectId!);
            }
            selectedEvent["Going"] = arr;
            selectedEvent.saveInBackground()
        }
        sender.isSelected = !sender.isSelected
      
    }

    override func viewDidLoad() {
        tableView.allowsSelection = false
        descField.isEditable = false;
        NotificationCenter.default.addObserver(self, selector: #selector(EventDescriptionTableVC.eventDeleted), name: NSNotification.Name(rawValue: "eventDeleted"), object: nil)
        firstCell.layoutIfNeeded()
        setMap()
        super.viewDidLoad()
    }
    
    
    func eventDeleted() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let id:String? = selectedEvent.objectId;
        let query = PFQuery(className: "Event")
        query.whereKey("objectId", equalTo: id!);
        
        query.getFirstObjectInBackground {
            (event:AnyObject?, error: Error?) -> Void in
            if error != nil || event == nil {
                print(error)
            } else if let event = event {
                self.selectedEvent = event as! PFObject
            }
        }
        
        super.viewDidAppear(true);
    }
    
    override func viewWillLayoutSubviews() {
        self.prepareView()
    }
    
    func setMap() {
        
        if let event = selectedEvent {
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
        }
    }
    
    func prepareView() {
        if let event = selectedEvent {
            
            let date:Date! = event["Date"] as! Date
            let id:String? = event["Creator"] as? String
            
            let creator:String!
            if id != PFUser.current()!.objectId {
                self.navigationItem.rightBarButtonItem = nil;
                creator = event["CreatorName"] as? String
                let query : PFQuery = PFUser.query()!
                query.whereKey("objectId", equalTo: creator)
                query.getFirstObjectInBackground {
                    (user: PFObject?, error: Error?) -> Void in
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
                self.email = PFUser.current()?.email
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.long;
            dateFormatter.timeStyle = DateFormatter.Style.short;
            let dateString = dateFormatter.string(from: date)
            
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
            
            let leftLine:UIView = UIView(frame: CGRect(x: 1, y: 2.0, width: 0.5, height: 25.0))
            let rightLine:UIView = UIView(frame: CGRect(x: maybeButton.frame.size.width - 1.0, y: 2.0, width: 1.5, height: 25.0))
            
            leftLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
            rightLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
            
            maybeButton.addSubview(leftLine)
            maybeButton.addSubview(rightLine)
            
            if goingList.contains(PFUser.current()!.objectId!) {
                goingButton.isSelected = true;
                goingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            }
            
            if maybeList.contains(PFUser.current()!.objectId!) {
                maybeButton.isSelected = true;
                maybeButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            }
            
            if notGoingList.contains(PFUser.current()!.objectId!) {
                notGoingButton.isSelected = true;
                notGoingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            }
            let fixedWidth = descField.frame.size.width
            descField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = descField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = descField.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            descField.frame = newFrame;
        }
    }
    /* TABLEVIEW DELEGATE METHODS*/
    
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                let fixedWidth = descField.frame.size.width
                descField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = descField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = descField.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 10)
                descField.frame = newFrame;
                return 100 + descField.frame.height
            }
            if (indexPath as NSIndexPath).row >= 1 && (indexPath as NSIndexPath).row <= 4 {
                return 40
            }
            if (indexPath as NSIndexPath).row == 5 {
                return Constants.ScreenDimensions.screenWidth
            }
        }
        return self.tableView.rowHeight;
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toEventEdit" {
            let destinationVC = segue.destination.childViewControllers[0] as! EventEditTableVC
            destinationVC.selectedEvent = self.selectedEvent
        } else if segue.identifier == "toUserList" {
            let destinationVC = segue.destination.childViewControllers[0] as! EventAttendanceVC
            destinationVC.goingList = self.userList
            destinationVC.maybeList = self.maybeList
            destinationVC.notGoingList = self.notGoingList
            destinationVC.event = self.selectedEvent
        }
    }
    
    
}
