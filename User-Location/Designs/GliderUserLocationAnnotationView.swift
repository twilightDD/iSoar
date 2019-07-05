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
    var glider: CALayer!
    
    // -update is a method inherited from MGLUserLocationAnnotationView. It updates the appearance of the user location annotation when needed. This can be called many times a second, so be careful to keep it lightweight.
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }
        
        // Check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            setupLayers()
            updateHeading()
        }
    }
    
    private func updateHeading() {
        // Show the heading arrow, if the heading of the user is available.
        if let heading = userLocation!.heading?.trueHeading {
            // arrow.isHidden = false
            
            // Get the difference between the map’s current direction and the user’s heading, then convert it from degrees to radians.
            let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)
            
            // If the difference would be perceptible, rotate the arrow.
            if abs(rotation) > 0.01 {
                // Disable implicit animations of this rotation, which reduces lag between changes.
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                glider.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
                CATransaction.commit()
            }
        }
    }
    
    private func setupLayers() {
        // This dot forms the base of the annotation.
        if glider == nil {
            glider = CALayer()
            glider.contents = UIImage(named: "glider")?.cgImage
            glider.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            layer.addSublayer(glider)
        }
    }
}
