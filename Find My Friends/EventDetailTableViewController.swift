//
//  EventDetailTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/22/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventDetailTableViewController: UITableViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventPlace: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var minutes: UILabel!
    @IBOutlet weak var seconds: UILabel!
    
    @IBOutlet weak var eventDescription: UITextView!
    
    var event: QBCOCustomObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        showAllInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initialize() {
        eventDescription.layer.borderWidth = 0.5
        eventDescription.layer.cornerRadius = 4.0
        eventDescription.layer.borderColor = UIColor.whiteColor().CGColor
        
        let editBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "goToEditEvent")
        self.navigationItem.rightBarButtonItem = editBtn
    }
    
    func showAllInformation() {
        eventTitle.text = event.fields["eventName"] as NSString
        if event.fields["eventPlace"] != nil {
            eventPlace.text = event.fields["eventPlace"] as NSString
        }
        if event.fields["eventTime"] != nil {
            eventTime.text = event.fields["eventTime"] as NSString
        }
        if event.fields["eventDescription"] != nil {
            eventDescription.text = event.fields["eventDescription"] as NSString
        }
    }
    
    /////////////////////////////////////////////////////////////////////////
    func goToEditEvent() {
        println(__FUNCTION__)
    }
    
    @IBAction func deleteEvent(sender: AnyObject) {
        println(__FUNCTION__)
        let deleteAlert = UIAlertView(title: "Delete Event", message: "Are you sure?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Yes")
        deleteAlert.tag = 1
        deleteAlert.delegate = self
        deleteAlert.show()
    }
    ////////////////////////////////////////////////////////////////////////
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1 {
            if buttonIndex == 1 {
                println(__FUNCTION__)
            }
        }
    }
}
