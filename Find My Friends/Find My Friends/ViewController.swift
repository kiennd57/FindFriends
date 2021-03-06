//
//  ViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/14/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIAlertViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate , MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var locationManager: CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var checkinButton: UIButton!
    @IBOutlet weak var mapType: UISegmentedControl!
    @IBOutlet weak var userTable: UITableView!
    
    
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let util = Util()
    var status: NSString!
    var address: NSString!
    var users: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        users = NSArray()
        
        // Menu Bar Button Action
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        initialize()
        
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsPointsOfInterest = true
        mapView.showsBuildings = true
        
    }
    
    func initialize() {
        userTable.delegate = self
        userTable.dataSource = self
        checkinButton.layer.cornerRadius = 4.0
        checkinButton.layer.borderWidth = 0.1
        checkinButton.layer.borderColor = UIColor.greenColor().CGColor
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 45/255, green: 130/255, blue: 184/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(objectsAndKeys: UIColor.whiteColor(), NSForegroundColorAttributeName,
                                                                                                    UIColor.whiteColor(), NSBackgroundColorAttributeName) as [NSObject : AnyObject]
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        userTable.backgroundColor = UIColor(red: 55/255, green: 140/255, blue: 195/255, alpha: 1)
        userTable.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if userDefaults.boolForKey(kAuthorized) {
            retrieveUsers()
        } else {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        if self.mapView.annotations.count <= 1 {
//            for data in LocalStorageService.sharedInstance().checkins {
//                let geoData = data as! QBLGeoData
//                let cood = CLLocationCoordinate2D(latitude: geoData.latitude, longitude: geoData.longitude)
//                let pin = SSLMapPin(coordinate: cood)
//                pin.subtitle = geoData.status
//                pin.title = geoData.user.login
//                self.mapView.addAnnotation(pin)
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        locationManager.requestWhenInUseAuthorization()
        var region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        // ADD AN ANNOTATION
        var point = MKPointAnnotation()
        point.coordinate = userLocation.coordinate
        point.title = "This is title"
        point.subtitle = "This is subtitle"
        
//        mapView.addAnnotation(point)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        let AnnotationIdentifier = "AnnotationIdentifier"

            var theAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationIdentifier)

            var imageView = UIImageView()
            imageView.image = UIImage(named: "userTest.png")
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
            theAnnotationView.canShowCallout = true;
            theAnnotationView.image = UIImage(named: "pin.png")
            theAnnotationView.draggable = true
            return theAnnotationView
//        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending {
            println("Finish draging")
            println("The new latitude is: \(view.annotation.coordinate.latitude)")
            println("The new longitude is: \(view.annotation.coordinate.longitude)")
            
            view.dragState = MKAnnotationViewDragState.None
        }
    }
    
    @IBAction func changeMaptype(sender: AnyObject) {
        if mapType.selectedSegmentIndex == 0 {
            mapView.mapType = MKMapType.Standard
        } else if mapType.selectedSegmentIndex == 1 {
            mapView.mapType = MKMapType.Hybrid
        } else if mapType.selectedSegmentIndex == 2 {
            mapView.mapType = MKMapType.Satellite
        }
    }
    
    @IBAction func getLocation(sender: AnyObject) {
                var region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 800, 800)
                mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
                // ADD AN ANNOTATION
                var point = MKPointAnnotation()
                point.coordinate = self.mapView.userLocation.coordinate
                point.title = "This is title"
                point.subtitle = "This is subtitle"
                
                mapView.addAnnotation(point)
    }
    
    @IBAction func checkIn(sender: AnyObject) {
        
        if LocalStorageService.sharedInstance().currentUser == nil {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            
            var statusAlert = UIAlertView(title: "STATUS", message: "Please enter your status", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "Cancel")
            statusAlert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            statusAlert.textFieldAtIndex(0)?.placeholder = "Please enter your status here..."
            statusAlert.tag = 2
            statusAlert.delegate = self
            statusAlert.show()
        }
    }
    
    func doCheckInWithStatus(status: NSString) {
        println("OK")
        var hud = MBProgressHUD(view: self.view)
        self.view.addSubview(hud)
        hud.delegate = self
        hud.labelText = "CHECKING IN"
        hud.show(true)
        
        let ceo = CLGeocoder()
        let loc = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            let placeMark = placemarks[0] as? CLPlacemark
            self.address = "\(placeMark!.subLocality), \(placeMark!.locality)"
            self.userDefaults.setObject(self.address, forKey: "checkinAddress")
        })
        
        var geoData:QBLGeoData = QBLGeoData()
        geoData.latitude = self.mapView.userLocation.coordinate.latitude
        geoData.longitude = self.mapView.userLocation.coordinate.longitude
        geoData.status = status as String
        self.status = geoData.status
        QBRequest.createGeoData(geoData, successBlock: { (response: QBResponse!, geoData: QBLGeoData!) -> Void in
            hud.hide(true)
            self.performSegueWithIdentifier("goto_checkin", sender: self)
            }, errorBlock: { (response: QBResponse!) -> Void in
                hud.hide(true)
                var alertView = UIAlertView(title: "FAIL", message: "DM \(response.error.description)", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 2 {
            if buttonIndex == 0 {
                if (alertView.textFieldAtIndex(0)?.text == "") {
                    
                } else {
                    var status = alertView.textFieldAtIndex(0)?.text
                    doCheckInWithStatus(status!)
                }
            }
            else {
                println("CANCEL")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_checkin" {
            var destinationViewController = segue.destinationViewController as! CheckinViewController
            destinationViewController.mapView = self.mapView
//            destinationViewController.longtitude = self.mapView.userLocation.coordinate.longitude
//            destinationViewController.lattitude = self.mapView.userLocation.coordinate.latitude
            destinationViewController.status = self.status
            destinationViewController.theAddress = self.address
        }
    }
    
    /////////////////////////////////////
    func retrieveUsers() {
        QBRequest.usersForPage(QBGeneralResponsePage(currentPage: 0, perPage: 100, totalEntries: 100), successBlock: { (response: QBResponse!, responsePage: QBGeneralResponsePage!, userList: [AnyObject]!) -> Void in
            self.users = userList as NSArray
            self.userTable.reloadData()
            println("Count: \(self.users.count)")
            }) { (response: QBResponse!) -> Void in
            // FAIL
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UserMapTableViewCell
        let user = users[indexPath.row] as! QBUUser
        cell.userName.text = user.login
        cell.userImage.image = UIImage(named: "kien.jpg")
        cell.backgroundColor = UIColor(red: 55/255, green: 140/255, blue: 195/255, alpha: 1)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    /////////////////////////////////////////
    
    

}

