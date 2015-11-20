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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("ni7bpwOhWr114Rom27cx4QSv27Ud3tyMl0tZchxw",
            clientKey: "NqfIkHWioqiH93TsSijAvcoMNzWDgyx8Z9hoLJL2")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()

        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications();
        }
        if (launchOptions != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let navigation = appDelegate.window!.rootViewController as! UINavigationController
            let rootVC = storyboard.instantiateViewControllerWithIdentifier("MessageListVC") as! ConversationListTableViewController
            if (PFUser.currentUser() != nil) {
                if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
                    let name: AnyObject? = notificationPayload["name"];
//                    var date: AnyObject? = notificationPayload["date"];
                    let id: AnyObject? = notificationPayload["id"];
                    defaults.setObject(notificationPayload, forKey: Constants.TempKeys.notificationPayloadKey);
                    defaults.setObject(name, forKey: Constants.SelectedUserKeys.selectedNameKey)
                    defaults.setObject(id, forKey: Constants.SelectedUserKeys.selectedIdKey)
                    NSNotificationCenter.defaultCenter().postNotificationName("phoneVibrate", object: nil);
                    NSNotificationCenter.defaultCenter().postNotificationName("loadConversations", object: nil);
                    NSNotificationCenter.defaultCenter().postNotificationName("loadData", object: nil);
                    NSNotificationCenter.defaultCenter().postNotificationName("goToMessageVC", object: nil);
                    navigation.pushViewController(rootVC, animated: true);
                }
            }
        }
        
        return true
    }
    
    // Parse Push Notification Functions
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings settings: UIUserNotificationSettings) {
        if (settings.types != UIUserNotificationType.None) {
            print("Did register user");
            application.registerForRemoteNotifications();
        }
    }
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
   
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
//        let navigation = appDelegate.window!.rootViewController as! UINavigationController
//        let rootVC = storyboard.instantiateViewControllerWithIdentifier("MessageListVC") as! MessagerViewController
        if (PFUser.currentUser() != nil) {
            if let notificationPayload = userInfo as? NSDictionary {
                let name: AnyObject? = notificationPayload["name"];
//                var date: AnyObject? = notificationPayload["date"];
                let id: AnyObject? = notificationPayload["id"];
//                var text: AnyObject? = notificationPayload["alert"];
                defaults.setObject(notificationPayload, forKey: Constants.TempKeys.notificationPayloadKey);
                defaults.setObject(name, forKey: Constants.SelectedUserKeys.selectedNameKey)
                defaults.setObject(id, forKey: Constants.SelectedUserKeys.selectedIdKey)
                NSNotificationCenter.defaultCenter().postNotificationName("phoneVibrate", object: nil);
                NSNotificationCenter.defaultCenter().postNotificationName("loadConversations", object: nil);
                NSNotificationCenter.defaultCenter().postNotificationName("loadData", object: nil);
//                if (navigation.topViewController.restorationIdentifier != "MessageVC") {
//                    navigation.pushViewController(rootVC, animated: true);
//                }
            }
        }
        PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    }
   

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

