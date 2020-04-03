//
//  GliderUserLocationAnnotationView.swift
//  Glider Tool
//
//  Created by Newcomer on 05.07.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import Mapbox

// MARK: - GliderUserLocationAnnotationView
class GliderUserLocationAnnotationView: MGLUserLocationAnnotationView {

    // MARK: - Lets and Vats
    lazy var gliderLayer: CALayer? = setupGliderLayer()
    
    // MARK: - Overrides
    override func update() {
        if frame.isNull {
            fatalError("frame isNull")
        }
        
        rotateGliderLayer()
    }
    
    // MARK: - Private Methods
    private func setupGliderLayer () -> CALayer? {
        let gliderLayer = CALayer()
        guard let gliderImage = UIImage(named: "glider")?.cgImage
            else { return nil }
        gliderLayer.contents = gliderImage
        gliderLayer.bounds = CGRect(x: 0, y: 0, width: gliderImage.width, height: gliderImage.height)
        self.layer.addSublayer(gliderLayer)
        
        return gliderLayer
    }

    // Rotate User Location image depending of course.
    private func rotateGliderLayer() {
        guard let gliderLayer = self.gliderLayer
            else { return }
        guard let course = LocationManager.currentLocation?.course
            else { return }

        /* Get the difference between the map’s current direction and the user’s heading,
         then convert it from degrees to radians. */
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
