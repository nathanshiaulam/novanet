//
//  EventDescriptionTableVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/5/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse


class EventDescriptionTableVC: TableViewController, UITextViewDelegate {

    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressButton: UILabel!
    
    @IBAction func notGoingPressed(sender: AnyObject) {
    }
    @IBAction func maybePressed(sender: AnyObject) {
    }
    @IBAction func goingPressed(sender: AnyObject) {
    }

    override func viewDidLoad() {
    }
    
    /* TABLEVIEW DELEGATE METHODS*/
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return descField.frame.height + 20;
        } else {
            return self.tableView.rowHeight;
        }
        
    }
    
    /* TEXTVIEW DELEGATE METHODS*/
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
    
}
