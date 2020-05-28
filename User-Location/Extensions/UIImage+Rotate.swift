//
//  UIImage+Rotate.swift
//  Glider Tool
//
//  Created by sonic on 24.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

// MARK: - UIimage Rotate Extension
extension UIImage {
    func rotate(course: Double) -> UIImage? {
        let radians = course * Double.pi / 180
        return self.rotate(radians: radians)
    }
    
    func rotate(radians: Double) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        return newImage
    }
}
