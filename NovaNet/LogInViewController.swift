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
    
    var username:String = ""
    var password:String = ""
    var keyboardVisible:Bool = false
    var hideLogo:Bool =
        Constants.ScreenDimensions.screenHeight ==
            Constants.ScreenDimensions.IPHONE_4_HEIGHT ||
        Constants.ScreenDimensions.screenHeight ==
            Constants.ScreenDimensions.IPHONE_5_HEIGHT
    
    @IBAction func loginFunction(_ sender: UIButton) {
        loginUser()
    }
    
    private func loginUser() {
        if (validInput()) {
            UserAPI.sharedInstance.logIn(
                username: username,
                password: password,
                completion: onUserLogin,
                error: errorHandler)
        }
    }
    
    private func validInput() -> Bool {
        if username.length == 0 || password.length == 0 {
            Utilities.presentStandardError(errorString: "Invalid password or username", alertTitle: "Submission Failure", actionTitle: "Ok", sender: self)
            return false
        }
        return true
    }
    
    public func onUserLogin() {
        let id = PFUser.current()!.objectId
        ProfileAPI.sharedInstance.getProfileByUserId(userId: id!, completion: onFetchProfile)
        
        self.dismiss(animated: true, completion: nil);
    }
    
    public func onFetchProfile(prof: Profile) {
        ProfileAPI.sharedInstance.setAvailability(prof: prof, available: true)
        UserAPI.sharedInstance.setUserDefaults(id: prof.getUserId(), prof: prof)
    }
    
    public func errorHandler(error: String) {
        Utilities.presentStandardError(errorString: error, alertTitle: "Submission Failure", actionTitle: "Ok", sender: self)
    }
    
    /*-------------------------------- HELPER METHODS ------------------------------------*/
    
    func keyboardWillShow(_ notification:Notification) {
        let changeInHeight:CGFloat = -60.0
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
        let changeInHeight:CGFloat = 60.0
        if (keyboardVisible) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
                self.aboutTopConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = false
        novaLogo.isHidden = false
    }
    
    // Removes keyboard when tap outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        username = usernameField.text!.trimmed
        password = passwordField.text!.trimmed
        self.view.endEditing(true);
    }

    // Dismisses to home
    public func dismissToHomePage() {
        self.dismiss(animated: true, completion: nil);
    }
    
    // Moves to next field when hits enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == usernameField) {
            username = usernameField.text!.trimmed
            passwordField.becomeFirstResponder();
        }
        else {
            password = passwordField.text!.trimmed
            loginUser()
            textField.resignFirstResponder();
        }
        return true;
    }
    
    /*-------------------------------- NIB LIFE CYCLE METHODS ------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let usernamePlaceholder = NSAttributedString(string: "   Username", attributes: [NSForegroundColorAttributeName : UIColor.gray]);
        let passwordPlaceholder = NSAttributedString(string: "   Password", attributes: [NSForegroundColorAttributeName : UIColor.gray]);
        
        usernameField.attributedPlaceholder = usernamePlaceholder;
        passwordField.attributedPlaceholder = passwordPlaceholder;
        loginButton.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        usernameField.layer.cornerRadius = 15;
        passwordField.layer.cornerRadius = 15;
        passwordField.isSecureTextEntry = true;
        
        let email_image = UIImageView(image: UIImage(named: "login_email.png"))
        email_image.frame = CGRect(x: 0, y: 0, width: email_image.frame.width + 30, height: email_image.frame.height)
        email_image.contentMode = UIViewContentMode.center
        usernameField.leftView = email_image
        usernameField.leftViewMode = UITextFieldViewMode.always
        
        let password_image = UIImageView(image: UIImage(named: "login_password.png"))
        password_image.frame = CGRect(x: 0, y: 0, width: password_image.frame.width + 30, height: password_image.frame.height)
        password_image.contentMode = UIViewContentMode.center
        passwordField.leftView = password_image
        passwordField.leftViewMode = UITextFieldViewMode.always
        
        let usernameFieldPlaceholder = NSAttributedString(string: "E-Mail", attributes: [NSForegroundColorAttributeName : UIColor.white]);
        usernameField.attributedPlaceholder = usernameFieldPlaceholder;
        usernameField.textColor = UIColor.white;
        
        let passwordFieldPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.white]);
        passwordField.attributedPlaceholder = passwordFieldPlaceholder;
        passwordField.textColor = UIColor.white;
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.dismissToHomePage), name: NSNotification.Name(rawValue: "dismissToHomePage"), object: nil);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismissToHomePage"), object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}
