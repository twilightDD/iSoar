//
//  NearbyGliderAnnotation.swift
//  Glider Tool
//
//  Created by Peter Hauke on 25.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

import Mapbox

class NearbyGliderAnnotaion: MGLPointAnnotation {
    var gliderTelemetryData: GliderTelemetryData

    required init(gliderTelemetryData: GliderTelemetryData) {
        self.gliderTelemetryData = gliderTelemetryData

        super.init()

        self.title = gliderTelemetryData.flarmID
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
