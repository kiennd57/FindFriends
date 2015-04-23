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
    
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: util.blurImage(UIImage(named: "kien.jpg")!))
        
        var hud = MBProgressHUD(view:self.view)
        hud.labelText = "LOADING"
        hud.delegate = self
        hud.show(true)
        self.view.addSubview(hud)
        
        
                    QBRequest.createSessionWithSuccessBlock({ (response: QBResponse!, session: QBASession!) -> Void in
                        println("CREATE SESSION SUCCESSFULLY!")
                        
                        let userName = self.userDefault.objectForKey("currentUserName") as NSString!
                        let password = self.userDefault.objectForKey("currentPassword") as NSString!
                        
                        if userName != nil && password != nil {
                            if self.userDefault.boolForKey(self.util.KEY_AUTHORIZED) {
                                QBRequest.logInWithUserLogin(userName, password: password, successBlock: { (response: QBResponse!, user: QBUUser!) -> Void in
                                    var currentUser: QBUUser = QBUUser()
                                    
                                    currentUser.ID = session.userID
                                    currentUser.login = userName
                                    currentUser.password = password
                                    //save to singeton
                                    LocalStorageService.sharedInstance().saveCurrentUser(currentUser)
                                    
                                    self.userDefault.setBool(true, forKey: self.util.KEY_AUTHORIZED)
                                    self.userDefault.setObject(userName, forKey: "currentUserName")
                                    self.userDefault.setObject(password, forKey: "currentPassword")
                                    
                                    
                                    ChatService.instance().loginWithUser(currentUser, completionBlock: { () -> Void in
                                        println("LOGIN SUCCESS TO CHAT")
                                    })
                                    
                                    

                                    
                                    
                                    
                                    
                                    
                                    
                                    }, errorBlock: { (response: QBResponse!) -> Void in
                                        let alert = UIAlertView(title: "LOGIN FAIL!", message: "Can not login", delegate: self, cancelButtonTitle: "OK")
                                        alert.show()
                                })
                            }
                        }
                        
                        var filter = QBLGeoDataFilter()
                        filter.lastOnly = true
                        filter.sortBy = GeoDataSortByKindLatitude
                        QBRequest.geoDataWithFilter(filter, page: QBGeneralResponsePage(currentPage: 1, perPage: 6), successBlock: { (response: QBResponse!, objects: [AnyObject]!, responsePage: QBGeneralResponsePage!) -> Void in
        
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2*NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                                hud.hide(true)
                                let appdelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                self.presentViewController(appdelegate.rootController, animated: true, completion: nil)
                            })
        
                            LocalStorageService.sharedInstance().saveCheckins(objects)
                            println("CHECKIN LIST: \(LocalStorageService.sharedInstance().checkins)")
        
                            }, errorBlock: { (response: QBResponse!) -> Void in
        
                        })
                        }, errorBlock: { (response: QBResponse!) -> Void in
                            var alertView = UIAlertView(title: "SESSION CREATED FAILT", message: "DINH MENH", delegate: self, cancelButtonTitle: "OK")
                            alertView.show()
                    })
    }

    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(patternImage: util.blurImage(UIImage(named: "kien.jpg")!))
        
        var hud = MBProgressHUD(view:self.view)
        hud.labelText = "LOADING"
        hud.delegate = self
        hud.show(true)
        self.view.addSubview(hud)
        
        let userName = self.userDefault.objectForKey("currentUserName") as NSString!
        let password = self.userDefault.objectForKey("currentPassword") as NSString!
        
        var extendedAuthRequest = QBSessionParameters()
        extendedAuthRequest.userLogin = "phongnn"
        extendedAuthRequest.userPassword = "Matkhaulagi"
        
        QBRequest.createSessionWithExtendedParameters(extendedAuthRequest, successBlock: { (response: QBResponse!, session: QBASession!) -> Void in
            var currentUser = QBUUser()
            currentUser.ID = session.userID
            currentUser.login = "phongnn"
            currentUser.password = "Matkhaulagi"
            
            LocalStorageService.sharedInstance().currentUser = currentUser
            
            ChatService.instance().loginWithUser(currentUser, completionBlock: { () -> Void in
            })
            
            var filter = QBLGeoDataFilter()
            filter.lastOnly = true
            filter.sortBy = GeoDataSortByKindLatitude
            QBRequest.geoDataWithFilter(filter, page: QBGeneralResponsePage(currentPage: 1, perPage: 6), successBlock: { (response: QBResponse!, objects: [AnyObject]!, responsePage: QBGeneralResponsePage!) -> Void in
                hud.hide(true)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2*NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                    let appdelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    self.presentViewController(appdelegate.rootController, animated: true, completion: nil)
                })
                
                LocalStorageService.sharedInstance().saveCheckins(objects)
                println("CHECKIN LIST: \(LocalStorageService.sharedInstance().checkins)")
                hud.hide(true)
                }, errorBlock: { (response: QBResponse!) -> Void in
                    
            })
            
            

            
            
            }) { (response: QBResponse!) -> Void in
            
        }


    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
