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
    
    var chatType: QBChatDialogType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages = NSMutableArray()
        messagesTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("ChatID:\(self.dialog.ID)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatRoomDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessageFromRoom, object: nil)
        
        //Set title
        if self.dialog.type.value == QBChatDialogTypePrivate.value {
            let dictionary: [NSObject: AnyObject] = LocalStorageService.sharedInstance().usersAsDictionary
            let recipient = dictionary[self.dialog.recipientID] as QBUUser
            self.title = recipient.login
        } else {
            self.title = self.dialog.name
        }
        
        // Join room
        if self.dialog.type.value != QBChatDialogTypePrivate.value {
            self.chatRoom = self.dialog.chatRoom
            ChatService.instance().joinRoom(self.chatRoom, completionBlock: { (joinedChatRoom: QBChatRoom!) -> Void in
                // JOINED
            })
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

    func hidesBottomBarWhenPushed() -> Bool {
        return true
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
        
        self.messageTextField.text = nil

    }

    func chatDidReceiveMessageNotification(notification: NSNotification) {
        
        var dictionary: [NSObject: AnyObject] = notification.userInfo!
        var message = dictionary[kMessage] as QBChatMessage
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
        var message = dictionary[kMessage] as QBChatMessage
        let roomJID = dictionary[kRoomJID] as NSString
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
        var cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageCellIdentifier") as ChatMessageTableViewCell!
        
        if cell == nil {
            cell = ChatMessageTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ChatMessageCellIdentifier")
        }
        
        let message = self.messages.objectAtIndex(indexPath.row) as QBChatAbstractMessage
        cell.configureCellWithMessage(message)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let chatMessage = self.messages.objectAtIndex(indexPath.row) as QBChatAbstractMessage
        let cellHeight = ChatMessageTableViewCell.heightForCellWithMessage(chatMessage)
        
        return cellHeight
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -250)
            self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -250)
            self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x, self.messagesTableView.frame.origin.y, self.messagesTableView.frame.size.width, self.messagesTableView.frame.size.height - 252)
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageTextField.transform = CGAffineTransformIdentity
            self.sendMessageButton.transform = CGAffineTransformIdentity
            self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x, self.messagesTableView.frame.origin.y, self.messagesTableView.frame.size.width, self.messagesTableView.frame.size.height + 252)
        })
    }

    func completedWithResult(result: QBResult!) {
        if result.success && result.isKindOfClass(QBChatHistoryMessageResult) {
            let res = result as QBChatHistoryMessageResult
            var theMessages = res.messages
            if theMessages != nil {
                if theMessages.count > 0 {
                    self.messages.addObjectsFromArray(theMessages.mutableCopy() as NSArray)
                    self.messagesTableView.reloadData()
                    self.messagesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
            }
            
        }
    }
}
