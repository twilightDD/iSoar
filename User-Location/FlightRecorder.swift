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
    
    // MARK: - Public Methods
    func addFlightRecorderEntryForLocation(_ currentLocation: CLLocation) {
        let flightData = FlightData(unixTimeStamp: Date.currentTimeStamp,
                                    latitude: currentLocation.coordinate.latitude,
                                    longitude: currentLocation.coordinate.longitude,
                                    altitude: currentLocation.altitude,
                                    speed: currentLocation.speed,
                                    course: currentLocation.course,
                                    horizontalAccuracy: currentLocation.horizontalAccuracy,
                                    verticalAccuracy: currentLocation.verticalAccuracy)
        flightDataArray.append(flightData)
        
        print("Location: time: \(Date.currentTimeStamp) hA: \(flightData.horizontalAccuracy) vA: \(flightData.verticalAccuracy) long: \(flightData.longitude) lat: \(flightData.latitude)")
        print("Anzahl Einträge: \(flightDataArray.count)")
    }
    
}

// MARK: - Extentsion - Structs and Enums
extension FlightRecorder {
    
    struct FlightData: Equatable {
        //MARK: Lets and Vars
        var unixTimeStamp: Int64
        var latitude: Double
        var longitude: Double
        var altitude: Double
        var speed: Double
        var course: Double
        var horizontalAccuracy: CLLocationAccuracy
        var verticalAccuracy: CLLocationAccuracy

    }
    
}

// Unix Date Extension
extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
