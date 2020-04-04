//
//  FlightComputer.swift
//  Glider Tool
//
//  Created by sonic on 09.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

// MARK: - FlightComputer
class FlightComputer {

    // MARK: - Lets and Vars
    static let shared = FlightComputer()

    private var gliderIsFlying: Bool = false
    
    private(set) var flightUUIDString = UUID().uuidString
    private(set) var flightStartTime = Date()
    private(set) var flightEndTime = Date()
    private(set) var startICAO: String?
    private(set) var endICAO: String?


    private var shouldPlayGearWarning = true
    private var shouldPlayOxygenWarning = true


    // MARK: - Init&CO.
     init() {
        print("FlightComputer init")
        LocationManager.registerForLocationUpdates(self)
    }


    // MARK: - Public Methods
    // Check if Glider is flying or on ground
    func checkIfGliderIsFlying() {
        if gliderIsFlying == false {

            // Check if Glider is faster than 10m/s, then set FlightMode to true
            if let currentLocation = LocationManager.currentLocation(),
                currentLocation.speed > Presets.FlightComputer.minimalFlightSpeed {

                gliderIsFlying = true
                flightUUIDString = UUID().uuidString
                flightStartTime = Date()
                startICAO = icaoOfNearestAirport()
                
                // Create FlightRecorder Files
                FlightRecorder.shared.recorderIsReadyToWrite = ISoarFileManager.createFlightRecorderFiles()
            }
        }
        else {
            // Check if Glider is slower than 10m/s, then set FlightMode to false
            if let currentLocation = LocationManager.currentLocation(),
                currentLocation.speed < Presets.FlightComputer.minimalFlightSpeed {

                gliderIsFlying = false
                flightEndTime = Date()
                endICAO = icaoOfNearestAirport()

                // Close FlightRecorder Files
                ISoarFileManager.closeFlightRecorderFiles()
                FlightRecorder.shared.recorderIsReadyToWrite = false
            }
        }
        
    }


    // MARK: - Private Methods
    // Check for nearest Aiport
    private func icaoOfNearestAirport()
        -> String? {
            // Update Distance from current Location to all Airports in Database
            AirportDatabase.shared.updateDistance()
            
            if let nearestAirport = AirportDatabase.shared.nearestAirport(),
                (nearestAirport.distance ?? Presets.FlightComputer.minimalDistanceForNearestAirport + 1) < Presets.FlightComputer.minimalDistanceForNearestAirport {
                return nearestAirport.icao
            }
            return nil
    }
    
    // MARK: - Check Warning Methods
    private func checkForGearWarning() {
        guard let selectedDestinationAirport = DestinationSelectionViewController.destinationAirport(),
            let currentLocation = LocationManager.currentLocation(),
            let currentDistance = LocationManager.currentDistance()
            else { return }

        let gearWarningSwitch = UserDefaultsManager.gearWarningState()
        if gearWarningSwitch == true {

            let upperGearWarningAltitude = selectedDestinationAirport.elevation + Presets.FlightComputer.upperGearWarningAltitude
            let lowerGearWarningAltitude = selectedDestinationAirport.elevation + Presets.FlightComputer.lowerGearWarningAltitude

            let distanceWarningNeeded = currentDistance < Presets.FlightComputer.gearWarningDistance
            let upperWarningNeeded = currentLocation.altitude < upperGearWarningAltitude
            let lowerWarningNeeded = currentLocation.altitude > lowerGearWarningAltitude

            if distanceWarningNeeded == true,
                upperWarningNeeded == true,
                lowerWarningNeeded == true {
                
                if shouldPlayGearWarning == true {
                    speak(string: "Check Gear")
                    shouldPlayGearWarning = false
                }
            } else {
                shouldPlayGearWarning = true
            }

        }
    }
    
    // Audio for Oxygen Level Warning
    private func checkForOxygenWarning() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }

        let oxygenWarningNeeded = currentLocation.altitude > Presets.FlightComputer.oxygenWarningAltitude
        if oxygenWarningNeeded == true {
            if shouldPlayOxygenWarning == true {
                speak(string: "Check Oxygen Level")
                shouldPlayOxygenWarning = false
            }
        } else {
            shouldPlayOxygenWarning = true
        }
    }

    // Collision Warning

    private func collisionWarning() {
        // Check if Glider is flying / If false we dont need to warn
        if gliderIsFlying == true {
            // Check if Collision Warning Switch is on / If false we dont need to warn
            let collisionWarningSwitch = UserDefaultsManager.collisionWarningState()
            if collisionWarningSwitch == true {
                speak(string: "Warning, Traffic ahead")

            } else {
                // Collision Warning Switch is on
            }
            
        } else {
            // Glider not flying
        }
    }


    // MARK: Audio Methods
    private func speak(string: String) {
        AudioServicesPlayAlertSound(SystemSoundID(1256))

        let speechUtterance = AVSpeechUtterance(string: string)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechUtterance.rate = 0.5

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(speechUtterance)
    }

}


// MARK: - Extension - LocationManagerDelegate
extension FlightComputer: LocationManagerDelegate {

    func locationManager(didUpdateLocations locations: [CLLocation]) {
        checkForGearWarning()

        // Oxygen Warning
        checkForOxygenWarning()

    }

}
