
import UIKit
import Parse
import Bolts

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = Utilities().UIColorFromHex(0xFBFBFB, alpha: 1.0)

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "BrandonGrotesque-Medium", size: 18)!]
        
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)

    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }
    func willEnterForeground(_ notification: Notification!) {
        if (Utilities().userLoggedIn()) {
            let query:PFQuery = PFQuery(className: "Profile");
            let currentID = PFUser.current()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackground {
                (profile, error) -> Void in
                if (profile == nil || error != nil) {
                    print(error);
                } else if let profile = profile {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    profile["last_active"] = dateFormatter.string(from: Date());
                    profile["Available"] = true
                    profile.saveInBackground();
                    print(dateFormatter.string(from: Date()));
                }
            }
        }
    }
    
    deinit {
        // make sure to remove the observer when this view controller is dismissed/deallocated
        
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
    }
}
