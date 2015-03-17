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
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginFacebook: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let util = Util()
    var userDefault = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        username.delegate = self
        password.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doLoginWithFacebook(sender: AnyObject) {
        var username = self.username.text
        var password = self.password.text
        
        QBRequest.logInWithUserLogin(username, password: password, successBlock: { (response: QBResponse!, user: QBUUser!) -> Void in
            println("OK")
            var currentUser: QBUUser = QBUUser()
            currentUser.login = username
            currentUser.password = username
            //save to singeton
            LocalStorageService.sharedInstance().saveCurrentUser(currentUser)
            
            self.userDefault.setBool(true, forKey: self.util.KEY_AUTHORIZED)
            self.dismissViewControllerAnimated(true, completion: nil)
            }, errorBlock: { (response: QBResponse!) -> Void in
                println("FAILT")
        })
        
        //        QBRequest.createSessionWithSuccessBlock({ (response: QBResponse!, session: QBASession!) -> Void in
        //
        //
        //
        //            }, errorBlock: { (response: QBResponse!) -> Void in
        //            println("SESSION FAIL")
        //        })
    }
    
    
    
    //    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //        if string == "\n" {
    //            textField.resignFirstResponder()
    //            return false
    //        }
    //        return true
    //    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    var kbHeight: CGFloat!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight/3 : kbHeight/3)
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
}
