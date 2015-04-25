//
//  RootViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/18/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, MBProgressHUDDelegate, QBActionStatusDelegate {

    let util = Util()
    let userDefault = NSUserDefaults.standardUserDefaults()
    var hud: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: util.blurImage(UIImage(named: "kien.jpg")!))
        
        hud = MBProgressHUD(view:self.view)
        hud.labelText = "LOADING"
        hud.delegate = self
        hud.show(true)
        self.view.addSubview(hud)
        
        let userName = self.userDefault.objectForKey("currentUserName") as! String!
        let password = self.userDefault.objectForKey("currentPassword") as! String!
        
        
        if userName != nil && password != nil {
            createSession(userName, password: password)
        } else {
            createSession("embe", password: "12345678")
        }
    }
    
    func createSession(userName: String, password: String) {
        var extendedAuthRequest = QBSessionParameters()
        extendedAuthRequest.userLogin = userName
        extendedAuthRequest.userPassword = password
        
        QBRequest.createSessionWithExtendedParameters(extendedAuthRequest, successBlock: { (response: QBResponse!, session: QBASession!) -> Void in
            //set current user
            var currentUser = QBUUser()
            currentUser.ID = session.userID
            currentUser.login = userName
            currentUser.password = password
            self.userDefault.setBool(true, forKey: self.util.KEY_AUTHORIZED)
            LocalStorageService.sharedInstance().currentUser = currentUser
            
            self.registerForRemoteNotifications()
            
            ChatService.instance().loginWithUser(currentUser, completionBlock: { () -> Void in
            })
            
            var filter = QBLGeoDataFilter()
            filter.lastOnly = true
            filter.sortBy = GeoDataSortByKindLatitude
            QBRequest.geoDataWithFilter(filter, page: QBGeneralResponsePage(currentPage: 1, perPage: 6), successBlock: { (response: QBResponse!, objects: [AnyObject]!, responsePage: QBGeneralResponsePage!) -> Void in
                self.hud.hide(true)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2*NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    self.presentViewController(appdelegate.rootController, animated: true, completion: nil)
                })
                
                LocalStorageService.sharedInstance().saveCheckins(objects)
                println("CHECKIN LIST: \(LocalStorageService.sharedInstance().checkins)")
                self.hud.hide(true)
                }, errorBlock: { (response: QBResponse!) -> Void in
                    
            })
            
            }) { (response: QBResponse!) -> Void in
                
        }
    }
    
    func registerForRemoteNotifications () {
        if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound)
        }
    }
    
    
//    - (void)registerForRemoteNotifications{
//    
//    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//    
//    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
//    else{
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
//    }
//    #else
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
//    #endif
//    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
