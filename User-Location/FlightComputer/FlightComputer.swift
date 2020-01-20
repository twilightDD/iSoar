//
//  FlightComputer.swift
//  Glider Tool
//
//  Created by sonic on 09.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreLocation
import AVFoundation

// MARK: - FlightComputer
class FlightComputer {
    
    // MARK: - Lets and Vars
    static let shared = FlightComputer()
    
    let defaults = UserDefaults.standard
    
    var gliderIsFlying: Bool = false
    
    var playGearWarning = true
    var playOxygenWarning = true
    
    // MARK: - Public Methods
    // Check if Glider is flying or on ground
    func checkIfGliderIsFlying() {
        if gliderIsFlying == false {
            // Check if Glider is faster than 7m/s, then set FlightMode to true
            if MapScreen.shared!.currentLocation!.speed > 7 {
                gliderIsFlying = true
                
                // Create FlightRecorder File
                FlightRecorder.shared.recorderIsReadyToWrite = ISoarFileManager.createFlightRecorderFile()
            }
            else {
                return
            }
        }
        else {
            // Check if Glider is slower than 7m/s, then set FlightMode to false
            if MapScreen.shared!.currentLocation!.speed < 7 {
                gliderIsFlying = false
                
                // Close FlightRecorder File
                ISoarFileManager.closeFlightRecorderFile()
                FlightRecorder.shared.recorderIsReadyToWrite = false
            }
            else {
                return
            }
        }
        
    }
    
    // MARK: Audio Warnings
    // Audio Landing Gear Warning
    func gearWarning() {
        guard let selectedDestinationAirport = MapScreen.shared?.selectedDestinationAirport else {
            return
        }
        
        let landingGearWarningSwitch = defaults.value(forKey: "landingGearWarningSwitch") as! Bool
        
        let distanceInKm = (MapScreen.shared?.currentDistance!)!/1000
        
        let upperGearWarningAltitude = selectedDestinationAirport.elevation + 400
        let lowerGearWarningAltitude = selectedDestinationAirport.elevation + 200
        
        if landingGearWarningSwitch == true {
            
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
