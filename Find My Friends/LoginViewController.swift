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
        imageView.image = util.blurImage(UIImage(named: "kien.jpg")!)
        util.setupTextField(username)
        util.setupTextField(password)
    }
        
    
    @IBAction func doLoginWithFacebook(sender: AnyObject) {
        hideKeyboard()
        var alert = UIAlertView()
        
        if doCheckAllTextField() {
            var hud = MBProgressHUD(view: self.view)
            self.view.addSubview(hud)
            hud.labelText = "LOGGING IN"
            hud.show(true)
            
            var username = self.username.text
            var password = self.password.text
            
            QBRequest.logInWithUserLogin(username, password: password, successBlock: { (response: QBResponse!, user: QBUUser!) -> Void in
                hud.hide(true)
                var currentUser: QBUUser = QBUUser()
                currentUser.login = username
                currentUser.password = password
                //save to singeton
                LocalStorageService.sharedInstance().saveCurrentUser(currentUser)
                
                self.userDefault.setBool(true, forKey: self.util.KEY_AUTHORIZED)
                self.userDefault.setObject(username, forKey: "currentUserName")
                self.userDefault.setObject(password, forKey: "currentPassword")
                self.dismissViewControllerAnimated(true, completion: nil)
                }, errorBlock: { (response: QBResponse!) -> Void in
                    hud.hide(true)
                    alert = UIAlertView(title: "LOGIN FAILT", message: "PLEASE CHECK YOUR ACCOUNT", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
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
}
