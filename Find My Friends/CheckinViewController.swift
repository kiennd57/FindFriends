//
//  CheckinViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/19/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class CheckinViewController: UIViewController, MKMapViewDelegate,  CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    
    var locationManager: CLLocationManager!
    var status: NSString!
    var longtitude: CLLocationDegrees!
    var lattitude: CLLocationDegrees!
    var theAddress: NSString!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsPointsOfInterest = true
        mapView.showsBuildings = true
        println("ADDress: \(theAddress)")
        theAddress = NSUserDefaults.standardUserDefaults().objectForKey("checkinAddress") as! NSString
        address.text = theAddress as String
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 800, 800)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        // ADD AN ANNOTATION
        var point = MKPointAnnotation()
        point.coordinate = self.mapView.userLocation.coordinate
        point.title = status as String
        point.subtitle = "This is subtitle"
        
        mapView.addAnnotation(point)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 800, 800)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        // ADD AN ANNOTATION
        var point = MKPointAnnotation()
        point.coordinate = self.mapView.userLocation.coordinate
        point.title = status as String
        point.subtitle = "This is subtitle"
        
        mapView.addAnnotation(point)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }



}
