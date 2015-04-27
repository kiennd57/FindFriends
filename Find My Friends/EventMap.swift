//
//  EventMap.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 4/27/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    var countUpdated = 0
    var eventAnnotationView: SSLMapPin!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsPointsOfInterest = true
        mapView.showsBuildings = true
//        mapView.showsUserLocation = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if countUpdated == 0 {
            locationManager.requestWhenInUseAuthorization()
            var region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            eventAnnotationView = SSLMapPin(coordinate: userLocation.coordinate)
            mapView.addAnnotation(eventAnnotationView)
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
}
