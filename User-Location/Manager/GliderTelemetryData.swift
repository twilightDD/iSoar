//
//  GliderTelemetryData.swift
//  Glider Tool
//
//  Created by sonic on 13.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - OGNMessage
struct GliderTelemetryData: Hashable {

    // MARK: Lets and Vars
    var flarmID: String
    var timestamp: String
    var location: CLLocationCoordinate2D
    var heading: Double
    var isHeadingValid: Bool
    var speed: Double
    var altitude: Double
    var climbRate: Double

    // MARK: - Hashable
    static func == (lhs: GliderTelemetryData, rhs: GliderTelemetryData) -> Bool {
        return lhs.flarmID == rhs.flarmID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(flarmID)
    }

    // MARK: - Init&Co.
    static func telemetryDataFromOGNGliderResponse(_ response: String)
        -> GliderTelemetryData? {

            let telemetryDataArray = parseAndCleanup(response: response)
            
            print(telemetryDataArray)

            // TODO: Magic Number - nicht cool. Add docu! 16.3.20, ph
            guard telemetryDataArray.count >= 10
                else { return nil }

            let flarmID = telemetryDataArray[0]
            //let timestamp = telemetryDataArray[1]

            let latitude = String(telemetryDataArray[2])
            let longitude = String(telemetryDataArray[3])
            let location = locationCoordinateFrom(latitude: latitude,
                                                  longitude: longitude)

            let heading = headingFrom(heading: telemetryDataArray[4])
            var isHeadingValid = true
            if heading.isEqual(to: 0) {
                isHeadingValid = false
            }

            let speed = speedFrom(speed: telemetryDataArray[5])

            let altitude = altitudeFrom(altitude: telemetryDataArray[6])

            let climbRate = climbRateFrom(climbRate: telemetryDataArray[9])

            //let flarmID = responseArray[OGNMessageComponents.flarmID]
            let telemetryData = GliderTelemetryData(flarmID: flarmID,
                                                    timestamp: telemetryDataArray[1],
                                                    location: location,
                                                    heading: heading,
                                                    isHeadingValid: isHeadingValid,
                                                    speed: speed,
                                                    altitude: altitude,
                                                    climbRate: climbRate
            )
            return telemetryData
    }

    private static func parseAndCleanup(response: String)
        -> [String] {

            var finalResponse = response
            // convert response to array of strings
            if let anfang = finalResponse.firstIndex(of: ">"),
                let ende = finalResponse.firstIndex(of: ":") {
                let range = anfang..<ende
                print("Range: \(range)")

                finalResponse.replaceSubrange(range, with: "")
            }

            finalResponse = finalResponse
                .replacingOccurrences(of: ">", with: " ")
                .replacingOccurrences(of: ":\\", with: " ")
                .replacingOccurrences(of: ":/", with: " ")
                .replacingOccurrences(of: "h", with: " ")
                .replacingOccurrences(of: "N/", with: " ")
                .replacingOccurrences(of: "N\\", with: " ")
                .replacingOccurrences(of: "Eg", with: " ")
                .replacingOccurrences(of: "En", with: " ")
                .replacingOccurrences(of: "Ez", with: " ")
                .replacingOccurrences(of: "EX", with: " ")
                .replacingOccurrences(of: "E'", with: " ")
                .replacingOccurrences(of: "E\'", with: " ")
                .replacingOccurrences(of: "E^", with: " ")
                .replacingOccurrences(of: "/", with: " ")
                .replacingOccurrences(of: "A=", with: " ")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
                .replacingOccurrences(of: "fpm", with: "")

            //print("bereinigt: \(finalResponse)")

            // Split response into parts and convert it to "array of strings"; 16.3.20, ph
            let splittedFinalResponse = finalResponse.split(separator: " ")

            var responseArray = [String]()
            for responseSubsequence in splittedFinalResponse {
                responseArray.append(String(responseSubsequence))
            }

            return responseArray
    }

    private static func locationCoordinateFrom(latitude: String, longitude: String)
        -> CLLocationCoordinate2D {
            // Calculate Latitude from Degrees, Minutes and Seconds
            let thirdLatitudeResult = convertToDegrees(string: latitude)

            // Calculate Longitude from Degrees, Minutes and Seconds
            let thirdLongitudeResult = convertToDegrees(string: longitude)

            // Location Result
            let locationCoordinate = CLLocationCoordinate2D(latitude: thirdLatitudeResult,
                                                            longitude: thirdLongitudeResult)
            return locationCoordinate
    }

    // Convert Degrees to radians
    private static func convertToDegrees(string: String)
        -> Double {
            // Longitude Degree String
            var degreeString = ""

            if let range = string.range(of: ".") {
                degreeString = String(string[string.startIndex..<range.lowerBound].dropLast(2))
            }

            // Longitude Minutes String
            var minutesString = ""
            if let range = string.range(of: ".") {
                minutesString = String(string[string.startIndex..<range.lowerBound].suffix(2))
            }

            // Latitude Seconds String
            let seconds: Double = Double(Int(string.suffix(2)) ?? 0) / 100.0 * 60.0

            let firstResult = (seconds / 60) + (Double(minutesString) ?? 0.0)
            let secondResult = firstResult / 60
            let thirdResult = secondResult + (Double(degreeString) ?? 0.0)

            return thirdResult
    }
    
    // Convert Heading
    private static func headingFrom(heading headingString: String)
        -> Double {
            guard let heading = Double.init(headingString)
                else { return 0 }

            // TODO: Magic Number - nicht cool. Add docu! 16.3.20, ph
            let headingCorrected = heading - 1
            return headingCorrected
    }
    
    // Convert Speed - from knots to km\m - by multiplying with 1.852
    private static func speedFrom(speed speedString: String)
        -> Double {
            if var speed = Double.init(speedString) {
                speed = speed * 1.852 // knots in km\m
                return speed
            }

            return 0
    }
    
    // Convert Altitude - from feet to meter - by dividing with 3.281
    private static func altitudeFrom(altitude altitudeString: String)
        -> Double {
            if var altitude = Double.init(altitudeString) {
                altitude = altitude / 3.281 // feet in meter
                return altitude
            }

            return 0
    }
    
    // Convert ClimbRate - from fpm to m\s - by dividing with 197
    private static func climbRateFrom(climbRate climbRateString: String)
        -> Double {
            if var climbRate = Double.init(climbRateString) {
                climbRate = climbRate / 197
                return climbRate
            }

            return 0
    }
    
}

enum OGNMessageComponents: Int {
//    typealias RawValue = Int

    case flarmID = 0

}
