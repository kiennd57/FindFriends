//
//  ViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/14/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIAlertViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!

    var locationManager: CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let util = Util()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Menu Bar Button Action
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
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
        
        mapView.addAnnotation(point)
    }
    
    @IBAction func checkIn(sender: AnyObject) {
        
        var geoData = QBLGeoData()
        geoData.ID = 100
        geoData.latitude = self.mapView.userLocation.coordinate.latitude
        geoData.longitude = self.mapView.userLocation.coordinate.longitude
        geoData.status = "TEST STATUS"
        
        QBRequest.updateGeoData(geoData, successBlock: { (response: QBResponse!, geoData: QBLGeoData!) -> Void in
            var alertView = UIAlertView(title: "SUCCESS", message: "NGOT", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
            }, errorBlock: { (response: QBResponse!) -> Void in
                var alertView = UIAlertView(title: "FAIL", message: "DM \(response.description)", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
        })
        
//        QBRequest.createSessionWithSuccessBlock({ (response: QBResponse!, session: QBASession!) -> Void in
//            
//            
//            }, errorBlock: { (response: QBResponse!) -> Void in
//                var alertView = UIAlertView(title: "SESSION FAIL", message: "DINH MENH", delegate: self, cancelButtonTitle: "OK")
//                alertView.show()
//        })
    }
    
    
    
}

