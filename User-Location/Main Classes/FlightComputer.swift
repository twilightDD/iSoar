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
    
    private var alreadyWarnedFlarmIDs: Set<String> = []
    
    // MARK: - Public Class Methods
    class func start() {
        let shared = FlightComputer.shared
        LocationManager.registerForLocationUpdates(shared)
        
        // TODO: das ist nur zum Test hier, muss hier raus
        OGNSocketConnectionManager.registerForSocketUpdates(shared)
    }
    
    class func stop() {
        let shared = FlightComputer.shared
        LocationManager.unRegisterForLocationUpdates(shared)
    }
    
    class func isGliderFlying()
        -> Bool {
            let isGliderFlying = shared.isGliderFlying
            return isGliderFlying
            
            // TODO: Das muss dann hier rein
            //OGNSocketConnectionManager.registerForSocketUpdates(shared)
    }
    
    // MARK: - Private Instance Methods
    private func checkIfGliderIsFlying() {
        if isGliderFlying == false {
            
            // Check if Glider is faster than 10m/s, (Presets)
            if let currentLocation = LocationManager.currentLocation(),
                currentLocation.speed > Presets.FlightComputer.minimalFlightSpeed {
                
                // Set gliderIsFlying to true
                isGliderFlying = true
                
                // Start FlightRecording
                FlightRecorder.startRecording()
                
                // Register at OGNSocketConnectionManager
                OGNSocketConnectionManager.registerForSocketUpdates(self)
            }
        } else {
            // Check if Glider is slower than 10m/s, (Presets)
            if let currentLocation = LocationManager.currentLocation(),
                currentLocation.speed < Presets.FlightComputer.minimalFlightSpeed {
                
                // Set gliderIsFlying to false
                isGliderFlying = false
                
                // Stop FlightRecording
                FlightRecorder.stopRecording()
                
                // Unregister at OGNSocketConnectionManager
                OGNSocketConnectionManager.unregisterForSocketUpdates(self)
            }
        }
        
    }
    
    // MARK: Check Warning Methods
    // Check for Gear Warning
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
                    speak(string: Presets.FlightComputer.gearWarningSpokenText)
                    shouldPlayGearWarning = false
                }
            } else {
                shouldPlayGearWarning = true
            }
            
        }
    }
    
    // Check for Oxygen Warning
    private func checkForOxygenWarning() {
        guard let currentLocation = LocationManager.currentLocation()
            else { return }
        
        let oxygenWarningNeeded = currentLocation.altitude > Presets.FlightComputer.oxygenWarningAltitude
        if oxygenWarningNeeded == true {
            if shouldPlayOxygenWarning == true {
                speak(string: Presets.FlightComputer.oxygenWarningSpokenText)
                shouldPlayOxygenWarning = false
            }
        } else {
            shouldPlayOxygenWarning = true
        }
    }
    
    // TODO: 20200416 Kann ja dann auch weg
    // Check for Collision Warning
    private func checkForCollisionWarning() {
        // Check if Glider is flying / If false we dont need to warn
        if isGliderFlying == true {
            // Check if Collision Warning Switch is on / If false we dont need to warn
            let collisionWarningSwitch = UserDefaultsManager.collisionWarningState()
            if collisionWarningSwitch == true {
                speak(string: Presets.FlightComputer.collisionWarningSpokenText)
            } else {
                // Collision Warning Switch is off
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

// MARK: - Extension - DL_OGNSocketConnectionManagerDelegate
extension FlightComputer: DL_OGNSocketConnectionManagerDelegate {
    
    // Update alreadyWarnedFlarmIDs Set for specific FlarmID
    func updateNearbyGlider(gliderTelemetryData: GliderTelemetryData) {
        
        if UserDefaultsManager.collisionWarningState() == true {
            
            // If Nearby Glider IS in Collision Range AND NOT yet in the SET
            if gliderTelemetryData.isInCollisionRange == true && alreadyWarnedFlarmIDs.contains(gliderTelemetryData.flarmID) == false {
                
                // Check if Nearby Gliders Speed is more than 50 Kmh - is flying
                if gliderTelemetryData.speed > 50 {
                    alreadyWarnedFlarmIDs.update(with: gliderTelemetryData.flarmID)
                    speak(string: Presets.FlightComputer.collisionWarningSpokenText)
                    
                    print("IN RANGE: \(gliderTelemetryData.flarmID) - IM SET: \(alreadyWarnedFlarmIDs.count) - Alt: \(gliderTelemetryData.altitude) - Speed: \(gliderTelemetryData.speed)")
                } else {
                    // Nearby Gliders Speed is less than 50 Kmh - not flying
                    print("In Range: but not flying: \(gliderTelemetryData.flarmID)")
                }
                
            }
            
            // If Nearby Glider IS NOT (or no more) in Collision Range BUT IN the SET
            if gliderTelemetryData.isInCollisionRange == false &&
                alreadyWarnedFlarmIDs.contains(gliderTelemetryData.flarmID) {
                
                alreadyWarnedFlarmIDs.remove(gliderTelemetryData.flarmID)
                
                print("OUT OF RANGE: \(gliderTelemetryData.flarmID) - IM SET: \(alreadyWarnedFlarmIDs.count) - Alt: \(gliderTelemetryData.altitude) - Speed: \(gliderTelemetryData.speed)")
            }
        } else {
            alreadyWarnedFlarmIDs.removeAll()
        }
    }
    
    // Remove specific FlarmID from alreadyWarnedFlarmIDs Set
    func removeNearbyGlider(gliderTelemetryData: GliderTelemetryData) {
        alreadyWarnedFlarmIDs.remove(gliderTelemetryData.flarmID)
    }
    
    // Remove all FlarmIDs from alreadyWarnedFlarmIDs Set
    func removeAllNearbyGliders() {
        alreadyWarnedFlarmIDs.removeAll()
    }
    
}
