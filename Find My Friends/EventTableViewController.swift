//
//  EventTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/21/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController, MBProgressHUDDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var eventList: NSArray = NSArray()
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveAllEvents()
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as EventTableViewCell
        
        let event = eventList[indexPath.row] as QBCOCustomObject
        
        println(event.fields["eventName"])
        cell.eventTitle.text = event.fields["eventName"] as NSString
        if event.fields["eventPlace"] != nil {
            cell.eventPlace.text = event.fields["eventPlace"] as NSString
        }
        if event.fields["eventTime"] != nil {
            cell.dateTime.text = event.fields["eventTime"] as NSString
        }

        
//        cell.imageEvent.image = UIImage(named: images[indexPath.row])
//        cell.eventTitle.text = eventtitle[indexPath.row]
//        cell.eventPlace.text = places[indexPath.row]
//        cell.timeRemaining.text = "30"
//        cell.date.text = "Days"
//        cell.dateTime.text = "April, 20 @ 15 : 00"
        
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        self.performSegueWithIdentifier("goto_eventDetail", sender: self)
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
            self.eventList = object as NSArray
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
            let desController = segue.destinationViewController as EventDetailTableViewController
            let selectedEvent = eventList.objectAtIndex(selectedRow) as QBCOCustomObject
            desController.event = selectedEvent
        }
    }
}
