
//  ChatUserViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 4/21/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ChatUserViewController: UIViewController, NMPaginatorDelegate, UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate {
    
    @IBOutlet weak var usersTableView: UITableView!
    var users: NSMutableArray!
    var selectedUser: NSMutableArray!
    var paginator: UsersPaginator!
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.users = NSMutableArray()
        self.selectedUser = NSMutableArray()
        self.paginator = UsersPaginator(pageSize: 10, delegate: self)
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.paginator.fetchFirstPage()
    }

    @IBAction func createDialog(sender: AnyObject) {
        if selectedUser.count == 0 {
            let alert = UIAlertView(title: "ALERT!", message: "Please select at least 1 user", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        var chatDialog = QBChatDialog()
        var selectedUsersIds = NSMutableArray()
        var selectedUsersName = NSMutableArray()
        for var i = 0; i < selectedUser.count; i++ {
            let user = selectedUser.objectAtIndex(i) as! QBUUser
            selectedUsersIds.addObject(user.ID)
            selectedUsersName.addObject(user.login)
        }
        
        chatDialog.occupantIDs = selectedUsersIds as [AnyObject]!
        if self.selectedUser.count == 1 {
            chatDialog.type = QBChatDialogTypePrivate
        } else {
            chatDialog.name = selectedUsersName.componentsJoinedByString(",")
            chatDialog.type = QBChatDialogTypeGroup
        }

        QBChat.createDialog(chatDialog, delegate: self)
    }
    
    func fetchNextPage() {
        paginator.fetchNextPage()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userChatCell") as? UserChatCell
        
        let user = users.objectAtIndex(indexPath.row) as? QBUUser
        cell!.tag = indexPath.row
        cell!.userName.text = user!.login
        
        if selectedUser.containsObject(user!) {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        let user = users.objectAtIndex(indexPath.row) as? QBUUser
        if selectedUser.containsObject(user!) {
            selectedUser.removeObject(user!)
            selectedCell?.accessoryType = UITableViewCellAccessoryType.None
        } else {
            selectedUser.addObject(user!)
            selectedCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }
    
    func completedWithResult(result: QBResult!) {
        if result.success && result.isKindOfClass(QBChatDialogResult) {
            var dialogRes = result as! QBChatDialogResult
            let countView = self.navigationController?.viewControllers.count
            let dialogsViewController = self.navigationController?.viewControllers[countView! - 2] as! ChatDialogTableViewController
            dialogsViewController.createdDialog = dialogRes.dialog
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let alert = UIAlertView(title: "ERROR", message: "\(result.description)", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }

    func paginator(paginator: AnyObject!, didReceiveResults results: [AnyObject]!) {
        users.addObjectsFromArray(results)
        self.usersTableView.reloadData()
    }
}
