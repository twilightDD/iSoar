//
//  TasksDatabase.swift
//  Glider Tool
//
//  Created by sonic on 06.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

// MARK: - FlightsDatabase
class FlightsDatabase {
    static private let shared = FlightsDatabase()


    // MARK: - Public Class Methods
    // Sort Flights in Logbook in descending Date Order
    class func sortedFlightsByDescendingDate()
        -> [FlightMetaData] {
            let sortedFlightMetaDatas = FlightsDatabase.flightMetaDatas().sorted(by: { ($0.flightDate > $1.flightDate) })
            //            sortedFlightMetaDatas = sortedFlightMetaDatas.sorted(by: { ($0.startTimeUTC > $1.startTimeUTC) })

            return sortedFlightMetaDatas
    }

    
    // MARK: - Private Class Methods
    // Parse obtained JSONs into an array
    private class func flightMetaDatas()
        -> [FlightMetaData] {
            var flightMetaDatas = [FlightMetaData]()

            let flightMetaDataDatas = ISoarFileManager.flightMetaDataFileDatas()

            for flightMetaDataData in flightMetaDataDatas {
                do {
                    let flightMetaData = try JSONDecoder().decode(FlightMetaData.self,
                                                                  from: flightMetaDataData)
                    flightMetaDatas.append(flightMetaData)

                } catch let jsonError {
                    print("\(jsonError.localizedDescription)")
                }
            }

            return flightMetaDatas
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
