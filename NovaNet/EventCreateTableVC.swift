//
//  EventCreateTableVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/5/15.
//  Copyright © 2015 Nova. All rights reserved.
//


import Foundation
import Bolts
import Parse


class EventCreateTableVC: TableViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descField: UITextView!
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: "endEditing:"));
        tableView.allowsSelection = false;
        
        descField.text = Constants.ConstantStrings.placeHolderDesc;
        descField.textColor = UIColor.lightGrayColor()
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func dateFieldPressed(sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        if (sender.text?.characters.count > 0) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
            dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle;
            let currDate = dateFormatter.dateFromString(sender.text!);
            datePickerView.date = currDate!;
        }

        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        handleDatePicker(datePickerView);
        
    }

    func handleDatePicker(sender: UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle;
        
        let dateString = dateFormatter.stringFromDate((sender.date))
        
        dateField.text = dateString;
    }
    
    /* TABLEVIEW DELEGATE METHODS*/
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 3 && descField.textColor != UIColor.lightGrayColor(){
            print("hi");
            return descField.frame.height + 20;
        } else {
            return self.tableView.rowHeight;
        }
        
    }
    /* TEXTVIEW DELEGATE METHODS*/
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.ConstantStrings.placeHolderDesc;
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    
  }
