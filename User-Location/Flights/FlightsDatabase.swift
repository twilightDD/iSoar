//
//  TasksDatabase.swift
//  Glider Tool
//
//  Created by sonic on 06.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

//MARK: - FlightsDatabase
class FlightsDatabase {
    static let shared = FlightsDatabase()
    
    class func flightFileNames()
        -> [String] {
            let flightFileNames = ISoarFileManager.flightFileNames()
            
            return flightFileNames
    }

    class func metaData()
        -> FlightMetaData? {
            var flightMetaData: FlightMetaData?

            if let metaDataData = ISoarFileManager.flightMetaDataFileData() {
                do {
                    flightMetaData = try JSONDecoder().decode(FlightMetaData.self,
                                                              from: metaDataData)
                } catch let jsonError {
                    print("\(jsonError.localizedDescription)")
                }
            }

            return flightMetaData
    }

}

// MARK: Extension - Struct

struct FlightMetaData: Codable {
    var uuid: String
    var date: String
    var gliderID: String
    var startTimeUTC: String
    var startICAO: String
    var endTimeUTC: String
    var endICAO: String
    var flightCompleted: Bool
    var flightTime: String
}
