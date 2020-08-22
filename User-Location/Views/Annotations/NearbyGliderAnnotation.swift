//
//  NearbyGliderAnnotation.swift
//  Glider Tool
//
//  Created by Peter Hauke on 25.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Mapbox

class NearbyGliderAnnotation: MGLPointAnnotation {
    weak var annotationView: NearbyGliderAnnotationView? {
        didSet {
            var nearbyAircraftImageName = "\(gliderTelemetryData.aircraftType)"

            switch gliderTelemetryData.verticalPosition {
            case .above:
                nearbyAircraftImageName.append("above")
            case .below:
                nearbyAircraftImageName.append("below")
            case .unknown:
                break
            }
            annotationView?.aircraftImage = UIImage(named: nearbyAircraftImageName)
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

            // Set Coordinates on MGLPointAnnotation for update Postion on Map
            coordinate = gliderTelemetryDataStore.location
            if let annotationView = self.annotationView {
                if gliderTelemetryDataStore.aircraftImageNeedsUpdate == true {
                    // Update Aircraft Image (must be before update heading!)
                    var nearbyAircraftImageName = "\(gliderTelemetryData.aircraftType)"
                    switch gliderTelemetryData.verticalPosition {
                    case .above:
                        nearbyAircraftImageName.append("above")
                    case .below:
                        nearbyAircraftImageName.append("below")
                    case .unknown:
                        break
                    }

                    annotationView.aircraftImage = UIImage(named: nearbyAircraftImageName)
                }
                // update heading
                annotationView.heading = gliderTelemetryData.heading
            }
        }
    }
    
    required init(gliderTelemetryData: GliderTelemetryData) {
        self.gliderTelemetryDataStore = gliderTelemetryData
        
        super.init()

        if let buddy = Buddy.forFlarmID(gliderTelemetryData.flarmID) {
            title = buddy.name
        } else {
            title = gliderTelemetryData.flarmID
        }

        var subtitleString1 = String(format: "%.0fm | ", (gliderTelemetryData.altitude))
        let subtitleString2 = String(format: "%.1fm", (gliderTelemetryData.climbRate))
        
        subtitleString1.append(subtitleString2)
        
        self.subtitle = subtitleString1
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
