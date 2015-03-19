//
//  RootViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/18/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("TEST")
        self.view.backgroundColor = UIColor.redColor()

                    QBRequest.createSessionWithSuccessBlock({ (response: QBResponse!, session: QBASession!) -> Void in
                        println("CREATE SESSION SUCCESSFULLY!")
                        var filter = QBLGeoDataFilter()
                        filter.lastOnly = true
                        filter.sortBy = GeoDataSortByKindLatitude
                        QBRequest.geoDataWithFilter(filter, page: QBGeneralResponsePage(currentPage: 1, perPage: 6), successBlock: { (response: QBResponse!, objects: [AnyObject]!, responsePage: QBGeneralResponsePage!) -> Void in
        
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2*NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                                let appdelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                self.presentViewController(appdelegate.rootController, animated: true, completion: nil)
                            })
        
                            LocalStorageService.sharedInstance().saveCheckins(objects)
                            println("CHECKIN LIST: \(LocalStorageService.sharedInstance().checkins)")
        
                            }, errorBlock: { (response: QBResponse!) -> Void in
        
                        })
                        }, errorBlock: { (response: QBResponse!) -> Void in
                            var alertView = UIAlertView(title: "SESSION CREATED FAILT", message: "DINH MENH", delegate: self, cancelButtonTitle: "OK")
                            alertView.show()
                    })
        

        
        
        
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
