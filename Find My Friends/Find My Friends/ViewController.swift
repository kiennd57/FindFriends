//
//  ViewController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/9/15.
//  Copyright (c) 2015 Feed Team. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    
    // VARIABLES
    //let util = Utils()
    let maxIndex = Utils().MAX_VIEW
    var currentIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = 1
        pageControl.currentPage = 0
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "page1.png")!)
        addGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addGesture() {
        // left swipe gesture
        var leftGesture = UISwipeGestureRecognizer(target: self, action: "swipe:")
        leftGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftGesture)
        
        // right swipe gesture
        var rightGesture = UISwipeGestureRecognizer(target: self, action: "swipe:")
        rightGesture.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightGesture)
    }
    
    func swipe(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == UISwipeGestureRecognizerDirection.Left {
            if currentIndex == maxIndex {
                return
            } else {
                pageControl.currentPage = currentIndex
                currentIndex++
                setImageBackgroundWithImage("page\(currentIndex).png")
            }
            println("swipe left")
        } else if sender.direction == UISwipeGestureRecognizerDirection.Right {
            if currentIndex == 1 {
                return
            } else {
                pageControl.currentPage = currentIndex
                currentIndex--
                setImageBackgroundWithImage("page\(currentIndex).png")
            }
            println("swipe right")
        }
    }
    
    func setImageBackgroundWithImage(imageStr: String) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: imageStr)!)
    }

}

