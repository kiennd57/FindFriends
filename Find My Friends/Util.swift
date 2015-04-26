//
//  Util.swift
//  Find My Friends
//
//  Created by Phong Nguyen Nam on 3/14/15.
//  Copyright (c) 2015 Nam Phong Nguyen. All rights reserved.
//

import UIKit

class Util {
   let KEY_AUTHORIZED = "authorized"
    
    func setupTextField(textField: UITextField) {
        textField.layer.borderWidth = 1.5
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func setImageBlur(imageView: UIImageView) {
        var lightBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var blurView = UIVisualEffectView(effect: lightBlur)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    
    func blurImage(theImage: UIImage) -> UIImage {
        var context = CIContext(options: nil)
        var inputImage = CIImage(CGImage: theImage.CGImage)
        var filter = CIFilter(name: "CIGaussianBlur")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(float: 10), forKey: "inputRadius")
        var result = filter.valueForKey(kCIOutputImageKey) as! CIImage
        var cgImage = context.createCGImage(result, fromRect: inputImage.extent())
        var returnImage = UIImage(CGImage: cgImage)
        
        return returnImage!
    }
}
