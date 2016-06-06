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

    var bot:CGFloat!;

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet var createAccount: UIButton!
    @IBOutlet var forgotPassword: UIButton!
    
    
    @IBAction func loginFunction(sender: UIButton) {
        
        let username = usernameField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let password = passwordField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        NetworkManager().userLogin(username, password: password, vc: self);
    }
    
    // Set up local data store
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    /*-------------------------------- CONSTRAINTS ------------------------------------*/
    
    @IBOutlet weak var signInHeight: NSLayoutConstraint!
    
    @IBOutlet weak var distFromSignInToBottom: NSLayoutConstraint!
    @IBOutlet weak var distFromLogoToText: NSLayoutConstraint!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var splashHorizontal: NSLayoutConstraint!
    @IBOutlet weak var splashBottom: NSLayoutConstraint!
    @IBOutlet weak var splashOtherHorizontal: NSLayoutConstraint!
    @IBOutlet weak var splashTop: NSLayoutConstraint!

    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bot = distFromSignInToBottom.constant - 20;
        let usernamePlaceholder = NSAttributedString(string: "   Username", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        let passwordPlaceholder = NSAttributedString(string: "   Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()]);
        
        usernameField.attributedPlaceholder = usernamePlaceholder;
        passwordField.attributedPlaceholder = passwordPlaceholder;
        
        loginButton.layer.cornerRadius = 5
        
        var userFrameRect = usernameField.frame;
        var passwordFrameRect = passwordField.frame;
        userFrameRect.size.height = 250;
        passwordFrameRect.size.height = 250;
        usernameField.frame = userFrameRect;
        passwordField.frame = passwordFrameRect;
        
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
    
    override func viewDidLayoutSubviews() {
        manageiOSModelType();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
       

    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            signInHeight.constant = 50
            textFieldHeight.constant = 40
            forgotPassword.titleLabel!.font = forgotPassword.titleLabel?.font.fontWithSize(14.0);
            createAccount.titleLabel!.font = createAccount.titleLabel?.font.fontWithSize(14.0);
            distFromSignInToBottom.constant = bot - 10;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            signInHeight.constant = 50
            textFieldHeight.constant = 50
            forgotPassword.titleLabel!.font = forgotPassword.titleLabel?.font.fontWithSize(16.0);
            createAccount.titleLabel!.font = createAccount.titleLabel?.font.fontWithSize(16.0);
            distFromSignInToBottom.constant = bot;
            return;
        } else if (Constants.ScreenDimensions.screenHeight == 667) {
            return; // Do nothing because designed on iPhone 6 viewport
        } else if (Constants.ScreenDimensions.screenHeight == 736) {
            splashHorizontal.constant = -20;
            splashOtherHorizontal.constant = -20;
            splashTop.constant = 0;
            return;
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
