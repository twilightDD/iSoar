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
    
    func gliderIsFlying(_ isFlying: Bool)
    
}

// MARK: - FlightComputer
class FlightComputer {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = FlightComputer()
    
    // Private
    private var isGliderFlying: Bool = false {
        didSet {
            if oldValue != isGliderFlying {
                // Inform delegates
                for delegate in delegates.allObjects {
                    if let flightComputerDelegate = delegate as? FlightComputerDelegate {
                        flightComputerDelegate.gliderIsFlying(isGliderFlying)
                        
                    }
                }
            }
        }
    }
    
    private var isGliderCircling: Bool = false
    
    private var enteredLowOxygenAltitudeTimestamp: Int64?
    
    private var leftTurnCounter: Int = 0
    private var rightTurnCounter: Int = 0
    private var straightCounter: Int = 0
    
    private var shouldPlayGearWarning = true
    private var shouldPlayOxygenWarning = true
    
    private var alreadyWarnedFlarmIDs: Set<String> = []
    
    private var selectedDestinationAirport: AirportDatabase.Airport?
    
    // MARK: - Delegate
    private var delegates = NSHashTable<AnyObject>.weakObjects()
    
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
    
    class func registerForFlightComputerUpdates(_ delegate: FlightComputerDelegate) {
        // print("\(#function) - willAdd delegates.count = \(shared.delegates.count)")
        shared.delegates.add(delegate)
        // print("\(#function) - did Add delegates.count = \(shared.delegates.count)")
    }
    
    class func unRegisterForFlightComputerUpdates(_ delegate: FlightComputerDelegate) {
        // print("\(#function) - willRemove delegates.count = \(shared.delegates.count)")
        shared.delegates.remove(delegate)
        // print("\(#function) - did Remove delegates.count = \(shared.delegates.count)")
    }
    
    // MARK: - Private Instance Methods
    private func checkIfGliderIsFlying() {
        if isGliderFlying == false {
            // Check if Glider is faster than 10m/s, (Presets)
            if let currentLocation = LocationManager.currentLocation(),
               currentLocation.speed > Presets.FlightComputer.minimalFlightSpeed {
                
                // Set gliderIsFlying to true
                isGliderFlying = true
                
                // Register at OGNSocketConnectionManager
                OGNSocketConnectionManager.registerForSocketUpdates(self)
                
                #if DEBUG
                DLLogger.writeStringToLogFile("\(#function) -> true - Flight Start detected")
                #endif
                
            }
        } else {
            // Check if Glider is slower than 10m/s, (Presets)
            if let currentLocation = LocationManager.currentLocation(),
               currentLocation.speed < Presets.FlightComputer.minimalFlightSpeed,
               currentLocation.speed > 0 {
                
                // Get Terrain elevation of current User Location
                DLTerrainElevation.currentTerrainElevation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, completion: { elevation in
                    if let currentTerrainElevation = (elevation) {
                        // If vertical Distance between Glider Altitude and Terrain Elevation is < 100m - set isGliderFlying = false
                        if currentLocation.altitude-currentTerrainElevation < 100 {
                            self.isGliderFlying = false
                            OGNSocketConnectionManager.unregisterForSocketUpdates(self)
                            
                            #if DEBUG
                            DLLogger.writeStringToLogFile("\(#function) -> false - Flight End detected")
                            #endif
                            
                        } else {
                            // If vertical Distance between Glider Altitude and Terrain Elevation is > 100m  - Nothing to do
                        }
                    } else {
                        // If we cant get the Terrain elevation we check for the distance to the nearest Airport
                        if let nearestAirport = AirportDatabase.nearestAirport(),
                           let distance = LocationManager.distanceFromCurrentLocationTo(location: nearestAirport.location()) {
                            // If Distance to nearest Airport is < 500m - set isGliderFlying = false
                            if distance < Presets.FlightComputer.maximalDistanceFromNearestAirport {
                                self.isGliderFlying = false
                                OGNSocketConnectionManager.unregisterForSocketUpdates(self)
                                
                                #if DEBUG
                                DLLogger.writeStringToLogFile("\(#function) -> false - Flight End detected")
                                #endif
                                
                            } else {
                                // If Distance to nearest Airport is > 500m - check current Altitude of Glider
                                // If Glider Altitude is < 1200 - set isGliderFlying = false
                                if currentLocation.altitude < 1200 {
                                    self.isGliderFlying = false
                                    OGNSocketConnectionManager.unregisterForSocketUpdates(self)
                                    
                                    #if DEBUG
                                    DLLogger.writeStringToLogFile("\(#function) -> false - Flight End detected")
                                    #endif
                                    
                                } else {
                                    // If Glider Altitude is > 1200 - Nothing to do
                                }
                            }
                        }
                        
                    }
                    
                })
                
            }
        }
        
    }
    
    // Check if Glider is circling
    private func checkIfGliderIsCircling() {
        // If Thermal Assistant Switch is on - State true
        
        guard UserDefaultsManager.thermalAssistantState() == true,
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
            
            #if DEBUG
            DLLogger.writeStringToLogFile("\(#function) -> true - Thermal Circling Start detected")
            #endif
            
        } else if leftTurnCounter == 0 && rightTurnCounter == 0 && isGliderCircling == true {
            isGliderCircling = false
            MapScreenViewController.decreaseZoomLevel()
            
            #if DEBUG
            DLLogger.writeStringToLogFile("\(#function) -> false - Thermal Circling End detected")
            #endif
            
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
    // http://www.sglenzburg.ch/org/public/Dokumente/Powerpoint/Sauerstoff-SGL-Streckenflugseminar.pdf
    private func checkForLowOxygenWarning() {
        guard let currentLocation = LocationManager.currentLocation()
        else { return }
        
        let oxygenWarningSwitch = UserDefaultsManager.lowOxygenWarningState()
        if oxygenWarningSwitch == true {
            if currentLocation.altitude > Presets.FlightComputer.lowOxygenWarningAltitude {
                if enteredLowOxygenAltitudeTimestamp == nil {
                    //print("GLIDER ENTERED LOW OXYGEN ALTITUDE")
                    enteredLowOxygenAltitudeTimestamp = Date.currentUnixTimeStamp
                } else {
                    let secondsAboveLowOxygenWarningAltitude = Date.currentUnixTimeStamp - enteredLowOxygenAltitudeTimestamp!
                    if secondsAboveLowOxygenWarningAltitude > Presets.FlightComputer.safeSecondsAtLowOxygenAltitude {
                        if shouldPlayOxygenWarning == true {
                            //print("PLAY OXYGEN WARNING")
                            speak(string: Presets.FlightComputer.lowOxygenWarningSpokenText)
                            shouldPlayOxygenWarning = false
                        } else {
                            //print("GLIDER IN LOW OXYGEN WARNING ALTITUDE, BUT WARNING ALREADY PLAYED")
                        }
                        
                    } else {
                        //print("GLIDER NOT LONG ENOUGH IN LOW OXYGEN WARNING ALTITUDE")
                    }
                    
                }
                
            } else {
                if enteredLowOxygenAltitudeTimestamp != nil {
                    //print("GLIDER DESCANDED UNDER LOW OXYGEN WARNING ALTITUDE")
                    enteredLowOxygenAltitudeTimestamp = nil
                    if shouldPlayOxygenWarning == false {
                        shouldPlayOxygenWarning = true
                    }
                    
                } else {
                    //print("GLIDER IS UNDER LOW OXYGEN WARNING ALTITUDE")
                }
                
            }
            
        } else {
            //print("OXYGEN WARNING SWITCH IS OFF")
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
        checkForLowOxygenWarning()
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
