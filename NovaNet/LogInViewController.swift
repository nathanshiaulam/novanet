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
    
    @IBAction func loginFunction(_ sender: UIButton) {
        
        let username = usernameField.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        let password = passwordField.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        NetworkManager().userLogin(username, password: password, vc: self);
    }
    
    // Set up local data store
    let defaults:UserDefaults = UserDefaults.standard;

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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.view.endEditing(true);
    }
    

    // Dismisses to home
    func dismissToHomePage() {
        self.dismiss(animated: true, completion: nil);
    }
    
    // Moves to next field when hits enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
