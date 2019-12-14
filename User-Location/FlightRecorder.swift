//
//  FlightRecorder.swift
//  Glider Tool
//
//  Created by sonic on 14.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

//MARK: - FlightRecorder
class FlightRecorder {
    
    //MARK: - Lets and Vars
    static let shared = FlightRecorder()
    var flightDataArray = [FlightRecorder.flightData]()
    
    
    //MARK: - Public Methods
    func storeFlightData() {
        
        flightDataArray.append(flightData(time: "12", latitude: 12, longitude: 12, altitude: 12, speed: 12, course: 12))

    }
    
}

//MARK: - Extentsion - Structs and Enums
extension FlightRecorder {
    
    struct flightData: Equatable {
        //MARK: Lets and Vars
        
        var time: String
        var latitude: Double
        var longitude: Double
        var altitude: Double
        var speed: Double
        var course: Double
        
    }
}
