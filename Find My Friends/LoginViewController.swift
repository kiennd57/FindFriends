//
//  LoginViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/14/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, MBProgressHUDDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginFacebook: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let util = Util()
    var userDefault = NSUserDefaults.standardUserDefaults()
    var keyboardStatus = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        username.delegate = self
        password.delegate = self
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialize() {
        loginButton.layer.cornerRadius = 8
        signupButton.layer.cornerRadius = 8
        imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
//        util.setImageBlur(imageView)
        imageView.image = util.blurImage(UIImage(named: "blue.jpg")!)
        util.setupTextField(username)
        util.setupTextField(password)
        if(LocalStorageService.sharedInstance().currentUser != nil) {
            username.text = LocalStorageService.sharedInstance().currentUser.login
        }
        else {
            username.text = ""
        }
        password.text = ""
    }
        
    
    @IBAction func doLoginWithFacebook(sender: AnyObject) {
        hideKeyboard()
        var alert = UIAlertView()
        
        if doCheckAllTextField() {
            var hud = MBProgressHUD(view: self.view)
            self.view.addSubview(hud)
            hud.labelText = "LOGGING IN"
            hud.show(true)
            
            var extendedRequest = QBSessionParameters()
            extendedRequest.userLogin = self.username.text
            extendedRequest.userPassword = self.password.text
            
            QBRequest.createSessionWithExtendedParameters(extendedRequest, successBlock: { (response: QBResponse!, session: QBASession!) -> Void in
                //set current user
                QBRequest.userWithID(session.userID, successBlock: { (response: QBResponse!, user: QBUUser!) -> Void in
                    self.userDefault.setObject(user.ID, forKey: kUserId)
                    self.userDefault.setObject(user.login, forKey: kLogin)
                    self.userDefault.setObject(self.password.text, forKey: kPassword)
                    self.userDefault.setObject(user.fullName, forKey: kFullName)
                    self.userDefault.setObject(user.email, forKey: kEmail)
                    self.userDefault.setObject(user.phone, forKey: kPhone)
                    self.userDefault.setBool(true, forKey: kAuthorized)
                    user.password = self.password.text
                    
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
                
                // register for remote notification
                self.registerForRemoteNotifications()
                
                
                // get check in list
                var filter = QBLGeoDataFilter()
                filter.lastOnly = true
                filter.sortBy = GeoDataSortByKindLongitude
                
                QBRequest.geoDataWithFilter(filter, page: QBGeneralResponsePage(currentPage: 1, perPage: 6), successBlock: { (response: QBResponse!, objects: [AnyObject]!, responsePage: QBGeneralResponsePage!) -> Void in
                    hud.hide(true)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2*NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    LocalStorageService.sharedInstance().saveCheckins(objects)
                    println("CHECKIN LIST: \(LocalStorageService.sharedInstance().checkins)")
                    hud.hide(true)
                    }, errorBlock: { (response: QBResponse!) -> Void in
                        
                })

                }, errorBlock: { (error: QBResponse!) -> Void in
                    let alert = UIAlertView(title: "Alert", message: "Username/Password is wrong!", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    hud.hide(true)
            })
        } else {
            alert = UIAlertView(title: "ERROR", message: "USERNAME/PASSWORD CAN NOT BE BLANK", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func hideKeyboard() {
        username.resignFirstResponder()
        password.resignFirstResponder()
        resetView()
    }
    
    func doCheckAllTextField() -> Bool {
        if username.text.isEmpty || password.text.isEmpty {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(username.isFirstResponder()){
            username.resignFirstResponder()
            password.becomeFirstResponder()
        } else if(password.isFirstResponder()){
            password.resignFirstResponder()
            resetView()
            doLoginWithFacebook(self)
        }
        
        return true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func resetView() {
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        })
        keyboardStatus = true
    }
    
    func animateSignIn() {
        keyboardStatus = false
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, -100)
        })
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if keyboardStatus {
            animateSignIn()
        } else {
//            resetView()
        }
        return true
    }
    
    func registerForRemoteNotifications () {
        if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound)
        }
    }
}
