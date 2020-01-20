//
//  FlightComputer.swift
//  Glider Tool
//
//  Created by sonic on 09.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreLocation

// MARK: - FlightComputer
class FlightComputer {
    
    // MARK: - Lets and Vars
    static let shared = FlightComputer()
    
    var currentLocation:CLLocation?
    
    var gliderIsFlying: Bool = false
    
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
    
}
