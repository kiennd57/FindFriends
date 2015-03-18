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
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        //        let keyboardNextButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        //        keyboardNextButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("endEditingNow") )
        let item1 = UIBarButtonItem(title: "Next>                ", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector())
        var toolbarButtons = [item1, item]
        
        
        //        var toolbarButtons1 = [item1]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        //        keyboardNextButtonView.setItems(toolbarButtons1, animated: false)
        
        textField.inputAccessoryView = keyboardDoneButtonView
        //        textField.inputAccessoryView = keyboardNextButtonView
        
        return true
    }
    
    func resign() {
        self.resignFirstResponder()
    }
    
    
    
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        //nothing fancy here, just trigger the resign() method to close the keyboard.
        resign()
    }
    
    override func touchesBegan(touches: (NSSet!), withEvent event: (UIEvent!)) {
        self.view.endEditing(true)
    }
    
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
