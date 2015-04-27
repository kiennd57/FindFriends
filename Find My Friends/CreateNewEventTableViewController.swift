//
//  CreateNewEventTableViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 4/19/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class CreateNewEventTableViewController: StaticDataTableViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let userDefault = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventTime: UITextField!
    @IBOutlet weak var eventPlace: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventMapView: MKMapView!
    var countUpdated = 0
    
    var eventAnnotation: SSLMapPin!
    
    var datePicker: UIDatePicker!
    var pickerToolBar: UIToolbar!
    var userDefaults: NSUserDefaults!
    var locationManager: CLLocationManager!
    var participant: NSMutableArray = NSMutableArray()
    var friendList: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println(__FUNCTION__)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

            var imageName = userDefaults.objectForKey("eventImage") as! String
            eventImage.image = UIImage(named: imageName)

        if userDefaults.objectForKey("participant") != nil {
            participant = userDefaults.objectForKey("participant") as! NSMutableArray
            self.tableView.reloadData()
            userDefaults.removeObjectForKey("participant")
        }
    }
    
    func initialize() {
        userDefaults = NSUserDefaults.standardUserDefaults()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        eventTitle.delegate = self
        eventTime.delegate = self
        eventPlace.delegate = self
        eventDescription.delegate = self
        eventDescription.layer.borderWidth = 0.5
        eventDescription.layer.borderColor = UIColor.blackColor().CGColor
        eventDescription.layer.cornerRadius = 4.0
        
        createDatePicker()
        createSaveButtonBar()
        createSelectImageAction()
        
        //Map
        eventMapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        eventMapView.showsPointsOfInterest = true
        eventMapView.showsBuildings = true
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: "gotoEventMap")
//        eventMapView.addGestureRecognizer(tapGesture)
    }
    
    func gotoEventMap() {
        self.performSegueWithIdentifier("goto_eventMap", sender: nil)
    }
    
    /////////////////////////////////////////////////////////////
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if countUpdated == 0 {
            locationManager.requestWhenInUseAuthorization()
            var region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            eventAnnotation = SSLMapPin(coordinate: userLocation.coordinate)
            mapView.addAnnotation(eventAnnotation)
            countUpdated++
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        let AnnotationIdentifier = "eventAnnotation"
        var theAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationIdentifier)
        
        var imageView = UIImageView()
        imageView.image = UIImage(named: "e_default.png")
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
        theAnnotationView.draggable = true
        return theAnnotationView
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending {
            println("Finish draging")
            println("The new latitude is: \(view.annotation.coordinate.latitude)")
            println("The new longitude is: \(view.annotation.coordinate.longitude)")
            view.dragState = MKAnnotationViewDragState.None
        } else if newState == MKAnnotationViewDragState.Canceling {
            view.dragState = MKAnnotationViewDragState.None
        }
    }
    
    
    ////////////////////////////////////
    func createSaveButtonBar() {
        let saveBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveEvent")
        self.navigationItem.rightBarButtonItem = saveBtn
    }
    
    func saveEvent() {
        println(__FUNCTION__)
        
        if canBeSave() {
            
            let hud = MBProgressHUD(view: self.view)
            hud.delegate = self
            hud.labelText = "Creating"
            self.view.addSubview(hud)
            self.view.bringSubviewToFront(hud)
            hud.show(true)
            
            let owner = self.userDefault.objectForKey("currentUserName") as! String!
                      
            let event = QBCOCustomObject()
            event.className = "Event"
            event.fields["eventName"] = self.eventTitle.text
            event.fields["eventDescription"] = self.eventDescription.text
            event.fields["eventPlace"] = self.eventPlace.text
            event.fields["eventTime"] = self.eventTime.text
            event.fields["eventImage"] = userDefaults.objectForKey("eventImage")
            event.fields["eventParticipant"] = participant
            event.fields["eventOwner"] = owner
            
            QBRequest.createObject(event, successBlock: { (response: QBResponse!, object: QBCOCustomObject!) -> Void in
                let successAlert = UIAlertView(title: "SUCCESS!", message: "Your event was created and sent to your friend", delegate: self, cancelButtonTitle: "GOT IT")
                successAlert.show()
                hud.hide(true)
                }) { (response: QBResponse!) -> Void in
                    let failAlert = UIAlertView(title: "OOPS!", message: "Something happen! Try again later", delegate: self, cancelButtonTitle: "OK")
                    failAlert.show()
                    hud.hide(true)
            }
        } else {
            let alert = UIAlertView(title: "ERROR!", message: "Please fill all informations", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func canBeSave() -> Bool {
        if eventTitle.text.isEmpty {return false}
        if eventPlace.text.isEmpty {return false}
        if eventTime.text.isEmpty {return false}
        if eventDescription.text.isEmpty {return false}
        if participant.count == 0 {return false}
        
        return true
    }
    ////////////////////////////////////////////////////////////////////////////////////
    func createSelectImageAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "gotoEventType")
        eventImage.addGestureRecognizer(tapGesture)
    }
    
    func gotoEventType() {
        self.performSegueWithIdentifier("goto_EventType", sender: self)
    }
    ////////////////////////////////////////////////////////////////////////////////
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return participant.count + 1
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        } else {
            if indexPath.row == participant.count {
                let cellIdentifier = "cellAddFriend"
                tableView.registerNib(UINib(nibName: "AddParticipantTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! AddParticipantTableViewCell
                cell.btnInvite.addTarget(self, action: "inviteUserAction", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            } else {
                let cellIdentifier = "cellUserInvited"
                tableView.registerNib(UINib(nibName: "UserInvitedTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UserInvitedTableViewCell
                cell.userName.text = participant.objectAtIndex(indexPath.row) as? String
                return cell
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        } else {
            return 60
        }
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            if indexPath.row < participant.count {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            participant.removeObjectAtIndex(indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel.textColor = UIColor.blackColor()
        header.textLabel.font = UIFont.boldSystemFontOfSize(18)
        header.textLabel.frame = header.frame
        header.textLabel.textAlignment = NSTextAlignment.Left
        
        header.backgroundColor = UIColor.redColor()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////
    func inviteUserAction() {
        self.performSegueWithIdentifier("goto_selectUser", sender: self)
    }

    
    ////////////////////////////////////////
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    ///////////////////////////////////////////////////
    func createDatePicker() {
        datePicker = UIDatePicker(frame: CGRectMake(0, 50, 320, 480))
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        datePicker.sizeToFit()
        //        datePicker.locale = NSLocale(localeIdentifier: "da_VI")
        eventTime.inputView = datePicker
        
        pickerToolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 40))
        pickerToolBar.barStyle = UIBarStyle.Black
        pickerToolBar.sizeToFit()
        
        var barItems = NSMutableArray()
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        barItems.addObject(flexSpace)
        
        var doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneAction")
        barItems.addObject(doneButton)
        pickerToolBar.setItems(barItems as [AnyObject], animated: true)
        eventTime.inputAccessoryView = pickerToolBar
    }
    
    func doneAction() {
        println("DONE")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateStr = dateFormatter.stringFromDate(datePicker.date)
        eventTime.text = dateStr
        eventTime.resignFirstResponder()
    }
    
    ////////////////////////////////////////////////
}
