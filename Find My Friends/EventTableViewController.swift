//
//  EventTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/21/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController, MBProgressHUDDelegate {
    let userDefault = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var eventList: NSArray = NSArray()
    var selectedRow = 0
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveAllEvents()
        // Menu Bar Button Action
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 130/255, blue: 184/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(objectsAndKeys: UIColor.whiteColor(), NSForegroundColorAttributeName,
            UIColor.whiteColor(), NSBackgroundColorAttributeName) as [NSObject : AnyObject]
        tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        tableView.backgroundColor = UIColor(red: 0, green: 115/255, blue: 150/255, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if LocalStorageService.sharedInstance().events != nil {
            self.eventList = LocalStorageService.sharedInstance().events as NSArray
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return eventList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventTableViewCell
        
        let event = eventList.objectAtIndex(indexPath.row) as! QBCOCustomObject

        cell.eventTitle.text = event.fields["eventName"] as? String
        if event.fields["eventPlace"] != nil {
            cell.eventPlace.text = event.fields["eventPlace"] as? String
        }
        if event.fields["eventTime"] != nil {
            cell.dateTime.text = event.fields["eventTime"] as? String
        }
        
        
        ////
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let currentDate = NSDate()
        let str = event.fields["eventTime"] as? String
        let eventDateStr = str?.stringByAppendingString(":00")
        let eventDate = dateFormatter.dateFromString(eventDateStr!)
        let theSecond = eventDate?.timeIntervalSinceDate(currentDate)
//        println("\(currentDate)   \(theSecond)")
        let dayRemain = Int(theSecond!/(24 * 3600)) as Int
        let hourRemain = Int((theSecond!%(24*3600))/3600) as Int
        let minuteRemain = Int(((theSecond!%(24*3600))%3600)/60) as Int
        let secondRemain = Int((((theSecond!%(24*3600))%3600)%60)%60) as Int
        
        if dayRemain > 0 {
            cell.date.text = "Days"
            cell.timeRemaining.text = "\(dayRemain)"
            cell.statusView.backgroundColor = UIColor(red: 31/255, green: 138/255, blue: 112/255, alpha: 1)
        } else if hourRemain > 0 {
            cell.date.text = "Hours"
            cell.timeRemaining.text = "\(hourRemain)"
            cell.statusView.backgroundColor = UIColor(red: 166/255, green: 191/255, blue: 50/255, alpha: 1)
        } else if minuteRemain > 0 {
            cell.date.text = "Minutes"
            cell.timeRemaining.text = "\(minuteRemain)"
            cell.statusView.backgroundColor = UIColor(red: 200/255, green: 190/255, blue: 0/255, alpha: 1)
        } else {
            cell.date.text = ""
            cell.timeRemaining.text = "Over!"
            cell.statusView.backgroundColor = UIColor(red: 253/255, green: 116/255, blue: 0/255, alpha: 1)
        }
        
        cell.backgroundColor = UIColor(red: 0, green: 115/255, blue: 150/255, alpha: 1)
        
        cell.imageEvent.image = UIImage(named: (event.fields["eventImage"] as? String)!)
        
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        
        LocalStorageService.sharedInstance().currentEvent = self.eventList.objectAtIndex(indexPath.row) as! QBCOCustomObject
        
        self.performSegueWithIdentifier("goto_eventDetail", sender: self)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let event = eventList.objectAtIndex(indexPath.row) as! QBCOCustomObject
            let userName = LocalStorageService.sharedInstance().currentUser.login
            let owner = event.fields["eventOwner"] as! String!
            
            if (owner != userName && owner != nil) {
                let alert = UIAlertView(title: "Alert!", message: "You don't have right to delete", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            else {
                QBRequest.deleteObjectWithID(event.ID, className: "Event", successBlock: { (response: QBResponse!) -> Void in
                    let alert = UIAlertView(title: "OK", message: "OK", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    var eventListMutable = NSMutableArray(array: self.eventList)
                    eventListMutable.removeObjectAtIndex(indexPath.row)
                    self.eventList = eventListMutable
                    self.tableView.reloadData()
                    }, errorBlock: { (error: QBResponse!) -> Void in
                        let alert = UIAlertView(title: "fail", message: "fail", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                })
            }
        }
    }
    
    func filterEvent(senderEvents: NSArray) -> NSArray {
        let temp = NSMutableArray(array: senderEvents)
        
        for var i = 0; i < temp.count; i++ {
            let event = temp.objectAtIndex(i) as! QBCOCustomObject
            let participants = event.fields["eventParticipant"] as! NSMutableArray
            
            if(participants.count > 0) {
                if (!participants.containsObject(LocalStorageService.sharedInstance().currentUser.login) ) {
                    temp.removeObjectAtIndex(i)
                }
            }
        }
        
        return temp
    }

    /////////////////////////////////
    func retrieveAllEvents() {
        
        let hud = MBProgressHUD(view: self.view)
        hud.delegate = self
        hud.labelText = "Loading"
        self.view.addSubview(hud)
        
        self.view.bringSubviewToFront(hud)
        hud.show(true)
        
        QBRequest.objectsWithClassName("Event", successBlock: { (response: QBResponse!, object: [AnyObject]!) -> Void in
            self.eventList = NSArray(array: object)
            self.eventList = self.filterEvent(self.eventList)
            self.eventList = self.sortEventTime(self.eventList)
            LocalStorageService.sharedInstance().events = self.eventList as [AnyObject]
            self.tableView.reloadData()
            hud.hide(true)
            }) { (response: QBResponse!) -> Void in
            let alertView = UIAlertView(title: "ERROR!", message: "Fail to load events", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
            hud.hide(true)
        }
    }
    
    ////////////////////////////////////////////////////////
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_eventDetail" {
            let desController = segue.destinationViewController as! EventDetailTableViewController
            let selectedEvent = eventList.objectAtIndex(selectedRow) as! QBCOCustomObject
            desController.event = selectedEvent
        } else if segue.identifier == "goto_createEvent" {
            userDefaults.setObject("e_default.png", forKey: "eventImage")
        }
    }
    
    ///////////////////////////////////////////////////////////////////////
    func sortEventTime(eventList: NSArray!) -> NSArray{
        var tmpList = NSMutableArray(array: eventList)
        for var i = 0; i < tmpList.count - 1; i++ {
            for var j = i + 1; j < tmpList.count; j++ {
                var a = self.timeRemaining(tmpList.objectAtIndex(i) as! QBCOCustomObject)
                var b = self.timeRemaining(tmpList.objectAtIndex(j) as! QBCOCustomObject)
                if(a > b){
                    tmpList.exchangeObjectAtIndex(i, withObjectAtIndex: j)
                }
            }
        }
        
        return tmpList
    }
    
    func timeRemaining(event: QBCOCustomObject!) -> Int {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"

        let str = event.fields["eventTime"] as! String

        let eventDate = dateFormatter.dateFromString(str)
        
        let s = eventDate?.timeIntervalSince1970
        
        return Int(s!)
    }
}
