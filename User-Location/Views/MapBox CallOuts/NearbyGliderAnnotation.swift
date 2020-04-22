//
//  NearbyGliderAnnotation.swift
//  Glider Tool
//
//  Created by Peter Hauke on 25.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

import UIKit

import Mapbox

class NearbyGliderAnnotation: MGLPointAnnotation {
    weak var annotationView: NearbyGliderAnnotationView? {
        didSet {
            var nearbyGliderImageName = "\(gliderTelemetryData.type)"

            switch gliderTelemetryData.verticalPosition {
                case .above:
                    nearbyGliderImageName.append("above")
                case .below:
                    nearbyGliderImageName.append("below")
                case .unknown:
                    break
            }
            annotationView?.aircraftImage = UIImage(named: nearbyGliderImageName)
        }
    }

    private var gliderTelemetryDataStore: GliderTelemetryData
    var gliderTelemetryData: GliderTelemetryData {
        get {
            let store = gliderTelemetryDataStore
            return store
        }
        set {
            gliderTelemetryDataStore = newValue

            // set coordinates on MGLPointAnnotation for update postion on map
            coordinate = gliderTelemetryDataStore.location
            if let annotationView = self.annotationView {
                if gliderTelemetryDataStore.aircraftImageNeedsUpdate == true {
                    // update aircraft image (must be before update heading!)
                    var nearbyGliderImageName = "\(gliderTelemetryData.type)"
                    switch gliderTelemetryData.verticalPosition {
                        case .above:
                            nearbyGliderImageName.append("above")
                        case .below:
                            nearbyGliderImageName.append("below")
                        case .unknown:
                            break
                    }

                    annotationView.aircraftImage = UIImage(named: nearbyGliderImageName)
                }
                // update heading
                annotationView.heading = gliderTelemetryData.heading
            }
        }
    }
    
    required init(gliderTelemetryData: GliderTelemetryData) {
        self.gliderTelemetryDataStore = gliderTelemetryData
        
        super.init()
        
        self.title = gliderTelemetryData.flarmID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
