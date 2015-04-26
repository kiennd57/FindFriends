//
//  EventImageController.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 4/19/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventImageController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let cellIdentifier = "cell"
    var image = ["e_art.png", "e_boat.png", "e_bussiness.png", "e_buying.png", "e_camp.png", "e_cinema.png", "e_cycle.png", "e_game.png", "e_gamecomputer.png", "e_heart.png", "e_helicopter.png", "e_hotair.png", "e_learning.png", "e_magicwand.png", "e_magnifyingglass.png", "e_map.png", "e_math.png", "e_mic.png", "e_money.png", "e_motorcycle.png", "e_movie.png", "e_music.png", "e_news.png", "e_paint.png", "e_paintcan.png", "e_pencil.png", "e_phuot.png", "e_plane.png", "e_poker.png", "e_present.png", "e_programming.png", "e_racingflags.png", "e_running.png", "e_sailboat.png", "e_schooolbus.png", "e_scooter.png", "e_selffie.png", "e_shoeprints.png", "e_shopping.png", "e_skateboard.png", "e_spaceshuttle.png", "e_stockmarket.png", "e_tractor.png", "e_train.png", "e_unicycle.png"]
    
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        flowLayout.itemSize = CGSize(width: 70, height: 70)
        //        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView?.setCollectionViewLayout(flowLayout, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        userDefaults.setObject(self.image[indexPath.row], forKey: "eventImage")
//        println(userDefaults.objectForKey("eventImage"))
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return image.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
        
        // Configure the cell
        cell.imageView.image = UIImage(named: self.image[indexPath.row])
        
        return cell
    }

}
