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
    
    @IBAction func backLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);

    }
    @IBOutlet var emailField: UITextField!


    @IBAction func sendResetEmail(_ sender: UIButton) {
        NetworkManager().sendResetPasswordEmail(emailField, sender: self);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        var emailFrameRect = emailField.frame
        emailFrameRect.size.height = 200
        emailField.frame = emailFrameRect
        emailField.layer.cornerRadius = 15
        emailField.layer.borderWidth = 1.3
        emailField.layer.borderColor = UIColor.lightGray.cgColor
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let email_image = UIImageView(image: UIImage(named: "login_email.png"))
        email_image.frame = CGRect(x: 0, y: 0, width: email_image.frame.width + 30, height: email_image.frame.height)
        email_image.contentMode = UIViewContentMode.center
        emailField.leftView = email_image
        emailField.leftViewMode = UITextFieldViewMode.always
        
        let emailFieldPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.lightGray]);
        emailField.attributedPlaceholder = emailFieldPlaceholder;
        emailField.textColor = UIColor.lightGray;

        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let changeInHeight:CGFloat = -140.0
        if (!keyboardVisible) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = true
        novaLogo.isHidden = true
    }
    
    func keyboardWillHide(_ notification:Notification) {
        let changeInHeight:CGFloat = 140.0
        if (keyboardVisible) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.centerConstraint.constant += changeInHeight
            })
        }
        keyboardVisible = false
        novaLogo.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }

    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(_ textField: UITextField)-> Bool {
        if (textField == emailField) {
            textField.resignFirstResponder();
        }
        return false;
    }
    
    // Removes keyboard when tap outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
}
