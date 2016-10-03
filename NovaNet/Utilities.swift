
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
    let fileManager = FileManager.default

    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func userLoggedIn() -> Bool{
        let currentUser = PFUser.current();
        if ((currentUser) != nil) {
            return true;
        }
        return false;
    }

    func commaLimiter(_ textField: UITextField) {
        var ans: String! = textField.text!;
        let fullNameArr = ans.characters.split {$0 == ","}
        if fullNameArr.count <= 3 {
            let lastChar = textField.text?.characters.last;
            if (ans.characters.count > 1) {
                let truncatedString = textField.text?.substring(to: textField.text!.characters.index(textField.text!.endIndex, offsetBy: -1)); // Truncates String to get second to last
                let secondToLastChar = truncatedString!.characters.last;
                if (lastChar == " ") {
                    if (secondToLastChar != ",") {
                        ans = ans.substring(to: ans.index(ans.endIndex, offsetBy: -1)); // truncate last character
                        if fullNameArr.count < 3 {
                            ans = ans + ", ";
                        }
                    }
                }
                if (lastChar == ",") {
                    let components =  ans.components(separatedBy: ",")
                    let numCommas = components.count - 1
                    if numCommas > 2 {
                        ans = ans.substring(to: ans.index(ans.endIndex, offsetBy: -1)); // truncate last character
                    } 
                }
            }
            textField.text = ans;
        }
    }
    // Methods to read and write images from local data store/Parse
    func readImage() -> UIImage {
        var oldImage =  UIImage(named: "selectImage")!
        
        let relativePath = UserDefaults.standard.string(forKey: Constants.UserKeys.profileImageKey)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        if (relativePath != nil) {
            let fullPath = URL(fileURLWithPath: paths).appendingPathComponent(relativePath!).absoluteString
            let truncatedPath = fullPath.substring(from: fullPath.characters.index(fullPath.startIndex, offsetBy: 7))
            if (fileManager.fileExists(atPath: truncatedPath)) {
                oldImage = UIImage(contentsOfFile: truncatedPath)!
            }
        }
        return oldImage
    }
    
    func saveImage(_ image: UIImage) {
        let query = PFQuery(className:"Profile");
        let currentID = PFUser.current()!.objectId;
        query.whereKey("ID", equalTo:currentID!);

        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let relativePath = "image_\(Date.timeIntervalSinceReferenceDate).jpg"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let path = paths[0];
        let fullPath = "\(path )/\(relativePath)"

        fileManager.createFile(atPath: fullPath, contents: imageData, attributes: nil)

        let imageFile:PFFile = PFFile(data: imageData!)
        
        query.getFirstObjectInBackground {
            (profile: PFObject?, error: NSError?) -> Void in
            if error != nil || profile == nil {
                print(error);
            } else if let profile = profile {
                profile["Image"] = imageFile;
                profile.saveInBackground();
            }
        }
        print(relativePath);
        UserDefaults.standard.set(relativePath, forKey: Constants.UserKeys.profileImageKey)
//        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // Methods to format image and convert RGB to hex
    func formatImage(_ profileImage: UIImageView) {
        Utilities.formatImageWithWidth(profileImage, width: profileImage.frame.size.width)
    }
    
    static func formatImageReturn(_ profileImage: UIImageView) -> UIImage {
        let croppedImage: UIImage = ImageUtil.cropToSquare(image: profileImage.image!)
        profileImage.image = croppedImage
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
        return profileImage.image!
    }
    
    static func formatImageWithWidth(_ profileImage: UIImageView, width: CGFloat) {
        let croppedImage: UIImage = ImageUtil.cropToSquare(image: profileImage.image!)
        profileImage.image = croppedImage
        profileImage.layer.cornerRadius = width / 2;
        profileImage.clipsToBounds = true;
    }
    
    static func manageFontSizes(_ sizeToTextField: [CGFloat:[UILabel]]) {
        for (fontSize, textLabels) in sizeToTextField {
            for i in 0..<textLabels.count {
                let textLabel = textLabels[i]
                textLabel.font = UIFont(name: textLabel.font!.fontName, size: fontSize)
            }
        }
    }
}
