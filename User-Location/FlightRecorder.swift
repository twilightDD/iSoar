//
//  FlightRecorder.swift
//  Glider Tool
//
//  Created by sonic on 14.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - FlightRecorder
class FlightRecorder {
    
    // MARK: - Lets and Vars
    static let shared = FlightRecorder()
    var flightDataArray = [FlightRecorder.FlightData]()
    
    var gliderIsFlying: Bool = false
    var recorderIsReadyToWrite = false

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

                // create file
                recorderIsReadyToWrite = ISoarFileManager.createFileForFlight()
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

                ISoarFileManager.stopFlightRecorderFile()
                recorderIsReadyToWrite = false

               // ISoarFileManager.createFlightRecorderFile()

                // ToDo: Store content of the flightDataArray to the File
                // ToDo: Remove all Entries from the flightDataArray
            }
            else {
                return
            }
        }
        
    }



    // Add Current Location Infos to FlightRecorder Database
    func addFlightRecorderEntryForLocation(_ currentLocation: CLLocation) {

        let locationCoordinate2D = CLLocationCoordinate2D.init(latitude: currentLocation.coordinate.latitude,
                                                               longitude: currentLocation.coordinate.longitude)
        
        let currentPositionInfo = FlightData(unixTimeStamp: Date.currentTimeStamp,
                                    latitude: currentLocation.coordinate.latitude,
                                    longitude: currentLocation.coordinate.longitude,
                                    locationCoordinate2D: locationCoordinate2D,
                                    altitude: currentLocation.altitude,
                                    speed: currentLocation.speed,
                                    course: currentLocation.course)
        flightDataArray.append(currentPositionInfo)


        // Flight Recorder on disk
        checkIfGliderIsFlying()
        if recorderIsReadyToWrite == true {
            // Aufbereiten der Daten für das RecorderFile
            var recordLine = ""
            recordLine.append(contentsOf: "\(currentPositionInfo.unixTimeStamp): ")
            recordLine.append(contentsOf: "lat \(locationCoordinate2D.latitude) ")
            recordLine.append(contentsOf: "lon \(locationCoordinate2D.longitude) ")
            recordLine.append(contentsOf: "\n")

            ISoarFileManager.appendToFlightRecorderFile(recordLine)
        }
    }
    
}

// MARK: - Extentsion - Structs and Enums
extension FlightRecorder {
    
    struct FlightData: Equatable {
        //MARK: Lets and Vars
        var unixTimeStamp: Int64
        var latitude: Double
        var longitude: Double
        var locationCoordinate2D : CLLocationCoordinate2D
        var altitude: Double
        var speed: Double
        var course: Double
        
    }
    
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D)
        -> Bool {
            return lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
    }
}

// Unix Date Extension
extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
