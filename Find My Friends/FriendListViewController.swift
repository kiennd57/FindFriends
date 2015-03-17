//
//  FriendListViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/16/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NMPaginatorDelegate, QBActionStatusDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var usersTableView: UITableView!
    
    var users: NSMutableArray!
    var paginator: UsersPaginator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Menu Bar Button Action
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        users = NSMutableArray()
        paginator = UsersPaginator(pageSize: 10, delegate: self)
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        paginator.fetchFirstPage()
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cellUserIdentifier") as UITableViewCell
        
        var user = users[indexPath.row] as QBUUser
        cell.tag = indexPath.row
        cell.textLabel?.text = user.login
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    /////
    func fetchNextPage() {
        
    }
    
//    func completedWithResult(result: QBResult!) {
//        if result.success && result.isKindOfClass(QBChatDialogResult) {
//            var dialogResult = result as QBChatDialogResult
//            
//        }
//    }
    
    func paginator(paginator: AnyObject!, didReceiveResults results: [AnyObject]!) {
        users.addObjectsFromArray(results)
        println("NUMBER USER: \(users.count)")
        usersTableView.reloadData()
    }

}
