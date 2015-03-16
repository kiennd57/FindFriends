//
//  MapPin.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/16/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit
import MapKit

class MapPin: NSObject {
    var title: NSString!
    var subtitle: NSString!
    var coordinate: CLLocationCoordinate2D!
    init(coodinate: CLLocationCoordinate2D) {
        super.init()
        coordinate = coodinate
    }
}
