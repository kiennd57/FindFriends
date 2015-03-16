//
//  FriendListViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/16/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NMPaginatorDelegate {

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
        
        paginator = UsersPaginator(pageSize: 10, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        paginator.fetchFirstPage()
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        return UITableViewCell()
    }
    
    
    
    /////
    func fetchNextPage() {
        
    }
    
    
    func paginator(paginator: AnyObject!, didReceiveResults results: [AnyObject]!) {
        
    }

}
