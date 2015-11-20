//
//  ForgotPasswordViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 9/5/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class ForgotPasswordViewController: ViewController {

    @IBOutlet var emailField: UITextField!
    @IBOutlet var buttonHeight: NSLayoutConstraint!
    var screenMovementHeightUp: CGFloat!;
    var screenMovementHeightDown: CGFloat!;
   
    @IBOutlet var centerY: NSLayoutConstraint!
    @IBOutlet var subWelcomeLabel: UILabel!
    @IBOutlet var welcomeLabel: UILabel!
    @IBAction func backToLogin(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    @IBAction func sendResetEmail(sender: UIButton) {
        NetworkManager().sendResetPasswordEmail(emailField, sender: self);
    }
    
    override func viewDidLoad() {
        emailField.backgroundColor = UIColor.clearColor();
        let emailFieldPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName : Utilities().UIColorFromHex(0xA6AAA9, alpha: 1.0)]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.blackColor();
        emailField.font = UIFont(name: "Avenir", size: 16);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        screenMovementHeightUp = 0.0;
        screenMovementHeightDown  = 0.0;
        manageiOSModelType();
    }
    
    override func viewDidLayoutSubviews() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: emailField.frame.size.height - width, width:  emailField.frame.size.width, height: emailField.frame.size.height)
        
        border.borderWidth = width
        emailField.layer.addSublayer(border)
        emailField.layer.masksToBounds = true
    }

    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            welcomeLabel.font = welcomeLabel.font.fontWithSize(17.0);
            subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(14.0);
            buttonHeight.constant = 45;
            screenMovementHeightUp = 20.0;
            screenMovementHeightDown = 60.0;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            
            welcomeLabel.font = welcomeLabel.font.fontWithSize(18.0);
            subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(14.0);
            screenMovementHeightUp = 20.0;
            screenMovementHeightDown = 60.0;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            welcomeLabel.font = welcomeLabel.font.fontWithSize(24.0);
            subWelcomeLabel.font = subWelcomeLabel.font.fontWithSize(18.0);
            return;
        }
    }
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(textField: UITextField)-> Bool {
        if (textField == emailField) {
            textField.resignFirstResponder();
        }
        return false;
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= screenMovementHeightUp
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += screenMovementHeightDown
    }
    
    // Removes keyboard when tap outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
    }
    
}
