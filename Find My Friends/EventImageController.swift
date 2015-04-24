//
//  EventImageController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 4/19/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventImageController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventTypeTableView: UITableView!
    
    let cellIdentifier = "cellEventType"
    let images = ["e_birthday.png", "e_coffee.png", "e_dinner.png", "e_family.png", "e_golf.png", "e_graduated.png", "e_meeting", "e_networking_event.png", "e_party.png", "e_press_conference.png", "e_seminar.png", "e_show.png", "e_team_building_event.png", "e_travel.png", "e_wedding.png"]
    let types = ["Birthday", "Coffee", "Dinner", "Family", "Golf", "Graduation", "Meeting", "Networking event", "Party", "Conference", "Seminar", "Show", "Team building", "Travel", "Wedding"]
    
    var userDefaults: NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventTypeTableView.delegate = self
        eventTypeTableView.dataSource = self
        userDefaults = NSUserDefaults.standardUserDefaults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! EventTypeTableViewCell!
        cell.eventImage.image = UIImage(named: images[indexPath.row])
        cell.eventType.text = types[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        userDefaults.setObject(images[indexPath.row], forKey: "eventImage")
        userDefaults.setObject(types[indexPath.row], forKey: "eventType")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
