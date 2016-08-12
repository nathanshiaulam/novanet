//
//  LogInViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit

import Parse
import Bolts


class LogInViewController: ViewController, UITextFieldDelegate {


    @IBOutlet weak var aboutTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var novaLogo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var createAccount: UIButton!
    @IBOutlet var forgotPassword: UIButton!
    
    var keyboardVisible:Bool = false
    var hideLogo:Bool =
        Constants.ScreenDimensions.screenHeight ==
            Constants.ScreenDimensions.IPHONE_4_HEIGHT ||
        Constants.ScreenDimensions.screenHeight ==
            Constants.ScreenDimensions.IPHONE_5_HEIGHT
    
    @IBAction func loginFunction(sender: UIButton) {
        
        let username = usernameField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let password = passwordField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        NetworkManager().userLogin(username, password: password, vc: self);
    }
    
    // Set up local data store
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();

    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let usernamePlaceholder = NSAttributedString(string: "   Username", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        let passwordPlaceholder = NSAttributedString(string: "   Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        
        usernameField.attributedPlaceholder = usernamePlaceholder;
        passwordField.attributedPlaceholder = passwordPlaceholder;
        
        loginButton.layer.cornerRadius = 5
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        usernameField.layer.cornerRadius = 15;
        passwordField.layer.cornerRadius = 15;
        passwordField.secureTextEntry = true;
        
        let email_image = UIImageView(image: UIImage(named: "login_email.png"))
        email_image.frame = CGRect(x: 0, y: 0, width: email_image.frame.width + 30, height: email_image.frame.height)
        email_image.contentMode = UIViewContentMode.Center
        usernameField.leftView = email_image
        usernameField.leftViewMode = UITextFieldViewMode.Always
        
        let password_image = UIImageView(image: UIImage(named: "login_password.png"))
        password_image.frame = CGRect(x: 0, y: 0, width: password_image.frame.width + 30, height: password_image.frame.height)
        password_image.contentMode = UIViewContentMode.Center
        passwordField.leftView = password_image
        passwordField.leftViewMode = UITextFieldViewMode.Always
        
        let usernameFieldPlaceholder = NSAttributedString(string: "E-Mail", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        usernameField.attributedPlaceholder = usernameFieldPlaceholder;
        usernameField.textColor = UIColor.whiteColor();
        
        let passwordFieldPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.whiteColor();
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.dismissToHomePage), name: "dismissToHomePage", object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    func keyboardWillShow(notification:NSNotification) {
        let changeInHeight:CGFloat = -60.0
        if (!keyboardVisible) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
                self.aboutTopConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = true
        novaLogo.hidden = hideLogo
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let changeInHeight:CGFloat = 60.0
        if (keyboardVisible) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
                self.aboutTopConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = false
        novaLogo.hidden = false
    }

    
    // Removes keyboard when tap outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
    }
    

    // Dismisses to home
    func dismissToHomePage() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // Moves to next field when hits enter
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameField) {
            passwordField.becomeFirstResponder();
        }
        else {
            NetworkManager().userLogin(usernameField.text!, password: passwordField.text!, vc: self);
            textField.resignFirstResponder();
        }
        return true;
    }
    
   

}
