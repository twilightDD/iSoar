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
    // Statics
    static private let shared = FlightComputer()

    // Private
    private var isGliderFlying: Bool = false

    private var shouldPlayGearWarning = true
    private var shouldPlayOxygenWarning = true

    // MARK: - Public Class Methods
    class func start() {
        let shared = FlightComputer.shared
        LocationManager.registerForLocationUpdates(shared)
    }

    class func stop() {
        let shared = FlightComputer.shared
        LocationManager.unRegisterForLocationUpdates(shared)
    }

    class func isGliderFlying()
        -> Bool {
            let isGliderFlying = shared.isGliderFlying
            return isGliderFlying
    }

    // MARK: - Private Instance Methods
    private func checkIfGliderIsFlying() {
        if isGliderFlying == false {

            // Check if Glider is faster than 10m/s, then set gliderIsFlying to true and start FlightRecording
            if let currentLocation = LocationManager.currentLocation(),
                currentLocation.speed > Presets.FlightComputer.minimalFlightSpeed {

                isGliderFlying = true

                FlightRecorder.startRecording()
            }
        } else {
            // Check if Glider is slower than 10m/s, then set FlightMode to false
            if let currentLocation = LocationManager.currentLocation(),
                currentLocation.speed < Presets.FlightComputer.minimalFlightSpeed {

                isGliderFlying = false

                FlightRecorder.stopRecording()
            }
        }
        
    }

    // MARK: Check Warning Methods
    private func checkForGearWarning() {
        guard let selectedDestinationAirport = DestinationSelectionViewController.destinationAirport(),
            let currentLocation = LocationManager.currentLocation(),
            let currentDistance = DestinationSelectionViewController.distanceToDestinationAirport()
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

    private func collisionWarning() {
        // Check if Glider is flying / If false we dont need to warn
        if isGliderFlying == true {
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
        checkForOxygenWarning()
        checkIfGliderIsFlying()
    }

}
