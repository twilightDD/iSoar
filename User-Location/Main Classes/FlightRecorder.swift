//
//  FlightRecorder.swift
//  Glider Tool
//
//  Created by sonic on 14.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import CoreLocation

// MARK: - FlightRecorder
class FlightRecorder {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = FlightRecorder()
    
    // Private
    private var canRecordFlight = false
    
    private var currentUnixTimeStamp = String.init(Date.currentUnixTimeStamp)
    private var flightStartDate = Date()
    private var startICAO: String?
    
    // MARK: - Public Class Methods
    class func setup() {
        let shared = FlightRecorder.shared
        FlightComputer.registerForFlightComputerUpdates(shared)
    }
    
    // MARK: - Private Methods
    // Start Recording of Telemetry Data
    private func startRecording() {
        currentUnixTimeStamp = String.init(Date.currentUnixTimeStamp)
        flightStartDate = Date()
        startICAO = icaoOfNearestAirportWithinMaximalDistance()
        
        let createFlightRecorderFiles = ISoarFileManager.createFlightRecorderFiles(currentUnixTimpStamp: currentUnixTimeStamp,
                                                                                   flightStartDate: flightStartDate,
                                                                                   startICAO: startICAO)
        canRecordFlight = createFlightRecorderFiles
    }
    
    // Stop Recording of Telemetry Data
    private func stopRecording() {
        let flightEndDate = Date()
        let endICAO = icaoOfNearestAirportWithinMaximalDistance()
        
        ISoarFileManager.closeFlightRecorderFiles(currentUnixTimeStamp: currentUnixTimeStamp,
                                                  flightStartDate: flightStartDate,
                                                  flightEndDate: flightEndDate,
                                                  startICAO: startICAO,
                                                  endICAO: endICAO)
        
        canRecordFlight = false
    }
    
    // Append Telemetry Data to FlightRecorder File
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
            
            // Append Telemetry Data to FlightRecorder File
            ISoarFileManager.appendTelemetryDataToFlightRecorderFile(recordLine)
        }
        
    }
    
    // Returns the ICAO Code of the nearest Airport
    private func icaoOfNearestAirportWithinMaximalDistance()
    -> String? {
        if let nearestAirport = FlightComputer.nearestAirport(),
           let distance = LocationManager.distanceFromCurrentLocationTo(location: nearestAirport.location) {
            if distance <= Presets.FlightComputer.maximalDistanceFromNearestAirport {
                return nearestAirport.icao
            }
        }
        
        return nil
    }
    
}

// MARK: - Extensions
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D)
        -> Bool {
            return lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
    }
}

extension FlightRecorder: LocationManagerDelegate {
    func locationManager(didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }
        addFlightRecorderEntryForLocation(currentLocation)
    }
    
}

extension FlightRecorder: FlightComputerDelegate {
    func gliderIsFlying(_ isFlying: Bool) {
        if isFlying == true {
            LocationManager.registerForLocationUpdates(FlightRecorder.shared)
            startRecording()
        } else {
            stopRecording()
            LocationManager.unRegisterForLocationUpdates(FlightRecorder.shared)
        }
    }
    
}
