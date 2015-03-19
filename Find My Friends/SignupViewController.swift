//
//  SignupViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/16/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, MBProgressHUDDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!

    
    let util = Util()
    var keyboardStatus = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        initialize()
        underlineBackButton()
    }
    
    func initialize() {
        fullname.delegate = self
        username.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
        email.delegate = self
        
        util.setupTextField(fullname)
        util.setupTextField(username)
        util.setupTextField(password)
        util.setupTextField(confirmPassword)
        util.setupTextField(email)
        
        signUpButton.layer.cornerRadius = 8
        
        imageView.image = util.blurImage(UIImage(named: "kien.jpg")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func underlineBackButton(){
        var titleString : NSMutableAttributedString = NSMutableAttributedString(string: backButton.titleLabel!.text!)
        titleString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, backButton.titleLabel!.text!.utf16Count))
        backButton.setAttributedTitle(titleString, forState: .Normal)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (fullname.isFirstResponder()){
            fullname.resignFirstResponder()
            username.becomeFirstResponder()
        } else if(username.isFirstResponder()) {
            username.resignFirstResponder()
            password.becomeFirstResponder()
        } else if (password.isFirstResponder()){
            password.resignFirstResponder()
            confirmPassword.becomeFirstResponder()
        } else if(confirmPassword.isFirstResponder()){
            confirmPassword.resignFirstResponder()
            email.becomeFirstResponder()
        } else if(email.isFirstResponder()){
            animatedSignupView()
            email.resignFirstResponder()
        }
        
        return true
    }
    
    func animatedSignupViewWithHeight(height: CGFloat) {
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, height)
        })
        keyboardStatus = false
    }
    
    func animatedSignupView() {
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        })
        keyboardStatus = true
    }
    
    @IBAction func backToLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
        if checkUsernameFilling() == true {
            if(checkPasswordLength() == true) {
                if checkPasswordMatch() == true {
                    doSignupWith(username.text, senderPass: password.text, senderEmail: email.text, senderFullname: fullname.text)
                } else {
                    var alert = UIAlertView(title: "ERROR", message: "Confirm password do not match", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            } else {
                var alert = UIAlertView(title: "ERROR", message: "Password's length must be at least 8 characters", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
    
    func doSignupWith(senderUsername: NSString, senderPass: NSString, senderEmail: NSString, senderFullname: NSString) {
        
        var user: QBUUser = QBUUser()
        user.fullName = senderFullname
        user.email = senderEmail
        user.login = senderUsername
        user.password = senderPass
        
        QBRequest.signUp(user, successBlock: { (response: QBResponse!, theUser: QBUUser!) -> Void in
            var alert = UIAlertView(title: "CONGRATULATION!", message: "SIGN UP SUCCESSFULLY. BACK TO LOGIN", delegate: self, cancelButtonTitle: "OK")
            alert.tag = 1
            alert.show()
            }) { (response: QBResponse!) -> Void in
                println("\(response.error.description)")
        }
        
    }
    
    func checkUsernameFilling() -> Bool {
        if username.text == "" {
            var alert = UIAlertView(title: "ERROR", message: "You must enter an username", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return false
        }
        return true
    }
    
    func checkPasswordMatch() -> Bool {
        if password.text == confirmPassword.text {
            return true
        }
        return false
    }
    
    func checkPasswordLength() -> Bool {
        if countElements(password.text) < 8 {
            return false
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1 {
            if buttonIndex == 0 {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.isEqual(fullname) || textField.isEqual(username) || textField.isEqual(password) {
            animatedSignupView()
        } else {
            if keyboardStatus {
                animatedSignupViewWithHeight(-100)
            }
        }
        return true
    }
}
