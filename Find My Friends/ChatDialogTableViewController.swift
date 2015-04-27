//
//  ChatDialogTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/20/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ChatDialogTableViewController: UITableViewController, QBActionStatusDelegate, MBProgressHUDDelegate {
    
    var createdDialog: QBChatDialog!
    var dialogs: NSMutableArray! = NSMutableArray()
    var userDefault = NSUserDefaults.standardUserDefaults()
    var hud: MBProgressHUD!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var selectedDialog: QBChatDialog! = QBChatDialog()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }

    func initialize() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 130/255, blue: 184/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(objectsAndKeys: UIColor.whiteColor(), NSForegroundColorAttributeName,
            UIColor.whiteColor(), NSBackgroundColorAttributeName) as [NSObject : AnyObject]
        self.tableView.separatorColor = UIColor(red: 155/255, green: 180/255, blue: 201/255, alpha: 1)
        tableView.backgroundColor = UIColor(red: 55/255, green: 140/255, blue: 195/255, alpha: 1)
        tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get chat dialog list
        if LocalStorageService.sharedInstance().currentUser != nil {
            hud = MBProgressHUD(view: self.view)
            hud.delegate = self
            hud.labelText = "Get chat list"
            self.view.addSubview(hud)
            self.view.bringSubviewToFront(hud)
            hud.show(true)
            
            QBChat.dialogsWithExtendedRequest(nil, delegate: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.createdDialog != nil {
            self.performSegueWithIdentifier("ShowNewChatViewControllerSegue", sender: nil)
            println("NEW CHAT")
        }
    }
    
    @IBAction func createDialog(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowUsersViewControllerSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ShowChatViewControllerSegue" {
            let destinationViewController = segue.destinationViewController as! ChatViewController
            let cell = sender as! ChatDialogTableViewCell
            println("cell tag: \(cell.tag)")
            let dialog = self.dialogs.objectAtIndex(cell.tag) as! QBChatDialog
            destinationViewController.dialog = dialog
        } else if segue.identifier == "ShowNewChatViewControllerSegue" {
            let destinationViewController = segue.destinationViewController as! ChatViewController
            destinationViewController.dialog = self.createdDialog
            self.createdDialog = nil
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.dialogs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatDialogTableViewCell") as! ChatDialogTableViewCell

        let chatDialog = self.dialogs.objectAtIndex(indexPath.row) as! QBChatDialog
        
        cell.tag = indexPath.row
        
        switch chatDialog.type.value {
        case QBChatDialogTypePrivate.value:
            cell.lastMessage.text = "Private chat"
            let dictionary: [NSObject: AnyObject] = LocalStorageService.sharedInstance().usersAsDictionary
            let recipient = dictionary[chatDialog.recipientID] as? QBUUser
            cell.userName.text = recipient!.login
        case QBChatDialogTypeGroup.value:
            cell.lastMessage.text = "Group chat"
            cell.userName.text = chatDialog.name
        case QBChatDialogTypePublicGroup.value:
            cell.lastMessage.text = "Group chat"
            cell.userName.text = chatDialog.name
        default:
            break
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor(red: 55/255, green: 140/255, blue: 195/255, alpha: 1)
//        cell.backgroundColor = UIColor(red: 0, green: 115/255, blue: 150/255, alpha: 1)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
//    
//    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    /////////////////////quickbloxAPI
    func completedWithResult(result: QBResult!) {
        hud.hide(true)
        if result.success && result.isKindOfClass(QBDialogsPagedResult) {
            let pagedResult = result as! QBDialogsPagedResult
            if pagedResult.dialogs != nil {
                self.dialogs = NSMutableArray(array: pagedResult.dialogs)
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
}
