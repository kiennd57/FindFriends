//
//  ChatDialogTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/20/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ChatDialogTableViewController: UITableViewController, QBActionStatusDelegate {
    
    var createdDialog: QBChatDialog! = QBChatDialog()
    var dialogs: NSMutableArray! = NSMutableArray()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var selectedDialog: QBChatDialog! = QBChatDialog()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get chat dialog list
        if LocalStorageService.sharedInstance().currentUser != nil {
            QBChat.dialogsWithExtendedRequest(nil, delegate: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        if self.createdDialog != nil {
//            self.performSegueWithIdentifier("ShowSplashViewControllerSegue", sender: nil)
//        }
    }
    
    @IBAction func createDialog(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowUsersViewControllerSegue", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.destinationViewController.isKindOfClass(ChatViewController) {
//            let desController = segue.destinationViewController as ChatViewController
//            if self.createdDialog != nil {
//                desController.dialog = self.createdDialog
//                self.createdDialog = nil
//            } else {
//                let cell = sender as ChatDialogTableViewCell
//                let dialog = self.dialogs.objectAtIndex(cell.tag) as QBChatDialog
//                desController.dialog = dialog
//            }
//        }
        
        if segue.identifier == "ShowChatViewControllerSegue" {
            let desController = segue.destinationViewController as ChatViewController
            desController.dialog = selectedDialog
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.dialogs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatDialogTableViewCell") as ChatDialogTableViewCell

        let chatDialog = self.dialogs.objectAtIndex(indexPath.row) as QBChatDialog
        
        
        cell.tag = indexPath.row
        
        cell.userName.text = chatDialog.name
        cell.lastMessage.text = "Fuck you"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedDialog = self.dialogs.objectAtIndex(indexPath.row) as QBChatDialog
        self.performSegueWithIdentifier("ShowChatViewControllerSegue", sender: nil)
    }
    
    /////////////////////quickbloxAPI
    func completedWithResult(result: QBResult!) {
        if result.success && result.isKindOfClass(QBDialogsPagedResult) {
            let pagedResult = result as QBDialogsPagedResult
            var dialogs = pagedResult.dialogs as NSArray
            self.dialogs = dialogs.mutableCopy() as NSMutableArray
            let pagedRequest = QBGeneralResponsePage(currentPage: 0, perPage: 100, totalEntries: 100)as QBGeneralResponsePage
            let dislogsUsersIDs = pagedResult.dialogsUsersIDs as NSSet
            QBRequest.usersWithIDs(dislogsUsersIDs.allObjects, page: pagedRequest, successBlock: { (response: QBResponse!, responsePage: QBGeneralResponsePage!, users: [AnyObject]!) -> Void in
                LocalStorageService.sharedInstance().users = users
                self.tableView.reloadData()
                }, errorBlock: { (response: QBResponse!) -> Void in
                
            })
        }
    }
}
