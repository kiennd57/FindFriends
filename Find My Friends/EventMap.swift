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
    var eventAnnotation: SSLMapPin!

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var centerLocation = mapView.centerCoordinate
        eventAnnotation = SSLMapPin(coordinate: centerLocation)
        mapView.addAnnotation(eventAnnotation)
    }

    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        let AnnotationIdentifier = "eventAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(AnnotationIdentifier) as MKAnnotationView!
        
        if annotationView != nil {
            return annotationView
        } else {
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
            theAnnotationView.canShowCallout = true;
            theAnnotationView.image = UIImage(named: "pin.png")
            theAnnotationView.draggable = true
            theAnnotationView.userInteractionEnabled = true
            return theAnnotationView
        }
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending {
            println("Finish draging")
            println("The new latitude is: \(view.annotation.coordinate.latitude)")
            println("The new longitude is: \(view.annotation.coordinate.longitude)")
        }
    }
}
