//
//  SignUpViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts

class SignUpViewController: ViewController {

    
    var bot:CGFloat!;

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBAction func cancelFunction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    @IBAction func signUpFunction(sender: UIButton) {
        NetworkManager().createUser( emailField.text!, password:passwordField.text!, confPassword:confirmPasswordField.text!, sender: self);
    }
    
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    /*-------------------------------- CONSTRAINTS ------------------------------------*/
    
    @IBOutlet weak var signInHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldY: NSLayoutConstraint!
    @IBOutlet weak var distFromSignInToBottom: NSLayoutConstraint!
    @IBOutlet weak var distFromLogoToText: NSLayoutConstraint!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var splashHorizontal: NSLayoutConstraint!
    @IBOutlet weak var splashBottom: NSLayoutConstraint!
    @IBOutlet weak var splashOtherHorizontal: NSLayoutConstraint!
    @IBOutlet weak var splashTop: NSLayoutConstraint!
  
    /*-------------------------------- HELPER METHODS ------------------------------------*/
   
    // Sets up installation so that the current user receives push notifications
    func setUpInstallations() {
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
    }
    
    func manageiOSModelType() {
        if (Constants.ScreenDimensions.screenHeight == 480) {
            signInHeight.constant = 50
            textFieldHeight.constant = 40
            distFromSignInToBottom.constant = bot - 10;
            textFieldY.constant = -30

            return;
        } else if (Constants.ScreenDimensions.screenHeight == 568) {
            signInHeight.constant = 50
            textFieldHeight.constant = 50
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


    
    
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(textField: UITextField)-> Bool {
        if (textField ==  emailField) {
            passwordField.becomeFirstResponder();
        }
        else if (textField == passwordField) {
            textField.resignFirstResponder()
            confirmPasswordField.becomeFirstResponder();
        }
        else {
            let confPassword:String =  confirmPasswordField.text!.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let password:String = passwordField.text!.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let email:String = emailField.text!.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            NetworkManager().createUser(email, password: password, confPassword: confPassword, sender: self);
            textField.resignFirstResponder();
        }
        return false;
    }
    

    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    // Basically style and format all of the textfields
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.secureTextEntry = true;
        confirmPasswordField.secureTextEntry = true;
        bot = distFromSignInToBottom.constant - 20;
        signupButton.layer.cornerRadius = 5
        var confPasswordFramRect =  confirmPasswordField.frame;
        var passwordFrameRect = passwordField.frame;
        var emailFrameRect = emailField.frame;

        confPasswordFramRect.size.height = 200;
        passwordFrameRect.size.height = 200;
        emailFrameRect.size.height = 200;
        
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        
        confirmPasswordField.frame = confPasswordFramRect;
        passwordField.frame = passwordFrameRect;
        emailField.frame = emailFrameRect;
        
        confirmPasswordField.layer.cornerRadius = 15;
        passwordField.layer.cornerRadius = 15;
        emailField.layer.cornerRadius = 15;
 
        let email_image = UIImageView(image: UIImage(named: "login_email.png"))
        email_image.frame = CGRect(x: 0, y: 0, width: email_image.frame.width + 30, height: email_image.frame.height)
        email_image.contentMode = UIViewContentMode.Center
        emailField.leftView = email_image
        emailField.leftViewMode = UITextFieldViewMode.Always
        
        let password_image = UIImageView(image: UIImage(named: "login_password.png"))
        password_image.frame = CGRect(x: 0, y: 0, width: password_image.frame.width + 30, height: password_image.frame.height)
        password_image.contentMode = UIViewContentMode.Center
        passwordField.leftView = password_image
        passwordField.leftViewMode = UITextFieldViewMode.Always
        
        let confirmPasswordImage = UIImageView(image: UIImage(named: "login_password.png"))
        confirmPasswordImage.frame = CGRect(x: 0, y: 0, width: confirmPasswordImage.frame.width + 30, height: confirmPasswordImage.frame.height)
        confirmPasswordImage.contentMode = UIViewContentMode.Center
        confirmPasswordField.leftView = confirmPasswordImage
        confirmPasswordField.leftViewMode = UITextFieldViewMode.Always
        
        let  confirmPasswordFieldPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
         confirmPasswordField.attributedPlaceholder =  confirmPasswordFieldPlaceholder;
         confirmPasswordField.textColor = UIColor.whiteColor();
        
        let passwordFieldPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.whiteColor();
        
        let emailFieldPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.whiteColor();
    }
    
    override func viewDidLayoutSubviews() {
        manageiOSModelType();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
