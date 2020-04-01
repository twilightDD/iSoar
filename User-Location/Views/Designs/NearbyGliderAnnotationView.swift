//
//  NearbyGliderAnnotationView.swift
//  Glider Tool
//
//  Created by Peter Hauke on 02.04.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import Mapbox

// MARK: - NearbyGliderAnnotationView
class NearbyGliderAnnotationView: MGLAnnotationView {
    
    // MARK: Lets and Vars
    private var headingStore: Double = 0
    var heading: Double {
        get {
            let head = headingStore
            return head
        }
        set {
            headingStore = newValue
            
            // Rotate image depending on heading of glider
            let rotation: CGFloat = MGLRadiansFromDegrees(heading)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
            CATransaction.commit()
            
        }
    }
    
    // MARK: - Init&Co
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        if let nearbyGliderAnnotation = annotation as? NearbyGliderAnnotation {
            nearbyGliderAnnotation.annotationView = self
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Layout Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let gliderImage = UIImage(named: "nearbyGlider")?.cgImage
            else { return }
        
        layer.contents = gliderImage
        layer.bounds = CGRect(x: 0, y: 0, width: gliderImage.width, height: gliderImage.height)
    }
    
}
