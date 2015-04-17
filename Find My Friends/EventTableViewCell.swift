//
//  EventTableViewCell.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/21/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imageEvent: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventPlace: UILabel!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
