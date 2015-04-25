//
//  AppDelegate.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/14/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var spalshView: RootViewController!
    var rootController: SWRevealViewController!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        QBApplication.sharedApplication().applicationId = 20790;
        QBConnection.registerServiceKey("ugQa6f2b8uFHuWp");
        QBConnection.registerServiceSecret("yT2QaB9h5HpsSYm");
        QBSettings.setAccountKey("XTa7eHtDykX4D3kWe5ga");
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // instantiate your desired ViewController
        rootController = storyboard.instantiateViewControllerWithIdentifier("rootView") as! SWRevealViewController
        self.spalshView = RootViewController()
        self.window?.rootViewController = self.spalshView

        return true
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

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        var dictionary = NSDictionary(dictionary: userInfo)
        ChatService.instance().receiveRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        QBRequest.registerSubscriptionForDeviceToken(deviceToken, successBlock: { (response: QBResponse!, subscriptions: [AnyObject]!) -> Void in
            println("Register notification with device token success")
            }) { (response: QBError!) -> Void in
            let alert = UIAlertView(title: "Error", message: "\(response.reasons.description)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
        }
    }

}

