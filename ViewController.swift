
import UIKit
import Parse
import Bolts

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationDidFinishLaunchingNotification, object: nil)

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