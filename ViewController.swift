
import UIKit
import Parse
import Bolts

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 18)!]
        
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.willEnterForeground(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.willEnterForeground(_:)), name: UIApplicationDidFinishLaunchingNotification, object: nil)

    }
    
    func willEnterForeground(notification: NSNotification!) {
        if (Utilities().userLoggedIn()) {
            let query:PFQuery = PFQuery(className: "Profile");
            let currentID = PFUser.currentUser()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackgroundWithBlock {
                (profile: PFObject?, error: NSError?) -> Void in
                if (profile == nil || error != nil) {
                    print(error);
                } else if let profile = profile {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    profile["last_active"] = dateFormatter.stringFromDate(NSDate());
                    profile["Available"] = true
                    profile.saveInBackground();
                    print(dateFormatter.stringFromDate(NSDate()));
                }
            }
        }
    }
    
    deinit {
        // make sure to remove the observer when this view controller is dismissed/deallocated
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: nil, object: nil)
    }
}