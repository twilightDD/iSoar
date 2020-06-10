//
//  FlightComputer.swift
//  Glider Tool
//
//  Created by sonic on 09.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreLocation
import AVFoundation

// MARK: - Protocol - FlightComputerDelegate
protocol FlightComputerDelegate: AnyObject {
    
    func gliderflies(_ isFlying: Bool)
    
}

// MARK: - FlightComputer
class FlightComputer {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = FlightComputer()
    
    // Private
    private var isGliderFlying: Bool = false {
        didSet {
            delegate?.gliderflies(isGliderFlying)
        }
    }
    private var isGliderCircling: Bool = false
    
    private var leftTurnCounter: Int = 0
    private var rightTurnCounter: Int = 0
    private var straightCounter: Int = 0
    
    private var shouldPlayGearWarning = true
    private var shouldPlayOxygenWarning = true
    
    private var alreadyWarnedFlarmIDs: Set<String> = []
    
    private var selectedDestinationAirport: AirportDatabase.Airport?
    
    // MARK: - Delegate
    private weak var delegate: FlightComputerDelegate?
    
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
            
            // TODO: 20200518 Ist das hier richtig? Und Unregister?
            OGNSocketConnectionManager.registerForSocketUpdates(shared)
            
            return isGliderFlying
            
    }
    
    class func selectedDestinationAirport()
        -> AirportDatabase.Airport? {
            let destinationAirport = shared.selectedDestinationAirport
            return destinationAirport
    }
    
    class func setSelectedDestinationAirport(_ airport: AirportDatabase.Airport?) {
        let shared = FlightComputer.shared
        shared.selectedDestinationAirport = airport
    }
    
    class func setDelegate(_ delegate: FlightComputerDelegate) {
        let shared = FlightComputer.shared
        shared.delegate = delegate
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
                //FlightRecorder.startRecording()
                
                // Register at OGNSocketConnectionManager
                OGNSocketConnectionManager.registerForSocketUpdates(self)
            }
        } else {
            // Check if Glider is slower than 10m/s, (Presets)
            // TODO: GitHub Issue 32: https://github.com/dlpgithub/iSoar/issues/32
            if let currentLocation = LocationManager.currentLocation(),
                currentLocation.speed < Presets.FlightComputer.minimalFlightSpeed
                    && currentLocation.speed > 0 {
                
                // Set gliderIsFlying to false
                isGliderFlying = false
                
                // Stop FlightRecording
                //FlightRecorder.stopRecording()
                
                // Unregister at OGNSocketConnectionManager
                OGNSocketConnectionManager.unregisterForSocketUpdates(self)
            }
        }
        
    }
    
    // Check if Glider is circling
    private func checkIfGliderIsCircling() {
        // If Centering Help Switch is on - State true
        
        guard UserDefaultsManager.centeringHelpState() == true,
            let currentLocation = LocationManager.currentLocation(),
            let formerLocation = LocationManager.formerLocation()
            else { return }
        
        // If current Course < than former Course - Glider turns left
        if currentLocation.course < formerLocation.course - Presets.FlightComputer.significantCourseDeviation {
            
            leftTurnCounter += 1
            if leftTurnCounter > Presets.FlightComputer.turnCounterResetTrigger {
                rightTurnCounter = 0
                straightCounter = 0
                //print("Left Turn: Set Right & Straight to: 0")
            }
            
            // If current Course > than former Course - Glider turns right
        } else if currentLocation.course > formerLocation.course + Presets.FlightComputer.significantCourseDeviation {
            
            rightTurnCounter += 1
            if rightTurnCounter > Presets.FlightComputer.turnCounterResetTrigger {
                leftTurnCounter = 0
                straightCounter = 0
                //print("Right Turn: Set Left & Straight to: 0")
            }
            // If current Course Change < than significantCourseDeviation - Glider flys straight
        } else {
            straightCounter += 1
            if straightCounter > Presets.FlightComputer.turnCounterResetTrigger {
                leftTurnCounter = 0
                rightTurnCounter = 0
                //print("Straight: Set Left & Right to: 0")
            }
            
        }
        
        if leftTurnCounter > Presets.FlightComputer.continousSignificantCourseChanges && isGliderCircling == false ||
        rightTurnCounter > Presets.FlightComputer.continousSignificantCourseChanges && isGliderCircling == false {
            isGliderCircling = true
            MapScreenViewController.increaseZoomLevel()

        } else if leftTurnCounter == 0 && rightTurnCounter == 0 && isGliderCircling == true {
            isGliderCircling = false
            MapScreenViewController.decreaseZoomLevel()

        } else {
            //print("Nothing to do here")
        }
        
    }
    
    // MARK: Check Warning Methods
    // Check for Gear Warning
    private func checkForGearWarning() {
        guard let selectedDestinationAirport = FlightComputer.selectedDestinationAirport(),
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
        checkIfGliderIsFlying()
        checkIfGliderIsCircling()
        checkForGearWarning()
        checkForOxygenWarning()
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
