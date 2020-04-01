//
//  NearbyGliderAnnotation.swift
//  Glider Tool
//
//  Created by Peter Hauke on 25.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

import Mapbox

class NearbyGliderAnnotation: MGLPointAnnotation {
    weak var annotationView: NearbyGliderAnnotationView?

    private var gliderTelemetryDataStore: GliderTelemetryData
    var gliderTelemetryData: GliderTelemetryData {
        get {
            let store = gliderTelemetryDataStore
            return store
        }
        set {
            gliderTelemetryDataStore = newValue

            coordinate = gliderTelemetryDataStore.location

            if let annotationView = self.annotationView {
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
