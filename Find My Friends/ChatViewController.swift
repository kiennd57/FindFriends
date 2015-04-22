//
//  ChatViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/17/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, QBActionStatusDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var btnSendMsg: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    var messages: NSMutableArray!
    var chatRoom: QBChatRoom! = QBChatRoom()
    var dialog: QBChatDialog!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages = NSMutableArray()
        chatTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        chatTableView.delegate = self
        chatTableView.dataSource = self
        messageTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // KEYBOARD NOTIFICATION
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatRoomDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessageFromRoom, object: nil)
        
        
/*
//        if dialog.type == QBChatDialogTypePrivate {
//            var recipent: QBUUser = LocalStorageService.sharedInstance().usersAsDictionary[]
//            self.title = recipent.login
//        } else {
            self.title = dialog.name
//        }
        
        //Join Room
//        if dialog.type != QBChatDialogTypePrivate {
            chatRoom = dialog.chatRoom
            ChatService.instance().joinRoom(chatRoom, completionBlock: { (joinedChatRoom: QBChatRoom!) -> Void in
                // JOINED
            })
//        }
        
        // GET MESSAGES HISTORY
        QBChat.messagesWithDialogID(dialog.ID, extendedRequest: nil, delegate: self)
*/
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        chatRoom.leaveRoom()
        chatRoom = nil
    }
    
    func hidesBottomBarWhenPushed() -> Bool {
        return true
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
//        if messageTextField.text {
//            return
//        }
        
        var message: QBChatMessage = QBChatMessage()
        message.text = "Hi"
        var params = NSMutableDictionary()
        params["save_to_history"] = true
        message.customParameters = params
        
        
        //USER FOR 1-1 CHAT
//        if self.dialog.type == QBChatDialogTypePrivate {
            message.recipientID = UInt(self.dialog.recipientID)
            message.senderID = LocalStorageService.sharedInstance().currentUser.ID
            ChatService.instance().sendMessage(message)
            self.messages.addObject(message)
//        } else {
            //USE FOR GROUP CHAT
//            ChatService.instance().sendMessage(message, toRoom: self.chatRoom)
//        }
        
        // RELOAD MESSAGE TABLE
        self.chatTableView.reloadData()
        if self.messages.count > 0 {
            self.chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
        //CLEAN TEXTFIELD
        messageTextField.text = nil
    }
    
    func chatDidReceiveMessageNotification(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        
        var message: QBChatMessage = tmp[kMessage] as QBChatMessage
        if message.senderID != UInt(self.dialog.recipientID) {
            return
        }
        
        //SAVE THE MESSAGE
        self.messages.addObject(message)
        
        //RELOAD TABLE VIEW
        self.chatTableView.reloadData()
        if self.messages.count > 0 {
            self.chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    func chatRoomDidReceiveMessageNotification(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        var message = tmp[kMessage] as QBChatMessage
        var roomJID = tmp[kRoomJID] as NSString
        if self.chatRoom.JID != roomJID {
            return
        }
        //SAVE MESSAGE
        self.messages.addObject(message)
        
        //RELOAD TABLEVIEW
        self.chatTableView.reloadData()
        if self.messages.count > 0 {
            self.chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let ChatMessageCellIdentifier = "ChatMessageCellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(ChatMessageCellIdentifier) as ChatMessageTableViewCell!
        if cell == nil {
            cell = ChatMessageTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: ChatMessageCellIdentifier)
        }
        
        var message = self.messages[indexPath.row] as QBChatAbstractMessage
        cell.configureCellWithMessage(message)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var chatMessage = self.messages.objectAtIndex(indexPath.row) as QBChatAbstractMessage
        var cellHeight = ChatMessageTableViewCell.heightForCellWithMessage(chatMessage)
        return cellHeight
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(note: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -300)
            self.btnSendMsg.transform = CGAffineTransformMakeTranslation(0, -300)
            self.chatTableView.frame = CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.origin.y, self.chatTableView.frame.size.width, self.chatTableView.frame.size.height - 252)
        })
    }
    
    func keyboardWillHide(note: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageTextField.transform = CGAffineTransformIdentity
            self.btnSendMsg.transform = CGAffineTransformIdentity
            self.chatTableView.frame = CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.origin.y, self.chatTableView.frame.size.width, self.chatTableView.frame.size.height + 252)
        })
    }
    
    func completedWithResult(result: QBResult!) {
        if result.success && result.isKindOfClass(QBChatHistoryMessageResult) {
            var res = result as QBChatHistoryMessageResult
            var messagess = res.messages as NSArray
            if messagess.count > 0 {
                self.messages.addObjectsFromArray([messagess.mutableCopy()])
                self.chatTableView.reloadData()
                self.chatTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
        
        
    }


}
