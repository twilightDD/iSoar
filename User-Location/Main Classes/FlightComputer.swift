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
    private var isGliderCircling: Bool = false
    private var circlingCounter: Int = 0
    
    private var shouldPlayGearWarning = true
    private var shouldPlayOxygenWarning = true
    
    private var alreadyWarnedFlarmIDs: Set<String> = []
    
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

            OGNSocketConnectionManager.registerForSocketUpdates(shared)
    }
    
    class func isGliderCircling()
        -> Bool {
            let isGliderCircling = shared.isGliderCircling
            return isGliderCircling
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
    
    // TODO: 20200512 cyclomatic_complexity checken - geht es einfacher? dl
    // Check if Glider is circling
    private func checkIfGliderIsCircling() {
        if UserDefaultsManager.centeringHelpState() == true {
            if let currentLocation = LocationManager.currentLocation(),
                let formerLocation = LocationManager.formerLocation() {
                
                // Glider dreht rechts rum
                if currentLocation.course > formerLocation.course {
                    if currentLocation.course > formerLocation.course + Presets.FlightComputer.significantCourseDeviation {
                        print("DREHUNG RECHTS ERKANNT: COUNTER: \(circlingCounter)")
                        
                        if circlingCounter <= 15 {
                            if circlingCounter < 0 && circlingCounter >= -5 {
                                circlingCounter = 0
                            } else {
                                circlingCounter+=1
                            }

                            print("COUNTER RECHTS: \(circlingCounter)")
                        }
                        
                    } else {
                        print("DREHUNG RECHTS ERKANNT, ABER ZU GERING: COUNTER: \(circlingCounter)")
                        if circlingCounter >= 0 {
                            if circlingCounter <= 5 {
                                circlingCounter = 0
                            } else {
                                if circlingCounter >= -5  && circlingCounter <= 5 {
                                    circlingCounter = 0
                                } else {
                                    circlingCounter-=1
                                }
                            }
                        } else {
                            circlingCounter+=1
                        }
                        print("COUNTER RECHTS: \(circlingCounter)")
                    }
                    
                } else {
                    if currentLocation.course < formerLocation.course - Presets.FlightComputer.significantCourseDeviation {
                        print("DREHUNG LINKS ERKANNT: COUNTER: \(circlingCounter)")
                        
                        if circlingCounter >= -15 {
                            if circlingCounter > 0 && circlingCounter <= 5 {
                                circlingCounter = 0
                            } else {
                                circlingCounter-=1
                            }
                            
                            print("COUNTER LINKS: \(circlingCounter)")
                        }
                        
                    } else {
                        print("DREHUNG LINKS ERKANNT, ABER ZU GERING: COUNTER: \(circlingCounter)")
                        if circlingCounter <= 0 {
                            if circlingCounter >= -5 {
                                circlingCounter = 0
                            } else {
                                circlingCounter+=1
                            }
                        } else {
                            if circlingCounter <= 5 && circlingCounter >= -5 {
                                circlingCounter = 0
                            } else {
                                circlingCounter-=1
                            }
                        }
                        print("COUNTER LINKS: \(circlingCounter)")
                    }
                }
                
            }
            
            if circlingCounter > Presets.FlightComputer.continousSignificantCourseChanges || circlingCounter < -Presets.FlightComputer.continousSignificantCourseChanges {
                isGliderCircling = true
                print(#function, isGliderCircling)
                AudioServicesPlayAlertSound(SystemSoundID(1256))
            } else {
                isGliderCircling = false
                print(#function, isGliderCircling)
            }
            
        } else {
            // print("SWITCH IS OFF")
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
