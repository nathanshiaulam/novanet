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
        PFCloud.callFunctionInBackground("sendMail", withParameters:["text":text]) {
            (result: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                println(result);
            }
        }
    }
    
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false;

        feedbackTextField.backgroundColor = UIColor.clearColor();
        feedbackTextField.text = Constants.ConstantStrings.feedbackText;
        feedbackTextField.textColor = UIColorFromHex(0xA6AAA9, alpha: 1.0);
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
