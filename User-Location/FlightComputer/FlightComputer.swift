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

    var gliderIsFlying: Bool = false
    
    var flightUUID = UUID().uuidString
    var flightStartTime = Date()
    var flightEndTime = Date()
    var startICAO = String()
    var endICAO = String()
    
    var playGearWarning = true
    var playOxygenWarning = true
    
    // MARK: - Public Methods
    // Check if Glider is flying or on ground
    func checkIfGliderIsFlying() {
        if gliderIsFlying == false {
            // Check if Glider is faster than 10m/s, then set FlightMode to true
            if MapScreen.shared!.currentLocation!.speed > 10 {
                gliderIsFlying = true
                flightUUID = UUID().uuidString
                flightStartTime = Date()
                
                // Create FlightRecorder Files
                FlightRecorder.shared.recorderIsReadyToWrite = ISoarFileManager.createFlightRecorderFiles()
            }
            else {
                return
            }
        }
        else {
            // Check if Glider is slower than 10m/s, then set FlightMode to false
            if MapScreen.shared!.currentLocation!.speed < 10 {
                gliderIsFlying = false
                flightEndTime = Date()

                // Close FlightRecorder Files
                ISoarFileManager.closeFlightRecorderFiles()
                FlightRecorder.shared.recorderIsReadyToWrite = false
            }
            else {
                return
            }
        }
        
    }
    
//    // Check for nearest Aiport
//    func checkForNearestAirport()
//        -> String {
//        // Check Airport Array
//        // Sort for Distance
//        // Grab first one
//        // Check if Distance is < 500m
//        // If Yes return ICAO
//    }
    
    // MARK: Audio Warnings
    // Audio Landing Gear Warning
    func gearWarning() {
        guard let selectedDestinationAirport = MapScreen.shared?.selectedDestinationAirport
            else { return }

        let landingGearWarningSwitch = UserDefaultsManager.getLandingGearWarningSwitch()
        if landingGearWarningSwitch == true {
            let distanceInKm = (MapScreen.shared?.currentDistance!)!/1000

            let upperGearWarningAltitude = selectedDestinationAirport.elevation + 400
            let lowerGearWarningAltitude = selectedDestinationAirport.elevation + 200
            
            if distanceInKm < 1 && (MapScreen.shared?.currentLocation!.altitude)! < upperGearWarningAltitude && (MapScreen.shared?.currentLocation!.altitude)! > lowerGearWarningAltitude {
                
                if playGearWarning == true {
                    
                    AudioServicesPlayAlertSound(SystemSoundID(1256))
                    
                    let utterance = AVSpeechUtterance(string: "Check Landing Gear")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    utterance.rate = 0.5
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                    
                    playGearWarning = false
                    
                }
                else {
                    return
                }
            }
            else {
                playGearWarning = true
            }
        }
        else {
            // Landing Gear Switch is off
        }
        
    }
    
    // Audio for Oxygen Level Warning
    func oxygenWarning() {
        guard let currentLocation = MapScreen.shared?.currentLocation else {
            return
        }
        
        if currentLocation.altitude > 3500 {
            
            if playOxygenWarning == true {
                
                AudioServicesPlayAlertSound(SystemSoundID(1256))
                
                let utterance = AVSpeechUtterance(string: "Check Oxygen Level")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                playOxygenWarning = false
                
            }
            else {
                return
            }
        }
        else {
            playOxygenWarning = true
        }
    }
    
}
