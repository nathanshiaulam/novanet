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
    
    @IBOutlet var tableView: UITableView!
    
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    var userList:[PFObject] = [PFObject]();
    var imageList = [UIImage?]()
    var nextImage:UIImage? = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manageiOSModelType()

    }

    @IBAction func backPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*-------------------------------- TABLE VIEW METHODS ------------------------------------*/
    
    // Return the number of rows in the section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userList.count;
    }
    
    // Return the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! HomeTableViewCell
        manageiOSModelTypeCellLabels(cell);
        formatLabels(cell);
        imageList = [UIImage?](count: userList.count, repeatedValue: nil);
        if (userList.count > 0) {
            let profile: AnyObject = userList[indexPath.row];
            
            cell.name.text = profile["Name"] as? String;
            cell.experience.text = profile["Experience"] as? String;
            cell.selectedUserId = (profile["ID"] as? String)!;
            cell.experience.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            cell.experience.sizeToFit();
            var image = PFFile();
            if let userImageFile = profile["Image"] as? PFFile {
                image = userImageFile;
                image.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if (error == nil) {
                        cell.profileImage.image = UIImage(data:imageData!);
                        self.imageList[indexPath.row] = UIImage(data:imageData!);
                    }
                    else {
                        print(error);
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "selectImage")!;
                self.imageList[indexPath.row] = nil;
                
            }
            // Formats image into circle
            formatImage(cell.profileImage);
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (userList.count > 0) {
            let profile: AnyObject = userList[indexPath.row]
            let image: UIImage! = imageList[indexPath.row] as UIImage!
            
            if ((image) != nil) {
                self.nextImage = image
            } else {
                self.nextImage = nil
            }
            // Sets values for selected user
            prepareDataStore(profile as! PFObject)
            self.performSegueWithIdentifier("toProfileView", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toProfileView" {
            let destinationVC = segue.destinationViewController.childViewControllers.first as! SelectedProfileViewController
            destinationVC.image = self.nextImage
            destinationVC.fromMessage = false
        }
    }

    // Formats image into circle if the image is a square *should probably crop to square first*
    func formatImage( profileImage: UIImageView) {
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
    func formatLabels(cell: HomeTableViewCell) {
        
        // If run out of room, go to next line so it doesn't go off page
        cell.experience.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.experience.sizeToFit();
        cell.name.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.name.sizeToFit();
        
    }
    
    func manageiOSModelTypeCellLabels(cell: HomeTableViewCell) {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            cell.name.font = cell.name.font.fontWithSize(16.0);
            cell.experience.font = cell.experience.font.fontWithSize(12.0)
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            cell.name.font = cell.name.font.fontWithSize(19.0);
            cell.experience.font = cell.experience.font.fontWithSize(13.0)
            
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            cell.name.font = cell.name.font.fontWithSize(22.0);
            cell.experience.font = cell.experience.font.fontWithSize(13.0)
            return;
        }
        
    }
    
    // Sets up local datastore
    func prepareDataStore(profile: PFObject) {
        defaults.setObject(profile["Name"], forKey: Constants.SelectedUserKeys.selectedNameKey)
        defaults.setObject(profile["InterestsList"], forKey: Constants.SelectedUserKeys.selectedInterestsKey)
        defaults.setObject(profile["About"], forKey: Constants.SelectedUserKeys.selectedAboutKey)
        defaults.setObject(profile["Experience"], forKey: Constants.SelectedUserKeys.selectedExperienceKey)
        defaults.setObject(profile["Looking"], forKey: Constants.SelectedUserKeys.selectedLookingForKey)
        defaults.setObject(profile["Available"], forKey: Constants.SelectedUserKeys.selectedAvailableKey)
        defaults.setObject(profile["ID"], forKey: Constants.SelectedUserKeys.selectedIdKey)
        
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
