//
//  FeedbackViewController.swift
//  
//
//  Created by Nathan Lam on 8/16/15.
//
//

import UIKit
import Parse
import Bolts

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var feedbackTextField: UITextView!
    @IBAction func sendFeedbackButton(sender: UIButton) {
        var text = feedbackTextField.text;
        if count(text) > 0 && text != Constants.ConstantStrings.feedbackText {
            PFCloud.callFunctionInBackground("sendMail", withParameters:["text":text]) {
                (result: AnyObject?, error: NSError?) -> Void in
                if error == nil {
                    var alert = UIAlertController(title: "Thanks so much- we've received your feedback.", message: Constants.ConstantStrings.feedbackAlertText, preferredStyle: UIAlertControllerStyle.Alert);
                    alert.addAction(UIAlertAction(title: "GOT IT", style: UIAlertActionStyle.Default, handler: nil));
                    self.presentViewController(alert, animated: true, completion: nil);
                    println(result);
                }
            }
        } else {
            var alert = UIAlertController(title: "Empty Form", message: Constants.ConstantStrings.feedbackEmptyText, preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "GOT IT", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            
        }
    }
    
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false;

        feedbackTextField.backgroundColor = UIColor.clearColor();
        feedbackTextField.text = Constants.ConstantStrings.feedbackText;
        feedbackTextField.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0);
        feedbackTextField.font = UIFont(name: "Avenir", size: 15.0);
        
        // Go to login page if no user logged in
        if (!self.userLoggedIn()) {
            self.performSegueWithIdentifier("toUserLogin", sender: self);
        }
    }
    
    /*-------------------------------- TextViewDel Methods ------------------------------------*/
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColorFromHex(0xA6AAA9, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.ConstantStrings.feedbackText;
            textView.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0)
        }
    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Checks if user is logged in
    func userLoggedIn() -> Bool{
        var currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }
    
    // Converts to RGB from Hex
    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // Removes keyboard when tap out of screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }


}
