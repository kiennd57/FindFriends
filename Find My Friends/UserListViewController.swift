//
//  UserListViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 4/19/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate {
    
    @IBOutlet weak var friendTableView: UITableView!
    
    var friendList: NSArray = NSArray()
    var participantList: NSMutableArray = NSMutableArray()
    var userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUsers()
        
        // Do any additional setup after loading the view.
        friendTableView.delegate = self
        friendTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backToCreateEvent(sender: AnyObject) {
        println(__FUNCTION__)
        userDefault.setObject(participantList, forKey: "participant")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    ////////////////////////////////////////////////////////////
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "cellUser"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UserTableViewCell
        
        let user = friendList[indexPath.row] as QBUUser
        cell.userName.text = user.login
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if participantList.containsObject(user.login) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as UserTableViewCell
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            participantList.addObject(cell.userName.text!)
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            participantList.removeObject(cell.userName.text!)
        }
        println("NUMBER OBJ: \(participantList.count)")
    }
    
    /////////////////////////////////////
    func retrieveUsers() {
        var hud = MBProgressHUD(view: self.view)
        self.view.addSubview(hud)
        hud.labelText = "LOADING"
        hud.delegate = self
        hud.show(true)
        self.friendTableView.hidden = true
        self.view.bringSubviewToFront(hud)
    
        QBRequest.usersForPage(QBGeneralResponsePage(currentPage: 0, perPage: 100, totalEntries: 100), successBlock: { (response: QBResponse!, responsePage: QBGeneralResponsePage!, userList: [AnyObject]!) -> Void in
            self.friendList = userList as NSArray
            self.friendTableView.reloadData()
            self.friendTableView.hidden = false
            hud.hide(true)
            }) { (response: QBResponse!) -> Void in
                // FAIL
                hud.hide(true)
                let alert = UIAlertView(title: "ERROR!", message: "Couldn't get friend list", delegate: self, cancelButtonTitle: "OK")
                alert.show()
        }
    }
}
