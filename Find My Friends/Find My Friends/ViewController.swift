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
    @IBOutlet weak var imageView: UIImageView!
    
    // VARIABLES
    //let util = Utils()
    let maxIndex = Utils().MAX_VIEW
    var currentIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = 1
        pageControl.currentPage = 0
        imageView.image = UIImage(named: "page1.png")
        
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
        
        var rightGesture = UISwipeGestureRecognizer(
    }
    
    func swipe(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == UISwipeGestureRecognizerDirection.Left {
            if currentIndex == maxIndex {
                return
            } else {
                currentIndex++
                pageControl.currentPage = currentIndex - 1
                setImageBackgroundWithImage("page\(currentIndex).png")
            }
            println("swipe left")
        } else if sender.direction == UISwipeGestureRecognizerDirection.Right {
            if currentIndex == 1 {
                return
            } else {
                currentIndex--
                pageControl.currentPage = currentIndex - 1
                setImageBackgroundWithImage("page\(currentIndex).png")
            }
            println("swipe right")
        }
    }
    
    func setImageBackgroundWithImage(imageStr: String) {
        imageView.image = UIImage(named: imageStr)
        
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        // 2
        var blurView = UIVisualEffectView(effect: darkBlur)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        blurView.frame = imageView.bounds
        // 3
        imageView.addSubview(blurView)
        

    }

}

