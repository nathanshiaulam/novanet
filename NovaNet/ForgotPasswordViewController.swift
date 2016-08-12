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
    
    @IBOutlet weak var novaLogo: UIImageView!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    var keyboardVisible:Bool = false
    
    @IBOutlet var emailField: UITextField!

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
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let changeInHeight:CGFloat = -140.0
        if (!keyboardVisible) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = true
        novaLogo.hidden = true
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let changeInHeight:CGFloat = 140.0
        if (keyboardVisible) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = false
        novaLogo.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }

    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(textField: UITextField)-> Bool {
        if (textField == emailField) {
            textField.resignFirstResponder();
        }
        return false;
    }
    
    // Removes keyboard when tap outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
    }
    
}
