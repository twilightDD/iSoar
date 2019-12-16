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
    var flightDataArray = [FlightRecorder.flightData]()
    
    var currentLocation:CLLocation?
    
    
    // MARK: - Public Methods
    func storeFlightData() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        //let timeStamp = Date().timeIntervalSince1970
        let unixTimeStamp = Date.currentTimeStamp
        
        flightDataArray.append(flightData(unixTimeStamp: unixTimeStamp,
                                          latitude: currentLocation.coordinate.latitude,
                                          longitude: currentLocation.coordinate.latitude,
                                          altitude: currentLocation.altitude,
                                          speed: currentLocation.speed,
                                          course: currentLocation.course))
    }
    
}

// MARK: - Extentsion - Structs and Enums
extension FlightRecorder {
    
    struct flightData: Equatable {
        //MARK: Lets and Vars
        var unixTimeStamp: Int64
        var latitude: Double
        var longitude: Double
        var altitude: Double
        var speed: Double
        var course: Double
    }
    
}

// Unix Date Extension
extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
