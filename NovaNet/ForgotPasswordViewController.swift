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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var emailFrameRect = emailField.frame
        emailFrameRect.size.height = 200
        emailField.frame = emailFrameRect
        emailField.layer.cornerRadius = 15
        emailField.layer.borderWidth = 1.3
        emailField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let email_image = UIImageView(image: UIImage(named: "login_email.png"))
        email_image.frame = CGRect(x: 0, y: 0, width: email_image.frame.width + 30, height: email_image.frame.height)
        email_image.contentMode = UIViewContentMode.Center
        emailField.leftView = email_image
        emailField.leftViewMode = UITextFieldViewMode.Always
        
        let emailFieldPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.lightGrayColor();

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        screenMovementHeightUp = 0.0;
        screenMovementHeightDown  = 0.0;
        manageiOSModelType();
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
