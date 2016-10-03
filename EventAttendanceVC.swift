//
//  EventAttendanceVC.swift
//  
//
//  Created by Nathan Lam on 2/7/16.
//
//

import UIKit
import Parse
import Bolts

class EventAttendanceVC:  ViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event:PFObject!
    
    @IBOutlet weak var firstCell: UIView!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func goingClicked(_ sender: UIButton) {
        self.maybeButton.isSelected = false
        self.notGoingButton.isSelected = false
        
        self.maybeButton.titleLabel?.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        self.notGoingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        
        self.maybeCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        self.notGoingCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        
        self.goingCount.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.goingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.goingButton.isSelected = true

        activeList = goingList
        
        self.tableView.reloadData()


    }
    @IBAction func maybeClicked(_ sender: UIButton) {
        self.goingButton.isSelected = false
        self.notGoingButton.isSelected = false
        
        self.goingCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        self.notGoingCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        
        self.maybeButton.titleLabel?.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        self.notGoingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        
        self.maybeCount.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.maybeButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.maybeButton.isSelected = true
        
        activeList = maybeList
        
        self.tableView.reloadData()
        
    }
    @IBAction func notGoingClicked(_ sender: UIButton) {
        self.goingButton.isSelected = false
        self.maybeButton.isSelected = false
        
        self.goingCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        self.maybeCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        
        self.goingCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        self.maybeCount.textColor = Utilities().UIColorFromHex(0x879494, alpha: 1.0)
        
        self.notGoingCount.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.notGoingButton.titleLabel?.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.notGoingButton.isSelected = true

        activeList = notGoingList
        
        self.tableView.reloadData()
        
    }
    
    @IBOutlet weak var notGoingButton: EventAttendanceButton!
    @IBOutlet weak var maybeButton: EventAttendanceButton!
    @IBOutlet weak var goingButton: EventAttendanceButton!
    
    @IBOutlet weak var notGoingCount: UILabel!
    @IBOutlet weak var maybeCount: UILabel!
    @IBOutlet weak var goingCount: UILabel!
    
    @IBOutlet weak var eventOrganizer: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    let defaults:UserDefaults = UserDefaults.standard;
    
    var activeList:[PFObject] = [PFObject]();
    var goingList:[PFObject] = [PFObject]();
    var maybeList:[PFObject] = [PFObject]();
    var notGoingList:[PFObject] = [PFObject]();
    var imageList = [UIImage?]()
    var nextImage:UIImage? = UIImage()
    
    override func viewDidLoad() {
        
        self.tableView.tableFooterView = UIView()
        maybeButton.layoutIfNeeded()
        eventTitle.text = event["Title"] as? String
        let id:String? = event["Creator"] as? String
        
        let creator:String!
        if id != PFUser.current()!.objectId {
            self.navigationItem.rightBarButtonItem = nil;
            creator = event["CreatorName"] as? String
        }
        else {
            creator = "you!"
        }

        eventOrganizer.text = "Organized by " + creator
        self.goingCount.text = String(goingList.count)
        self.maybeCount.text = String(maybeList.count)
        self.notGoingCount.text = String(notGoingList.count)
        
        self.goingButton.isSelected = true
        self.goingCount.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        self.activeList = goingList
        manageiOSModelType()
        super.viewDidLoad()


    }
    
    override func viewDidLayoutSubviews() {
        let leftLine:UIView = UIView(frame: CGRect(x: 1, y: 2.0, width: 0.5, height: 20.0))
        let rightLine:UIView = UIView(frame: CGRect(x: 69.0, y: 2.0, width: 1.5, height: 20.0))
        
        leftLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
        rightLine.backgroundColor = Utilities().UIColorFromHex(0xEEEEEE, alpha: 1.0)
        
        maybeButton.addSubview(leftLine)
        maybeButton.addSubview(rightLine)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadList()
        super.viewDidAppear(true)
    }
    
    @IBAction func backPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadList() {
        if goingButton.isSelected == true {
            self.goingCount.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            activeList = goingList
        }
        else if maybeButton.isSelected == true {
            self.maybeCount.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            activeList = maybeList
        }
        else {
            self.notGoingCount.textColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
            activeList = notGoingList
        }
    }
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activeList.count;
    }
    
    // Return the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! HomeTableViewCell
        manageiOSModelTypeCellLabels(cell);
        formatLabels(cell);
        imageList = [UIImage?](repeating: nil, count: activeList.count);
        if (activeList.count > 0) {
            let profile: AnyObject = activeList[(indexPath as NSIndexPath).row];
            
            cell.name.text = profile["Name"] as? String;
            cell.experience.text = profile["Experience"] as? String;
            cell.selectedUserId = (profile["ID"] as? String)!;
            cell.experience.lineBreakMode = NSLineBreakMode.byWordWrapping;
            cell.experience.sizeToFit();
            var image = PFFile();
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile;
                image.getDataInBackground {
                    (imageData, error) -> Void in
                    if (error == nil) {
                        cell.profileImage.image = UIImage(data:imageData!);
                        self.imageList[(indexPath as NSIndexPath).row] = UIImage(data:imageData!);
                    }
                    else {
                        print(error);
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "selectImage")!;
                self.imageList[(indexPath as NSIndexPath).row] = nil;
                
            }
            // Formats image into circle
            formatImage(cell.profileImage);
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (activeList.count > 0) {
            let profile: AnyObject = activeList[(indexPath as NSIndexPath).row]
            let image: UIImage! = imageList[(indexPath as NSIndexPath).row] as UIImage!
            
            if ((image) != nil) {
                self.nextImage = image
            } else {
                self.nextImage = nil
            }
            // Sets values for selected user
            prepareDataStore(profile as! PFObject)
            self.performSegue(withIdentifier: "toProfileView", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toProfileView" {
            let destinationVC = segue.destination.childViewControllers.first as! SelectedProfileViewController
            destinationVC.image = self.nextImage
            destinationVC.fromMessage = false
        }
    }

    // Formats image into circle if the image is a square *should probably crop to square first*
    func formatImage( _ profileImage: UIImageView) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }
    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            self.tableView.rowHeight = 65.0
            return
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            self.tableView.rowHeight = 70.0
            return
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            self.tableView.rowHeight = 75.0
            return // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            self.tableView.rowHeight = 80.0
            return
        }
    }

    
    // formats labels for each cell
    func formatLabels(_ cell: HomeTableViewCell) {
        
        // If run out of room, go to next line so it doesn't go off page
        cell.experience.lineBreakMode = NSLineBreakMode.byWordWrapping;
        cell.experience.sizeToFit();
        cell.name.lineBreakMode = NSLineBreakMode.byWordWrapping;
        cell.name.sizeToFit();
        
    }
    
    func manageiOSModelTypeCellLabels(_ cell: HomeTableViewCell) {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            cell.name.font = cell.name.font.withSize(16.0);
            cell.experience.font = cell.experience.font.withSize(12.0)
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            cell.name.font = cell.name.font.withSize(19.0);
            cell.experience.font = cell.experience.font.withSize(13.0)
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            cell.name.font = cell.name.font.withSize(22.0);
            cell.experience.font = cell.experience.font.withSize(13.0)
            return;
        }
        
    }
    
    // Sets up local datastore
    func prepareDataStore(_ profile: PFObject) {
        defaults.set(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey)
        defaults.set(profile["InterestsList"], forKey: Constants.SelectedUserKeys.selectedInterestsKey)
        defaults.set(profile["About"], forKey: Constants.SelectedUserKeys.selectedAboutKey)
        defaults.set(profile["Experience"], forKey: Constants.SelectedUserKeys.selectedExperienceKey)
        defaults.set(profile["Looking"], forKey: Constants.SelectedUserKeys.selectedLookingForKey)
        defaults.set(profile["Available"], forKey: Constants.SelectedUserKeys.selectedAvailableKey)
        defaults.set(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey)
        
    }
}
