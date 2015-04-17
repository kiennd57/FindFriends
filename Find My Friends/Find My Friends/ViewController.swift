//
//  ViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/14/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIAlertViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate , MBProgressHUDDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var locationManager: CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var checkinButton: UIButton!
    @IBOutlet weak var mapType: UISegmentedControl!
    
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let util = Util()
    var status: NSString!
    var address: NSString!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        checkinButton.layer.cornerRadius = 4.0
        checkinButton.layer.borderWidth = 0.1
        checkinButton.layer.borderColor = UIColor.greenColor().CGColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if userDefaults.boolForKey(util.KEY_AUTHORIZED) {
            
        } else {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.mapView.annotations.count <= 1 {
            for data in LocalStorageService.sharedInstance().checkins {
                let geoData = data as QBLGeoData
                let cood = CLLocationCoordinate2D(latitude: geoData.latitude, longitude: geoData.longitude)
                let pin = SSLMapPin(coordinate: cood)
                pin.subtitle = geoData.status
                pin.title = geoData.user.login
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
//        locationManager.requestWhenInUseAuthorization()
//        var region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
//        mapView.setRegion(mapView.regionThatFits(region), animated: true)
//        
//        // ADD AN ANNOTATION
//        var point = MKPointAnnotation()
//        point.coordinate = userLocation.coordinate
//        point.title = "This is title"
//        point.subtitle = "This is subtitle"
//        
//        mapView.addAnnotation(point)
//    }
    
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
            let placeMark = placemarks[0] as CLPlacemark
            println("PLACE MARK: \(placeMark)")
            println("City: \(placeMark.locality)")
            println("name: \(placeMark.name)")
            println("ocean: \(placeMark.ocean)")
            println("postal code: \(placeMark.postalCode)")
            println("sublocal: \(placeMark.subLocality)")
            self.address = "\(placeMark.subLocality), \(placeMark.locality)"
            self.userDefaults.setObject(self.address, forKey: "checkinAddress")
        })
        
        var geoData:QBLGeoData = QBLGeoData()
        geoData.latitude = self.mapView.userLocation.coordinate.latitude
        geoData.longitude = self.mapView.userLocation.coordinate.longitude
        geoData.status = status
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
            var destinationViewController = segue.destinationViewController as CheckinViewController
            destinationViewController.mapView = self.mapView
//            destinationViewController.longtitude = self.mapView.userLocation.coordinate.longitude
//            destinationViewController.lattitude = self.mapView.userLocation.coordinate.latitude
            destinationViewController.status = self.status
            destinationViewController.theAddress = self.address
        }
    }
}

