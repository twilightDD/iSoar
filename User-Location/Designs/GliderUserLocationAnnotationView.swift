//
//  GliderUserLocationAnnotationView.swift
//  Glider Tool
//
//  Created by Newcomer on 05.07.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import Mapbox

// Create a subclass of MGLUserLocationAnnotationView.
class GliderUserLocationAnnotationView: MGLUserLocationAnnotationView {
    let size: CGFloat = 48
    lazy var gliderLayer: CALayer = {
        let gliderLayer = CALayer()
        gliderLayer.contents = UIImage(named: "glider")?.cgImage
        gliderLayer.bounds = CGRect(x: 0, y: 0, width: self.size, height: self.size)
        self.layer.addSublayer(gliderLayer)
        
        return gliderLayer
    }()
    
    
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }
        
        rotateGliderImage()
    }
    

    /// Rotate User Location image depending of course.
    private func rotateGliderImage() {
        guard let course = MapScreen.shared!.currentLocation?.course
            else { return }
        
        // arrow.isHidden = false
        
        // Get the difference between the map’s current direction and the user’s heading, then convert it from degrees to radians.
        let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - course)
        
        // If the difference would be perceptible, rotate the arrow.
        if abs(rotation) > 0.01 {
            // Disable implicit animations of this rotation, which reduces lag between changes.
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gliderLayer.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
            CATransaction.commit()
        }
    }
}
