//
//  ProfileTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/21/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController, UITextFieldDelegate, MBProgressHUDDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var email: UILabel!
    
    
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPass: UITextField!
    
    
    var imagePickerView: UIImagePickerController!
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getDemo()
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
        imageProfile.userInteractionEnabled = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 130/255, blue: 184/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(objectsAndKeys: UIColor.whiteColor(), NSForegroundColorAttributeName,
            UIColor.whiteColor(), NSBackgroundColorAttributeName) as [NSObject : AnyObject]

        let tapImageGesture = UITapGestureRecognizer(target: self, action: "changeProfileAction:")
        imageProfile.addGestureRecognizer(tapImageGesture)
        
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
    func changeProfileAction(sender: AnyObject) {
        imagePickerView = UIImagePickerController()
        imagePickerView.delegate = self
        imagePickerView.allowsEditing = true
        
        let popup = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take a photo", "Choose an image")
        
        popup.showInView(self.view)

    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.buttonTitleAtIndex(buttonIndex) == "Take a photo" {
            imagePickerView.sourceType = UIImagePickerControllerSourceType.Camera;
            self.presentViewController(imagePickerView, animated: true, completion: nil)
        } else if actionSheet.buttonTitleAtIndex(buttonIndex) == "Choose an image" {
            imagePickerView.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            self.presentViewController(imagePickerView, animated: true, completion: nil)
        } else if actionSheet.buttonTitleAtIndex(buttonIndex) == "Cancel" {
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.imageProfile.image = chosenImage;
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
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
                
                var object = QBCOCustomObject()
                object.className = "UserProfile"
                object.fields["userName"] = currentUser.login
//                object.fields["fullName"] = currentUser.fullName
                object.fields["password"] = currentUser.password
//                object.fields["email"] = currentUser.email
//                object.fields["phoneNumber"] = currentUser.phone
//                object.fields["avatar"] = UIImageJPEGRepresentation(self.imageProfile.image, 0.8)
                
                QBRequest.createObject(object, successBlock: { (response: QBResponse!, customObject: QBCOCustomObject!) -> Void in
//                        let alert = UIAlertView(title: "SUCCESS", message: nil, delegate: self, cancelButtonTitle: "Cancel")
//                        alert.show()
                    
                    LocalStorageService.sharedInstance().uploadFile(self.getDataImageUpload(self.imageProfile.image!), withObjectID: customObject.ID)
                    hud.hide(true)
                    }, errorBlock: { (error: QBResponse!) -> Void in
                        let alert = UIAlertView(title: "FAIL", message: nil, delegate: self, cancelButtonTitle: "Cancel")
                        alert.show()
                        hud.hide(true)
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
    
    func scaleDownImageWith(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var scaledImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func getDataImageUpload(image: UIImage) -> NSData{
        var resulution = image.size.width * image.size.height
        var img = UIImage()
        
        if resulution > 60 * 60 {
            img = scaleDownImageWith(image, newSize: CGSizeMake(60, 60))
        }
        
        //compress image
        var compression = 0.8 as CGFloat
        var maxCompression = 0.1 as CGFloat
        
        var imageData = UIImageJPEGRepresentation(img, compression)
        //        while imageData.length > 500 && compression > maxCompression {
        //            compression -= 0.1
        //            imageData = UIImageJPEGRepresentation(img, compression)
        //            println("Compress: \(imageData.length)")
        //        }
        
        return imageData
    }
    
    func getDemo() {
        
//        QBRequest.downloadFileFromClassName("UserProfile", objectID: "553f17e1535c123ea50d21c3", fileFieldName: "avatar", successBlock: { (response: QBResponse!, data: NSData!) -> Void in
//            self.imageProfile.image = UIImage(data: data)
//            }, statusBlock: { (request: QBRequest!, requestStatus: QBRequestStatus!) -> Void in
//            
//            }) { (response: QBResponse!) -> Void in
//            
//        }
        
//        LocalStorageService.sharedInstance().uploadFile(UIImagePNGRepresentation(self.imageProfile.image))
    }
}
