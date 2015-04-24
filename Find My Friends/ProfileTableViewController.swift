//
//  ProfileTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/21/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController, UITextFieldDelegate, MBProgressHUDDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var email: UILabel!
    
    
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPass: UITextField!
    
    
    
    
    var currentUser: QBUUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Menu Bar Button Action
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        initialize()
        getAllInformations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initialize() {
        imageProfile.layer.masksToBounds = true
        imageProfile.layer.cornerRadius = 40
        imageProfile.layer.borderWidth = 1
        imageProfile.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        tfFullName.delegate = self
        tfPhoneNumber.delegate = self
        tfPassword.delegate = self
        tfConfirmPass.delegate = self
    }
    
    func getAllInformations() {
        currentUser = LocalStorageService.sharedInstance().currentUser
        if currentUser != nil {
            userName.text = currentUser.login
            fullName.text = currentUser.fullName
            email.text = currentUser.email
            
            tfFullName.text = currentUser.fullName
            tfPhoneNumber.text = currentUser.phone
            tfPassword.text = currentUser.password
            tfConfirmPass.text = currentUser.password
        }
    }
    /////////////////////////////////////////////////////////////////////////
    
    
    @IBAction func saveChange(sender: AnyObject) {
        println(__FUNCTION__)
        if canSubmit() {
            if currentUser != nil {
                let hud = MBProgressHUD(view: self.view)
                hud.labelText = "Updating"
                hud.delegate = self
                self.view.addSubview(hud)
                self.view.bringSubviewToFront(hud)
                hud.show(true)
                
                currentUser.fullName = tfFullName.text
                currentUser.phone = tfPhoneNumber.text
                currentUser.password = tfPassword.text
                QBRequest.updateUser(currentUser, successBlock: { (response: QBResponse!, user: QBUUser!) -> Void in
                    let alert = UIAlertView(title: "Success", message: "Update informations success", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    self.getAllInformations()
                    hud.hide(true)
                    }, errorBlock: { (response: QBResponse!) -> Void in
                    let alert = UIAlertView(title: "ERROR!", message: "Fail to update informations", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    hud.hide(true)
                        println("ERROR: \(response.error)")
                })
            }
        } else {
            let alert = UIAlertView(title: "ERROR", message: "All field can not be empty. Password must atleast 8 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    //////////////////////////////////////////////////////////
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    /////////////////////////////////////////////
    func canSubmit() -> Bool {
        if tfFullName.text.isEmpty {return false}
        if tfPhoneNumber.text.isEmpty {return false}
        if tfPassword.text != tfConfirmPass.text {return false}
        if count(tfPassword.text) < 8 {return false}
        return true
    }
}
