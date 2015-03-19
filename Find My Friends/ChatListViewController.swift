//
//  ChatListViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/17/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, QBActionStatusDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dialogTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var dialogs: NSMutableArray!
    var createdDialog: QBChatDialog!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Menu Bar Button Action
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if LocalStorageService.sharedInstance().currentUser != nil {
            QBChat.dialogsWithExtendedRequest(nil, delegate: nil)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.createdDialog != nil {
            self.performSegueWithIdentifier("ShowNewChatViewControllerSegue", sender: nil)
        }
    }
    
    
    @IBAction func createDialog(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowUsersViewControllerSegue", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(ChatViewController) {
            var destinationViewController = segue.destinationViewController as ChatViewController
            if self.createdDialog != nil {
                destinationViewController.dialog = self.createdDialog
                self.createdDialog = nil
            } else {
                let cell = sender as UITableViewCell
                var dialog = self.dialogs[cell.tag] as QBChatDialog
                destinationViewController.dialog = dialog
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dialogs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChatRoomCellIdentifier") as UITableViewCell!
        var chatDialog = self.dialogs[indexPath.row] as QBChatDialog
        cell.tag = indexPath.row
        
        cell.textLabel?.text = "TEST"
        cell.detailTextLabel?.text = "TEST"
        
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func completedWithResult(result: QBResult!) {
        if result.success && result.isKindOfClass(QBDialogsPagedResult) {
            var pagedResult = result as QBDialogsPagedResult
            var dialogs = pagedResult.dialogs as NSArray
            self.dialogs = dialogs.mutableCopy() as NSMutableArray
            var pagedRequest = QBGeneralResponsePage(currentPage: 0, perPage: 100)
            var dialogsUsersIDs = pagedResult.dialogsUsersIDs
            QBRequest.usersWithIDs(dialogsUsersIDs.allObjects, page: pagedRequest, successBlock: { (response: QBResponse!, responsePage: QBGeneralResponsePage!, objects: [AnyObject]!) -> Void in
                self.dialogTableView.reloadData()
                }, errorBlock: { (response: QBResponse!) -> Void in
                
            })
        } else {
            var alert = UIAlertView(title: "ERROR", message: "ERROR: \(result.errors.description)", delegate: self, cancelButtonTitle: "GOT IT")
            alert.show()
        }
    }
}
