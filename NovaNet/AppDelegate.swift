//
//  AppDelegate.swift
//  NovaNet
//
//  Created by Nathan Lam on 7/14/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//

import UIKit
import Parse
import Bolts
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults:UserDefaults = UserDefaults.standard;
    var posted:Bool = false;
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        let navigationBarAppearance = UINavigationBar.appearance()
        let tabBarAppearance = UITabBar.appearance()

        let cancelButtonAttributes: NSDictionary = [NSFontAttributeName: UIFont(name: "BrandonGrotesque-Medium", size: 16.0)!, NSForegroundColorAttributeName: UIColor.white]
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState())
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.isTranslucent = false
        
        tabBarAppearance.barTintColor = UIColor.white
        tabBarAppearance.layer.borderWidth = 0.50
        tabBarAppearance.layer.borderColor = UIColor.clear.cgColor
        tabBarAppearance.clipsToBounds = true
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("ni7bpwOhWr114Rom27cx4QSv27Ud3tyMl0tZchxw",
            clientKey: "NqfIkHWioqiH93TsSijAvcoMNzWDgyx8Z9hoLJL2")
        GMSServices.provideAPIKey("AIzaSyBweBvAkvyDFpocqomLn9vNdM0OILJqBsQ")
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        if (PFUser.current() != nil) {
            let query = PFQuery(className:"Profile");
            let currentID = PFUser.current()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackground {
                (profile: PFObject?, error: NSError?) -> Void in
                if error != nil || profile == nil {
                    print(error);
                } else if let profile = profile {
                    
                    // Sets up local datastore
                    let fromNew:Bool = (profile["New"] as? Bool)!
                    if (!fromNew) {
                        profile["Available"] = true
                        
                        self.defaults.set(profile["Name"], forKey: Constants.UserKeys.nameKey)
                        self.defaults.set(PFUser.current()!.email, forKey: Constants.UserKeys.emailKey)
                        self.defaults.set(profile["InterestsList"], forKey: Constants.UserKeys.interestsKey)
                        self.defaults.set(profile["About"], forKey: Constants.UserKeys.aboutKey)
                        self.defaults.set(profile["Experience"], forKey: Constants.UserKeys.experienceKey)
                        self.defaults.set(profile["Looking"], forKey: Constants.UserKeys.lookingForKey)
                        self.defaults.set(profile["Distance"], forKey: Constants.UserKeys.distanceKey)
                        self.defaults.set(profile["Available"], forKey: Constants.UserKeys.availableKey)
                        self.defaults.set(profile["New"], forKey: Constants.TempKeys.fromNew)
                        self.defaults.set(profile["Greeting"], forKey: Constants.UserKeys.greetingKey)
                        
                        
                        // Stores image in local data store and refreshes image from Parse
                        let userImageFile = profile["Image"] as! PFFile;
                        userImageFile.getDataInBackground {
                            (imageData, error) -> Void in
                            if (error == nil) {
                                let image = UIImage(data:imageData!);
                                Utilities().saveImage(image!);
                            }
                            else {
                                let placeHolder = UIImage(named: "selectImage");
                                Utilities().saveImage(placeHolder!);
                                print(error);
                            }
                        }
                        profile.saveInBackground()
                    }
                    
                }
            }
        }
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor.white

        // Register for Push Notitications
        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
            let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
        }
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications();
        }
        if (launchOptions != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            let navigation = appDelegate.window!.rootViewController as! UINavigationController
            let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageListVC") as! ConversationListTableViewController
            let eventsListVC = storyboard.instantiateViewController(withIdentifier: "EventsListVC") as! EventsFinderTableVC

            if (PFUser.current() != nil) {
                if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                    let name: AnyObject? = notificationPayload["name"]
                    let alert: String? = notificationPayload["alert"] as? String
                    let id: AnyObject? = notificationPayload["id"]
                    
                    print(((alert)! as NSString).substring(to: 7))
                    if (((alert)! as NSString).substring(to: 7) == "Events:") {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "phoneVibrate"), object: nil)
                        posted = true
                        navigation.pushViewController(eventsListVC, animated: true);
                    } else {
                        defaults.set(notificationPayload, forKey: Constants.TempKeys.notificationPayloadKey);
                        defaults.set(name, forKey: Constants.SelectedUserKeys.selectedNameKey)
                        defaults.set(id, forKey: Constants.SelectedUserKeys.selectedIdKey)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "phoneVibrate"), object: nil);
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadConversations"), object: nil);
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadData"), object: nil);
                        posted = true
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "goToMessageVC"), object: nil);
                        navigation.pushViewController(messageVC, animated: true);
                    }
                }
            }
        }
        
        return true
    }
    
    // Parse Push Notification Functions
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation.setDeviceTokenFrom(deviceToken)
        installation.saveInBackground()
    }
    func application(_ application: UIApplication, didRegister settings: UIUserNotificationSettings) {
        if (settings.types != UIUserNotificationType()) {
            print("Did register user");
            application.registerForRemoteNotifications();
        }
    }
    func dateFromString(_ date: String, format: String) -> Date {
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.date(from: date)!
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        if (PFUser.current() != nil) {
            if let notificationPayload:NSDictionary = userInfo as NSDictionary? {
                let name: AnyObject? = notificationPayload["name"];
                let id: AnyObject? = notificationPayload["id"];

                defaults.set(notificationPayload, forKey: Constants.TempKeys.notificationPayloadKey);
                defaults.set(name, forKey: Constants.SelectedUserKeys.selectedNameKey)
                defaults.set(id, forKey: Constants.SelectedUserKeys.selectedIdKey)
                if (!posted) {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "phoneVibrate"), object: nil);
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loadConversations"), object: nil);
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loadData"), object: nil);
                }
            }
        }
        PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
    }
   

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if (Utilities().userLoggedIn()) {
            let query:PFQuery = PFQuery(className: "Profile");
            let currentID = PFUser.current()!.objectId;
            query.whereKey("ID", equalTo:currentID!);
            
            query.getFirstObjectInBackground {
                (profile: PFObject?, error: NSError?) -> Void in
                if (profile == nil || error != nil) {
                    print(error);
                } else if let profile = profile {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    profile["last_active"] = dateFormatter.string(from: Date());
                    profile["Available"] = true
                    profile.saveInBackground();
                    print(dateFormatter.string(from: Date()));
                }
            }
        }

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

