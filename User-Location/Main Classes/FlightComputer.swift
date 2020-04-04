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


    private var playGearWarning = true
    private var playOxygenWarning = true


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
    
    // MARK: - Audio Warnings
    // TODO: make private - why should MapScreenViewController call this method? 04042020, ph
    func gearWarning() {
        guard let selectedDestinationAirport = DestinationSelectionViewController.destinationAirport(),
            let currentLocation = LocationManager.currentLocation(),
            let currentDistance = LocationManager.currentDistance()
            else { return }

        let gearWarningSwitch = UserDefaultsManager.gearWarningState()
        if gearWarningSwitch == true {

            let distanceInKm = currentDistance / 1000
            let upperGearWarningAltitude = selectedDestinationAirport.elevation + Presets.FlightComputer.upperGearWarningAltitude
            let lowerGearWarningAltitude = selectedDestinationAirport.elevation + Presets.FlightComputer.lowerGearWarningAltitude
            
            if distanceInKm < 1
                && (currentLocation.altitude < upperGearWarningAltitude
                    && currentLocation.altitude > lowerGearWarningAltitude) {
                
                if playGearWarning == true {
                    AudioServicesPlayAlertSound(SystemSoundID(1256))
                    
                    let utterance = AVSpeechUtterance(string: "Check Gear")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    utterance.rate = 0.5
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                    
                    playGearWarning = false
                } else {
                    playGearWarning = true
                }
            }

        }
    }
    
    // Audio for Oxygen Level Warning
    // TODO: make private - why should MapScreenViewController call this method? 04042020, ph
    func oxygenWarning() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }

        if currentLocation.altitude > 3500 {

            if playOxygenWarning == true {
                AudioServicesPlayAlertSound(SystemSoundID(1256))

                let utterance = AVSpeechUtterance(string: "Check Oxygen Level")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)

                playOxygenWarning = false
            } else {
                playOxygenWarning = true
            }
        }
    }

    // Collision Warning

    private func collisionWarning() {
        // Check if Glider is flying / If false we dont need to warn
        if gliderIsFlying == true {
            // Check if Collision Warning Switch is on / If false we dont need to warn
            let collisionWarningSwitch = UserDefaultsManager.collisionWarningState()
            if collisionWarningSwitch == true {
                AudioServicesPlayAlertSound(SystemSoundID(1256))
                
                let utterance = AVSpeechUtterance(string: "Warning, Traffic ahead")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            } else {
                // Collision Warning Switch is on
            }
            
        } else {
            // Glider not flying
        }
    }

}


extension FlightComputer: LocationManagerDelegate {

    func locationManager(didUpdateLocations locations: [CLLocation]) {
        gearWarning()

        // Oxygen Warning
        oxygenWarning()

    }

}
