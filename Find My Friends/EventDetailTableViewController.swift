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
    var eventDate: NSDate!
    var dateFormatter: NSDateFormatter!
    var timer: NSTimer!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        showAllInformation()
        calculateTimeRemaining()
        countDownTimeRemaining()
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
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let str = event.fields["eventTime"] as String
        let eventDateStr = "\(str):00"
        println("\(eventDateStr)")
        eventDate = dateFormatter.dateFromString(eventDateStr)
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
        eventImage.image = UIImage(named: event.fields["eventImage"] as String)
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
    
    /////////////////////////////////////////////////////////////////////////////////////////
    func calculateTimeRemaining() {
        println(__FUNCTION__)
        
        let currentDate = NSDate()
        let theSeconds = eventDate.timeIntervalSinceDate(currentDate)
        
        let dayRemain = Int(theSeconds/(24 * 3600)) as Int
        let hourRemain = Int((theSeconds%(24*3600))/3600) as Int
        let minuteRemain = Int(((theSeconds%(24*3600))%3600)/60) as Int
        let secondRemain = Int((((theSeconds%(24*3600))%3600)%60)%60) as Int
        
        if theSeconds > 0 {
            days.text = "\(dayRemain)"
            hours.text = "\(hourRemain)"
            minutes.text = "\(minuteRemain)"
            seconds.text = "\(secondRemain)"
        } else {
//            timer.invalidate()
            days.text = "0"
            hours.text = "0"
            minutes.text = "0"
            seconds.text = "0"
        }
    }
    
    func countDownTimeRemaining() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "calculateTimeRemaining", userInfo: nil, repeats: true) as NSTimer
    }
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
    }
}
