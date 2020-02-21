//
//  FlightRecorder.swift
//  Glider Tool
//
//  Created by sonic on 14.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - FlightRecorder
class FlightRecorder {

    // MARK: - Lets and Vars
    static let shared = FlightRecorder()

    var recorderIsReadyToWrite = false

    // MARK: - Public Methods
    // Add Current Location Infos to FlightRecorder File
    func addFlightRecorderEntryForLocation(_ currentLocation: CLLocation) {

        let locationCoordinate2D = CLLocationCoordinate2D.init(latitude: currentLocation.coordinate.latitude,
                                                               longitude: currentLocation.coordinate.longitude)

        let currentTelemetryData = FlightData(unixTimeStamp: Date.currentTimeStamp,
                                    latitude: currentLocation.coordinate.latitude,
                                    longitude: currentLocation.coordinate.longitude,
                                    locationCoordinate2D: locationCoordinate2D,
                                    altitude: currentLocation.altitude,
                                    speed: currentLocation.speed,
                                    course: currentLocation.course)

        // Write Data to FlightRecorder File
        FlightComputer.shared.checkIfGliderIsFlying()
        if recorderIsReadyToWrite == true {
            // Prepare Data for FlightRecorder File
            var recordLine = ""
            recordLine.append(contentsOf: "\(currentTelemetryData.unixTimeStamp),")
            recordLine.append(contentsOf: "\(locationCoordinate2D.latitude),")
            recordLine.append(contentsOf: "\(locationCoordinate2D.longitude),")
            recordLine.append(contentsOf: "\(currentLocation.altitude),")
            recordLine.append(contentsOf: "\(currentLocation.speed),")
            recordLine.append(contentsOf: "\(currentLocation.course),")
            recordLine.append(contentsOf: "\n")

            // Append Data to FlightRecorder File
            ISoarFileManager.appendTelemetryDataToFlightRecorderFile(recordLine)
        }

    }

}

// MARK: - Extentsion - Structs and Enums
extension FlightRecorder {

    struct FlightData: Equatable {
        // MARK: Lets and Vars
        var unixTimeStamp: Int64
        var latitude: Double
        var longitude: Double
        var locationCoordinate2D: CLLocationCoordinate2D
        var altitude: Double
        var speed: Double
        var course: Double
    }

}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D)
        -> Bool {
            return lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
    }
}

// Unix Date Extension
extension Date {
    static var currentTimeStamp: Int64 {return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
