
//
//  Utilities.swift
//  NovaNet
//
//  Created by Nathan Lam on 10/11/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse

class Utilities: NSObject {
    let fileManager = NSFileManager.defaultManager()

    func UIColorFromHex(rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.currentUser();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }

    func commaLimiter(textField: UITextField) {
        var ans: String! = textField.text!;
        let fullNameArr = ans.characters.split {$0 == ","}
        if fullNameArr.count <= 3 {
            let lastChar = textField.text?.characters.last;
            if (ans.characters.count > 1) {
                let truncatedString = textField.text?.substringToIndex(textField.text!.endIndex.advancedBy(-1)); // Truncates String to get second to last
                let secondToLastChar = truncatedString!.characters.last;
                if (lastChar == " ") {
                    if (secondToLastChar != ",") {
                        ans = ans.substringToIndex(ans.endIndex.advancedBy(-1)); // truncate last character
                        if fullNameArr.count < 3 {
                            ans = ans + ", ";
                        }
                    }
                }
                if (lastChar == ",") {
                    let components =  ans.componentsSeparatedByString(",")
                    let numCommas = components.count - 1
                    if numCommas > 2 {
                        ans = ans.substringToIndex(ans.endIndex.advancedBy(-1)); // truncate last character
                    } 
                }
            }
            textField.text = ans;
        }
    }
    // Methods to read and write images from local data store/Parse
    func readImage() -> UIImage {
        var oldImage =  UIImage(named: "selectImage")!
        
        let relativePath = NSUserDefaults.standardUserDefaults().stringForKey(Constants.UserKeys.profileImageKey)
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        if (relativePath != nil) {
            let fullPath = NSURL(fileURLWithPath: paths).URLByAppendingPathComponent(relativePath!).absoluteString
            let truncatedPath = fullPath.substringFromIndex(fullPath.startIndex.advancedBy(7))
            if (fileManager.fileExistsAtPath(truncatedPath)) {
                oldImage = UIImage(contentsOfFile: truncatedPath)!
            }
        }
        return oldImage
    }
    
    func saveImage(image: UIImage) {
        let query = PFQuery(className:"Profile");
        let currentID = PFUser.currentUser()!.objectId;
        query.whereKey("ID", equalTo:currentID!);

        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let path = paths[0];
        let fullPath = "\(path )/\(relativePath)"

        fileManager.createFileAtPath(fullPath, contents: imageData, attributes: nil)

        let imageFile:PFFile = PFFile(data: imageData!)
        
        query.getFirstObjectInBackgroundWithBlock {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                print(error);
            } else if let profile = profile {
                profile["Image"] = imageFile;
                profile.saveInBackground();
            }
        }
        print(relativePath);
        NSUserDefaults.standardUserDefaults().setObject(relativePath, forKey: Constants.UserKeys.profileImageKey)
//        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // Methods to format image and convert RGB to hex
    func formatImage(profileImage: UIImageView) {
        Utilities.formatImageWithWidth(profileImage, width: profileImage.frame.size.width)
    }
    
    static func formatImageReturn(profileImage: UIImageView) -> UIImage {
        let croppedImage: UIImage = ImageUtil.cropToSquare(image: profileImage.image!)
        profileImage.image = croppedImage
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
        return profileImage.image!
    }
    
    static func formatImageWithWidth(profileImage: UIImageView, width: CGFloat) {
        let croppedImage: UIImage = ImageUtil.cropToSquare(image: profileImage.image!)
        profileImage.image = croppedImage
        profileImage.layer.cornerRadius = width / 2;
        profileImage.clipsToBounds = true;
    }
    
    static func manageFontSizes(sizeToTextField: [CGFloat:[UILabel]]) {
        for (fontSize, textLabels) in sizeToTextField {
            for i in 0..<textLabels.count {
                let textLabel = textLabels[i]
                textLabel.font = UIFont(name: textLabel.font!.fontName, size: fontSize)
            }
        }
    }
}