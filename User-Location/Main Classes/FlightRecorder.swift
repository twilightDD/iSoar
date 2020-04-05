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
    // Statics
    static private let shared = FlightRecorder()

    // Private
    private var canRecordFlight = false

    private var flightUUIDString = UUID().uuidString
    private var flightStartDate = Date()
    private var flightEndDate = Date()
    private var startICAO: String?
    private var endICAO: String?

    // MARK: - Public Class Methods
    class func startRecording() {
        LocationManager.registerForLocationUpdates(shared)

        shared.startRecording()
    }
    
    class func stopRecording() {
        shared.stopRecording()

        LocationManager.unRegisterForLocationUpdates(shared)
    }

    // MARK: - Private Methods
    private func startRecording() {
        flightUUIDString = UUID().uuidString
        flightStartDate = Date()
        startICAO = AirportDatabase.icaoOfNearestAirport()

        let createFlightRecorderFiles = ISoarFileManager.createFlightRecorderFiles(flightUUIDString: flightUUIDString,
                                                                                   flightStartDate: flightStartDate,
                                                                                   startICAO: startICAO)
        canRecordFlight = createFlightRecorderFiles
    }

    private func stopRecording() {
        flightEndDate = Date()
        endICAO = AirportDatabase.icaoOfNearestAirport()

        ISoarFileManager.closeFlightRecorderFiles(flightUUIDString: flightUUIDString,
                                                  flightStartDate: flightStartDate,
                                                  flightEndDate: flightEndDate,
                                                  startICAO: startICAO,
                                                  endICAO: endICAO)

        canRecordFlight = false
    }

    private func addFlightRecorderEntryForLocation(_ currentLocation: CLLocation) {

        if FlightComputer.isGliderFlying() == true,
            canRecordFlight == true {
            // Prepare Data for FlightRecorder File
            let unixTimeStamp = Date.currentUnixTimeStamp
            let recordLine = String()
                .appending("\(unixTimeStamp),")
                .appending("\(currentLocation.coordinate.latitude),")
                .appending("\(currentLocation.coordinate.longitude),")
                .appending("\(currentLocation.altitude),")
                .appending("\(currentLocation.speed),")
                .appending("\(currentLocation.course),")
                .appending("\n")

            // Append Data to FlightRecorder File
            ISoarFileManager.appendTelemetryDataToFlightRecorderFile(recordLine)
        }

    }

}

// MARK: - Extension - LocationManagerDelegate
extension FlightRecorder: LocationManagerDelegate {
    func locationManager(didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last // Alternativ: LocationManager.currentLocation
            else { return }
        addFlightRecorderEntryForLocation(currentLocation)
    }

}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D)
        -> Bool {
            return lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
    }
}
