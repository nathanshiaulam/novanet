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

    @IBOutlet weak var novaLogo: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    var keyboardVisible:Bool = false
    var hideLogo:Bool =
        Constants.ScreenDimensions.screenHeight ==
            Constants.ScreenDimensions.IPHONE_4_HEIGHT ||
            Constants.ScreenDimensions.screenHeight ==
            Constants.ScreenDimensions.IPHONE_5_HEIGHT
    
    @IBAction func cancelFunction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil);
    }
    @IBAction func signUpFunction(_ sender: UIButton) {
        createUser()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    /*-------------------------------- CONSTRAINTS ------------------------------------*/
    
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutTopConstraint: NSLayoutConstraint!
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(_ textField: UITextField)-> Bool {
        if (textField ==  emailField) {
            passwordField.becomeFirstResponder()
        }
        else if (textField == passwordField) {
            textField.resignFirstResponder()
            confirmPasswordField.becomeFirstResponder()
        }
        else {
            createUser()
            textField.resignFirstResponder()
        }
        return false;
    }
    
    private func createUser() {
        let confPassword:String =  confirmPasswordField.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        let password:String = passwordField.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        let email:String = emailField.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        if (validInput(email: email, password: password, confPassword: confPassword)) {
            UserAPI.sharedInstance.create(email: email, password: password, completion: onUserCreate, error: errorHandler)
        }
    }
    
    private func validInput(email: String, password: String, confPassword: String) -> Bool {
        if (email.characters.count == 0 || password.characters.count == 0 || confPassword.characters.count == 0) {
            Utilities.presentStandardError(errorString: "Invalid password or email", alertTitle: "Submission Failure", actionTitle: "Ok", sender: self)
            return false
        }
        if (password != confPassword) {
            Utilities.presentStandardError(errorString: "Your passwords don't match!", alertTitle: "Submission Failure", actionTitle: "Ok", sender: self)
            return false
        }
        return true
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let changeInHeight:CGFloat = -75.0
        if (!keyboardVisible) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
                self.aboutTopConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = true
        novaLogo.isHidden = hideLogo
    }
    
    func keyboardWillHide(_ notification:Notification) {
        let changeInHeight:CGFloat = 75.0
        if (keyboardVisible) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
                self.aboutTopConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = false
        novaLogo.isHidden = false
    }
    
    public func onUserCreate() {
        // Extract email
        let email:String = emailField.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        // Create Profile
        let id:String = PFUser.current()!.objectId!
        let prof = Profile(id: id, greeting: Constants.ConstantStrings.greetingMessage, email: email)
        ProfileAPI.sharedInstance.create(prof: prof)
        
        // Dismiss to home
        self.dismiss(animated: true, completion: { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissToHomePage"), object: nil);
        })
        
    }
    
    public func errorHandler(error: String) {
        Utilities.presentStandardError(errorString: error, alertTitle: "Submission Failure", actionTitle: "Ok", sender: self)
    }

    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/

    // Basically style and format all of the textfields
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        passwordField.isSecureTextEntry = true;
        confirmPasswordField.isSecureTextEntry = true;

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
        email_image.contentMode = UIViewContentMode.center
        emailField.leftView = email_image
        emailField.leftViewMode = UITextFieldViewMode.always
        
        let password_image = UIImageView(image: UIImage(named: "login_password.png"))
        password_image.frame = CGRect(x: 0, y: 0, width: password_image.frame.width + 30, height: password_image.frame.height)
        password_image.contentMode = UIViewContentMode.center
        passwordField.leftView = password_image
        passwordField.leftViewMode = UITextFieldViewMode.always
        
        let confirmPasswordImage = UIImageView(image: UIImage(named: "login_password.png"))
        confirmPasswordImage.frame = CGRect(x: 0, y: 0, width: confirmPasswordImage.frame.width + 30, height: confirmPasswordImage.frame.height)
        confirmPasswordImage.contentMode = UIViewContentMode.center
        confirmPasswordField.leftView = confirmPasswordImage
        confirmPasswordField.leftViewMode = UITextFieldViewMode.always
        
        let  confirmPasswordFieldPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName : UIColor.white]);
         confirmPasswordField.attributedPlaceholder =  confirmPasswordFieldPlaceholder;
         confirmPasswordField.textColor = UIColor.white;
        
        let passwordFieldPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.white]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.white;
        
        let emailFieldPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.white]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.white;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
