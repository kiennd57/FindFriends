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
        
        self.view.backgroundColor = UIColor(red: 45/255, green: 130/255, blue: 184/255, alpha: 1)
        
        hud = MBProgressHUD(view:self.view)
        hud.labelText = "LOADING"
        hud.delegate = self
        hud.show(true)
        self.view.addSubview(hud)
        
        let userName = self.userDefault.objectForKey(kLogin) as! String!
        let password = self.userDefault.objectForKey(kPassword) as! String!
        
        if userName != nil && password != nil {
            createSession(userName, password: password)
        } else {
//            createSession("embe", password: "12345678")
            self.userDefault.setBool(false, forKey: kAuthorized)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2*NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                self.presentViewController(appdelegate.rootController, animated: true, completion: nil)
            })
        }
    }
    
    func createSession(userName: String, password: String) {
        
        var extendedAuthRequest = QBSessionParameters()
        extendedAuthRequest.userLogin = userName
        extendedAuthRequest.userPassword = password
        
        QBRequest.createSessionWithExtendedParameters(extendedAuthRequest, successBlock: { (response: QBResponse!, session: QBASession!) -> Void in
            QBRequest.userWithID(session.userID, successBlock: { (response: QBResponse!, user: QBUUser!) -> Void in
                self.userDefault.setObject(user.ID, forKey: kUserId)
                self.userDefault.setObject(user.login, forKey: kLogin)
                self.userDefault.setObject(password, forKey: kPassword)
                self.userDefault.setObject(user.fullName, forKey: kFullName)
                self.userDefault.setObject(user.email, forKey: kEmail)
                self.userDefault.setObject(user.phone, forKey: kPhone)
                self.userDefault.setBool(true, forKey: kAuthorized)
                user.password = password
                
                LocalStorageService.sharedInstance().currentUser = user
                
                
                //create userProfile for first login
                QBRequest.objectsWithClassName("UserProfile", successBlock: { (response: QBResponse!, profiles: [AnyObject]!) -> Void in
                    if profiles != nil {
                        
                        LocalStorageService.sharedInstance().userProfiles = profiles
                        var check = true
                        for var i = 0; i < profiles.count; i++ {
                            let profile = profiles[i] as! QBCOCustomObject
                            if profile.userID == session.userID {
                                check = false
                                break;
                            }
                        }
                        
                        if check {
                            var profileObject = QBCOCustomObject()
                            profileObject.className = "UserProfile"
                            QBRequest.createObject(profileObject, successBlock: { (response: QBResponse!, returnObj: QBCOCustomObject!) -> Void in
                                
                                }, errorBlock: { (response: QBResponse!) -> Void in
                                    
                            })
                        }
                        
                    } else {
                        var profileObject = QBCOCustomObject()
                        profileObject.className = "UserProfile"
                        QBRequest.createObject(profileObject, successBlock: { (response: QBResponse!, returnObj: QBCOCustomObject!) -> Void in
                            
                            }, errorBlock: { (response: QBResponse!) -> Void in
                                
                        })
                    }
                    }, errorBlock: { (response: QBResponse!) -> Void in
                        
                })
                
                //login to chat service
                ChatService.instance().loginWithUser(user, completionBlock: { () -> Void in
                })
                }, errorBlock: { (errorResponse: QBResponse!) -> Void in
                    
            })
            
            self.registerForRemoteNotifications()
            
            var filter = QBLGeoDataFilter()
            filter.lastOnly = true
            filter.sortBy = GeoDataSortByKindLatitude
            QBRequest.geoDataWithFilter(filter, page: QBGeneralResponsePage(currentPage: 1, perPage: 6), successBlock: { (response: QBResponse!, objects: [AnyObject]!, responsePage: QBGeneralResponsePage!) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2*NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    self.presentViewController(appdelegate.rootController, animated: true, completion: nil)
                })
                
                LocalStorageService.sharedInstance().saveCheckins(objects)
                println("CHECKIN LIST: \(LocalStorageService.sharedInstance().checkins)")
                }, errorBlock: { (response: QBResponse!) -> Void in
                    
            })
            
            }, errorBlock: { (response: QBResponse!) -> Void in
                let alert = UIAlertView(title: "Alert", message: "Your internet connection is poor", delegate: self, cancelButtonTitle: "OK")
                alert.show()
        })
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
