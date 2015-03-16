//
//  SignupViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/16/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, MBProgressHUDDelegate {
    
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var email: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fullname.delegate = self
        username.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
        email.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signUpAction(sender: AnyObject) {
        doSignupWith(username.text, senderPass: password.text, senderEmail: email.text, senderFullname: fullname.text)
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
        
//        QBRequest.createSessionWithSuccessBlock({ (response: QBResponse!, session: QBASession!) -> Void in
//            
//            }, errorBlock: { (response: QBResponse!) -> Void in
//            println("FAIL TO CREATE SESSION")
//        })

    }
    
//    func checkPasswordMatch() -> Bool {
//        
//    }
    
    
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
}
