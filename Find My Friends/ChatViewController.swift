//
//  ChatViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/17/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, QBActionStatusDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    var messages:NSMutableArray!
    var chatRoom: QBChatRoom!
    var dialog: QBChatDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages = NSMutableArray()
        messagesTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        initialize()
    }
    
    func initialize(){
        sendMessageButton.layer.cornerRadius = 8
        sendMessageButton.layer.borderColor = UIColor.clearColor().CGColor
        
        self.view.backgroundColor = UIColor(red: 207/255, green: 209/255, blue: 201/255, alpha: 1)
        self.messagesTableView.backgroundColor = UIColor(red: 232/255, green: 235/255, blue: 225/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatRoomDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessageFromRoom, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushDidReceive:", name: kPushDidReceive, object: nil)

        
        self.view.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "keyboardWillHide:")
        self.view.addGestureRecognizer(tapGesture)
        
        //Set title
//        if self.dialog.type.value == QBChatDialogTypePrivate.value {
//            let dictionary: [NSObject: AnyObject] = LocalStorageService.sharedInstance().usersAsDictionary
//            let recipient = dictionary[self.dialog.recipientID] as? QBUUser
//            if recipient != nil {
//                self.title = recipient!.login
//            }
//        } else {
//            self.title = self.dialog.name
//        }
        
        if self.dialog != nil {
            if self.dialog.type.value != QBChatDialogTypePrivate.value {
                self.chatRoom = self.dialog.chatRoom
                ChatService.instance().joinRoom(self.chatRoom, completionBlock: { (joinedRoom: QBChatRoom!) -> Void in
                    
                })
            }
        } 
        
        // get message history
        if self.dialog.ID != nil {
            QBChat.messagesWithDialogID(self.dialog.ID, extendedRequest: nil, delegate: self)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if self.chatRoom != nil {
            self.chatRoom.leaveRoom()
            self.chatRoom = nil
        }
    }

//    func hidesBottomBarWhenPushed() -> Bool {
//        return true
//    }
    
    func pushDidReceive(notification: NSNotification) {
        let dictionary: [NSObject: AnyObject] = notification.userInfo!
        let message = dictionary["message"] as! String
        
        var pushMessage = SSMPushMessage(message: message, richContentFilesIDs: nil)
        var theMessage = QBChatMessage()
        theMessage.text = message
        
        self.messages.addObject(theMessage)
        self.messagesTableView.reloadData()
    }

    @IBAction func sendMessage(sender: AnyObject) {
        
        if self.messageTextField.text.isEmpty {
            return
        }
        
        //Create a message
        var message = QBChatMessage()
        message.text = messageTextField.text
        var params = NSMutableDictionary()
        params["save_to_history"] = true
        message.customParameters = params
        
        // if chat private : 1 - 1
        if self.dialog.type.value == QBChatDialogTypePrivate.value {
            message.recipientID = UInt(self.dialog.recipientID)
            message.senderID = LocalStorageService.sharedInstance().currentUser.ID
            
            ChatService.instance().sendMessage(message)
            self.messages.addObject(message)
        } else {
            ChatService.instance().sendMessage(message, toRoom: self.chatRoom)
        }
        
        self.messagesTableView.reloadData()
        if self.messages.count > 0 {
            self.messagesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
        
        
        let recipentUser = "\(self.dialog.recipientID)"
        QBRequest.sendPushWithText(messageTextField.text, toUsers: recipentUser, successBlock: { (response: QBResponse!, events: [AnyObject]!) -> Void in
            
            }) { (error: QBError!) -> Void in
            
        }
        
        self.messageTextField.text = nil
    }

    func chatDidReceiveMessageNotification(notification: NSNotification) {
        
        var dictionary: [NSObject: AnyObject] = notification.userInfo!
        var message = dictionary[kMessage] as! QBChatMessage
        if Int(message.senderID) != self.dialog.recipientID {
            return
        }
        
        self.messages.addObject(message)
        self.messagesTableView.reloadData()
        if self.messages.count > 0 {
            self.messagesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    func chatRoomDidReceiveMessageNotification(notification: NSNotification) {
        var dictionary: [NSObject: AnyObject] = notification.userInfo!
        var message = dictionary[kMessage] as! QBChatMessage
        let roomJID = dictionary[kRoomJID] as! NSString
        if self.chatRoom.JID != roomJID {
            return
        }
        
        self.messages.addObject(message)
        self.messagesTableView.reloadData()
        if self.messages.count > 0 {
            self.messagesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageCellIdentifier") as! ChatMessageTableViewCell!
        
        if cell == nil {
            cell = ChatMessageTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ChatMessageCellIdentifier")
        }
        
        let message = self.messages.objectAtIndex(indexPath.row) as! QBChatAbstractMessage
        cell.configureCellWithMessage(message)
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let chatMessage = self.messages.objectAtIndex(indexPath.row) as! QBChatAbstractMessage
        let cellHeight = ChatMessageTableViewCell.heightForCellWithMessage(chatMessage)
        
        return cellHeight
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -210)
            self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -210)
            self.messagesTableView.transform = CGAffineTransformMakeTranslation(0, -210)
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageTextField.transform = CGAffineTransformIdentity
            self.sendMessageButton.transform = CGAffineTransformIdentity
            self.messagesTableView.transform = CGAffineTransformIdentity
        })
        messageTextField.resignFirstResponder()
    }

    func completedWithResult(result: QBResult!) {
        if result.success && result.isKindOfClass(QBChatHistoryMessageResult) {
            let res = result as! QBChatHistoryMessageResult
            var theMessages = res.messages
            if theMessages != nil {
                if theMessages.count > 0 {
                    self.messages.addObjectsFromArray(theMessages as [AnyObject])
                    self.messagesTableView.reloadData()
                    self.messagesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
            }
        }
    }
}
