//
//  Presets.swift
//  Glider Tool
//
//  Created by Peter Hauke on 01.04.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Network
import CoreLocation
import UIKit

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
        /// Represents the App Version
        static let appVersion: String = "iSoar \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")_\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")"
        /// Timespan of Expiration of Nearby Aircrafts Telemetry Data - and removing from Map
        static let telemetryDataExpirationTimespan: Int64 = 120
        /// Distance from Login Location to Reconnect Location
        static let distanceLimitForReconnect: Double = 10000
        
    }
    
    struct MapScreen {
        
        static let eulaText: String = "You are not allowed to use this software as your primary navigation system.\n\nThe data provided in this app may be incorrect or incomplete.\n\nThis software may only be used as an additional backup to your currently valid ICAO card.\n\nBy using this app in the mobile network, costs may arise from your mobile operator."
        
    }
    
    struct FlightComputer {
        
        /// Check for nearest Airport and set it for Start-Airport and End-Airport in the LogBook
        static let maximalDistanceFromNearestAirport: CLLocationDistance = 500
        
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
        static let gearWarningSpokenText: String = "Warning, check Landing Gear"
        
        // Collision Warning
        /// Represents the distance Limit of Nearby Gliders in which the user is warned
        static let horizontalCollisionWarningDistance: CLLocationDistance = 2000
        /// Represents the distance Limit of Nearby Gliders above or below me in which the user is warned
        static let verticalCollisionWarningDistance: CLLocationDistance = 200
        /// Represents the spoken Text of the acoustic Warning
        static let collisionWarningSpokenText: String = "Warning, Traffic ahead"
        
        // Centering Help
        /// Represents the deviation of the current course to the former course
        static let significantCourseDeviation: Double = 3
        /// Represents how many continous significant Course Changes must be recognized to set "Circling" to true
        static let continousSignificantCourseChanges: Int = 15
        /// Represents the value of continous Courses  Updates to another Direction than the last cirling Turn
        static let turnCounterResetTrigger: Int = 7
        
    }
    
    struct AirportDatabase {
        
        /// Represents the URL of the Airports.json File on the Server
        static let airportsJSONFileURL = URL(string: "https://www.isoar.de/_b13/Airports.json")
        
    }
    
    struct Settings {
        
        /// Represents the the MapBox Style URL - Key Value Pair - Country : StyleURL
        static let countries = ["Austria": "mapbox://styles/dlmapbox/ckecnz3gl2en51amvmz2zr9nd",
                                "Belgium": "mapbox://styles/dlmapbox/ckecp85kk0bcq19p527u2poup",
                                "Bulgaria": "mapbox://styles/dlmapbox/cked4x4912v1e1anvelby5at2",
                                "Croatia": "mapbox://styles/dlmapbox/cked60k1o2w2k19qytp74kf8d",
                                "Denmark": "mapbox://styles/dlmapbox/ckecrvjox0fsv19mh1yb3mp1q",
                                "Finland": "mapbox://styles/dlmapbox/ckecpy9jc2gbk19mx1zy46xb0",
                                "Germany": "mapbox://styles/dlmapbox/cka5rqao21e0z1iqisptn1fwt",
                                "Italy": "mapbox://styles/dlmapbox/ckecoq7k81yw719kijd8f1m6w",
                                "Netherlands": "mapbox://styles/dlmapbox/ckecq6au02gpp19mjk98tbg0u",
                                "Poland": "mapbox://styles/dlmapbox/ckecso9mw1vgs19obtw0skrai",
                                "Romania": "mapbox://styles/dlmapbox/ckeduxe5t0av019rkf2vjm9uh",
                                "Slovenia": "mapbox://styles/dlmapbox/ckedatk3n0hza19ryhj79muzi",
                                "Sweden": "mapbox://styles/dlmapbox/ckecuue8m2l8c1amv1bqakkdf",
                                "Switzerland": "mapbox://styles/dlmapbox/ckeco8can24b019o0cw384tx7"
        ]
        
        /// Represents the URL of the Manual on the Server
        static let maualURL = URL(string: "https://www.isoar.de/handbuch")
        
    }
}
