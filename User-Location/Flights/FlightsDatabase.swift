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
    
    class func getFlightMetaDataFileNames()
        -> [String] {
            let fileNames = ISoarFileManager.flightMetaDataFileNames()
           
            return fileNames
    }


    class func metaData()
        -> FlightMetaData? {
            
            // ToDo: Ausgabe der Dateinamen
            print(ISoarFileManager.flightMetaDataFileNames().description)
            
            
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
    var flightUUID: String
    var flightDate: String
    var gliderID: String
    var startTimeUTC: String
    var startICAO: String
    var endTimeUTC: String
    var endICAO: String
    var flightCompleted: Bool
    var flightTime: String
}
