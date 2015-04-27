//
//  EventDetailTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/22/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventDetailTableViewController: UITableViewController, UIAlertViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventPlace: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventMapLocation: MKMapView!
    
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var minutes: UILabel!
    @IBOutlet weak var seconds: UILabel!
    
    @IBOutlet weak var eventDescription: UITextView!
    
    var event: QBCOCustomObject!
    var eventDate: NSDate!
    var dateFormatter: NSDateFormatter!
    var timer: NSTimer!
    var locationManager: CLLocationManager!
    
    var eventAnnotation: SSLMapPin!
    
    
    var thisEvent: QBCOCustomObject!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        initialize()
        showAllInformation()
        calculateTimeRemaining()
        countDownTimeRemaining()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("eventImage")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initialize() {
        eventDescription.layer.borderWidth = 0.5
        eventDescription.layer.cornerRadius = 4.0
        eventDescription.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let editBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "goToEditEvent")
        self.navigationItem.rightBarButtonItem = editBtn
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let str = event.fields["eventTime"] as! String
        let eventDateStr = "\(str):00"
        println("\(eventDateStr)")
        eventDate = dateFormatter.dateFromString(eventDateStr)
        
        eventMapLocation.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        eventMapLocation.showsPointsOfInterest = true
        eventMapLocation.showsBuildings = true
        
        
    }
    
    func showAllInformation() {
        thisEvent = LocalStorageService.sharedInstance().currentEvent
        eventTitle.text = thisEvent.fields["eventName"] as? String
        if event.fields["eventPlace"] != nil {
            eventPlace.text = thisEvent.fields["eventPlace"] as? String
        }
        if event.fields["eventTime"] != nil {
            eventTime.text = thisEvent.fields["eventTime"] as? String
        }
        if event.fields["eventDescription"] != nil {
            eventDescription.text = thisEvent.fields["eventDescription"] as? String
        }
        eventImage.image = UIImage(named: (thisEvent.fields["eventImage"] as? String)!)
        
        let longitude = thisEvent.fields["longitude"] as! NSString
        let doubleLongitude = theDoubleValue(longitude)
        
        let latitude = thisEvent.fields["latitude"] as! NSString
        let doubleLatitude = theDoubleValue(latitude)
        
        println("Longitude is: \(doubleLongitude)")
        eventAnnotation = SSLMapPin(coordinate: CLLocationCoordinate2D(latitude: doubleLatitude, longitude: doubleLongitude))
        eventMapLocation.addAnnotation(eventAnnotation)
        
        var region = MKCoordinateRegionMakeWithDistance(eventAnnotation.coordinate, 800, 800)
        eventMapLocation.setRegion(eventMapLocation.regionThatFits(region), animated: true)
    }
    
    func theDoubleValue(str: NSString!) -> Double {
        
        return str.doubleValue
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        let AnnotationIdentifier = "eventAnnotation"
        var theAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationIdentifier)
        
        var imageView = UIImageView()
        imageView.image = UIImage(named: (event.fields["eventImage"] as? String)!)
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.backgroundColor = UIColor.redColor()
        var f: CGRect = CGRectMake(5,5.5,45,45);
        imageView.frame = f
        imageView.layer.cornerRadius = 22.5;
        imageView.layer.masksToBounds = true;
        theAnnotationView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIView
        
        theAnnotationView.addSubview(imageView)
        theAnnotationView.enabled = true;
        theAnnotationView.image = UIImage(named: "pin.png")
        return theAnnotationView
    }
    
    /////////////////////////////////////////////////////////////////////////
    func goToEditEvent() {
        println(__FUNCTION__)
        
        self.performSegueWithIdentifier("goto_editEvent", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let desController = segue.destinationViewController as! EditEventTableViewController
        desController.event = self.event
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
            if timer != nil {
                timer.invalidate()
            }
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
