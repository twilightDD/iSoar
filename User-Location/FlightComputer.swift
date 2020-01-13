//
//  FlightComputer.swift
//  Glider Tool
//
//  Created by sonic on 09.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - FlightComputer
class FlightComputer {
    
    // MARK: - Lets and Vars
    static let shared = FlightComputer()
    
    var currentLocation:CLLocation?
    
    var gliderIsFlying: Bool = false
    
    var today = Date()
    var startFlightTime = Date()
    var stopFlightTime = Date()
    
    // MARK: - Public Methods
    // Check if Glider is flying or on ground
    func checkIfGliderIsFlying() {
        if gliderIsFlying == false {
            // Check if Glider is faster than 7m/s, then set FlightMode to true
            if MapScreen.shared!.currentLocation!.speed > 7 {
                gliderIsFlying = true
                startFlightTime = Date()
                
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
                stopFlightTime = Date()
                
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
