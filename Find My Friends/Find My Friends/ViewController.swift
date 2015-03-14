//
//  ViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/14/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if userDefaults.boolForKey(util.KEY_AUTHORIZED) {
            // TO BE ADDED
        } else {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

