//
//  ConfirmNovaViewController.swift
//  NovaNet
//
//  Created by Nathan Lam on 10/27/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
import MessageUI

class ConfirmNovaViewController: ViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var novaLogo: UIImageView!
    @IBOutlet weak var confirmField: UITextField!
    let defaults:UserDefaults = UserDefaults.standard;
    var keyboardVisible:Bool = false

    @IBAction func aboutNova(_ sender: UIButton) {
        if let checkURL = URL(string: "http://www.nova.com") {
            UIApplication.shared.openURL(checkURL)
        } else {
            print("invalid url")
        }
    }
    @IBAction func forgotCode(_ sender: UIButton) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["connect@nova.com"])
        mailComposerVC.setSubject("NovaNet Support")
        mailComposerVC.setMessageBody("<p>Please fill out the following details for us to help you.</p><p>Full Name:</p><p>Nova login email address (if different from this email address):</p><p>Hi Nova team,</p><p>Please help me retrieve the access code for the NovaNet app.</p>", isHTML: true)
        
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func checkConfirmation(_ sender: UIButton) {
        let confirmFieldText = confirmField.text

        let codeQuery = PFQuery(className: "EnterKey")
        codeQuery.whereKey("objectId", equalTo: Constants.ConstantStrings.confirmKey)
        codeQuery.getFirstObjectInBackground {
            (key: AnyObject?, error: Error?) -> Void in
            if error == nil {
                if let keyVal = key?["keyVal"] as? String {
                    if confirmFieldText == keyVal {
                        self.defaults.set(true, forKey: Constants.TempKeys.confirmed)
                        self.dismiss(animated: true, completion: nil);
                    } else {
                        let alert = UIAlertController(title: "Empty Field", message: "Sorry, your code is incorrect.", preferredStyle: UIAlertControllerStyle.alert);
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                print(error)
            }
        }
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        var confirmFieldRect = confirmField.frame
        confirmFieldRect.size.height = 200
        confirmField.frame = confirmFieldRect
        confirmField.layer.cornerRadius = 15
        confirmField.layer.borderWidth = 1.3
        confirmField.layer.borderColor = UIColor.lightGray.cgColor
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let confirmFieldPlaceholder = NSAttributedString(string: "Enter access code to begin", attributes: [NSForegroundColorAttributeName : UIColor.lightGray]);
        confirmField.attributedPlaceholder = confirmFieldPlaceholder;
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Allows users to hit enter and move to the next text field
    func textFieldShouldReturn(_ textField: UITextField)-> Bool {
        if (textField == confirmField) {
            textField.resignFirstResponder();
        }
        return false;
    }
    
    // Removes keyboard when tap outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
