//
//  Presets.swift
//  Glider Tool
//
//  Created by Peter Hauke on 01.04.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import Network
import CoreLocation

struct Presets {

    static func printPresetsWaringsIfNeeded() {
        #if DEBUG
        print("#######################")
        print("")
        print("USES DIFFERENT PRESETS FOR DEBUGGING")
        print("")
        print("#######################")
        #endif
    }

    struct OGNSocketConnection {

        /// Base URL String for aprs.glidernet.org
        static let host: NWEndpoint.Host = "aprs.glidernet.org"
        /// May not use any filter options.
        static let hostPort: NWEndpoint.Port = 10152
        /// For using filtered requests.
        static let hostPortFiltered: NWEndpoint.Port = 14580

        static let appVersion: String = "iSoar \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")_\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")"

        #if DEBUG
        /// Default Radius für NearbyGlider (for debug purpose)
        static let regionInKm: Double = 500
        #else
        /// Default Radius für NearbyGlider
        static let regionInKm: Double = 50
        #endif
    }
    
    struct MapScreen {

        #if DEBUG
        /// Default Radius für MapScreen ZoomLevel (for debug purpose)
        static let zoomLevel: Double = 5
        #else
        /// Default Radius für MapScreen ZoomLevel
        static let zoomLevel: Double = 9.6
        #endif
    }
    
    struct FlightComputer {

        /// Check for nearest Airport and set it for Start-Airport and End-Airport in the LogBook
        static let maximalDistanceFromNearestAirport: CLLocationDistance = 300

        /// Minimal Speed in Meter per Seconds to check if Glider is flying or not
        static let minimalFlightSpeed: CLLocationSpeed = 10

        // Oxygen Warning
        /// Represents the Oxygen Warning Altitude
        static let oxygenWarningAltitude: CLLocationDistance = 3500
        /// Represents the spoken Text of the acoustic Warning
        static let oxygenWarningSpokenText: String = "Warning, Oxygen Level low"

        // Landing Gear Warning
        /// Represents the lower distance Limit above the Airport in which user is warned
        static let gearWarningDistance: Double = 1000
        /// Represents the lower Altitude Range Limit above the Airport in which User is warned
        static let lowerGearWarningAltitude: Double = 200
        /// Represents the upper Altitude Range Limit above the Airport in which User is warned
        static let upperGearWarningAltitude: Double = 400
        /// Represents the spoken Text of the acoustic Warning
        static let gearWarningSpokenText: String = "Warning, check Gear"
        
        // Collision Warning
        /// Represents the distance Limit of Nearby Gliders in which the user is warned
        static let collisionWarningDistance: Double = 1000
        /// Represents the spoken Text of the acoustic Warning
        static let collisionWarningSpokenText: String = "Warning, Traffic ahead"

    }
    
}
