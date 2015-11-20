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


class EventCreateTableVC: TableViewController {
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var dateField: UITextField!
    override func viewDidLoad() {
        let datePicker:UIDatePicker = UIDatePicker();
        datePicker.setDate(NSDate(), animated: true);
        datePicker.addTarget(self, action: "updateTextField:", forControlEvents: UIControlEvents.ValueChanged);
        dateField.inputView = datePicker;
        
        
    }
    
    
    
    func updateTextField() {
        let datePicker:UIDatePicker? = dateField.inputView as? UIDatePicker;
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm";
        let dateString = dateFormatter.stringFromDate((datePicker?.date)!)

        dateField.text = dateString;
    }
}
