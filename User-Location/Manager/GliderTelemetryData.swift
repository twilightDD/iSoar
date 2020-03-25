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
    var flarmID: String = "keine flarmID"
    var timestamp: Int64 = 0
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var type: String = ""
    var heading: Double = 0
    var speed: Double = 0
    var altitude: Double = 0
    var climbRate: Double = 0
    
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
            
            // print("TelemetryDataArray: \(telemetryDataArray)")
            
            // TODO: Magic Number - nicht cool. Add docu! 16.3.20, ph
            guard telemetryDataArray.count >= 10
                else { return nil }
            
            let flarmID = telemetryDataArray[0]
            let timestamp = Date.currentUnixTimeStamp
            
            let latitude = String(telemetryDataArray[2])
            let longitude = String(telemetryDataArray[3])
            let location = locationCoordinateFrom(latitude: latitude,
                                                  longitude: longitude)
            
            let type = String(telemetryDataArray[4])
            
            let heading = Double(telemetryDataArray[5]) ?? 0
            
            let speed = speedFrom(speed: telemetryDataArray[6])
            
            let altitude = altitudeFrom(altitude: telemetryDataArray[7])
            
            let climbRate = climbRateFrom(climbRate: telemetryDataArray[10])
            
            let telemetryData = GliderTelemetryData(flarmID: flarmID,
                                                    timestamp: timestamp,
                                                    location: location,
                                                    type: type,
                                                    heading: heading,
                                                    speed: speed,
                                                    altitude: altitude,
                                                    climbRate: climbRate
            )
            return telemetryData
    }
    
    private static func parseAndCleanup(response: String)
        -> [String] {
            
            var finalResponse = response
            // Convert response to Array of Strings
            if let anfang = finalResponse.firstIndex(of: ">"),
                let ende = finalResponse.firstIndex(of: ":") {
                let range = anfang..<ende
                // print("Range: \(range)")
                
                finalResponse.replaceSubrange(range, with: "")
            }
            
            finalResponse = finalResponse
                .replacingOccurrences(of: ">", with: " ")
                .replacingOccurrences(of: ":\\", with: " ")
                .replacingOccurrences(of: ":/", with: " ")
                .replacingOccurrences(of: "h", with: " ")
                .replacingOccurrences(of: "N/", with: " ")
                .replacingOccurrences(of: "N\\", with: " ")
                .replacingOccurrences(of: "Eg", with: " NA ")
                .replacingOccurrences(of: "En", with: " NA ")
                .replacingOccurrences(of: "Ez", with: " NA ")
                .replacingOccurrences(of: "EX", with: " heli ")
                .replacingOccurrences(of: "E'", with: " plane ")
                .replacingOccurrences(of: "E\'", with: " NA ")
                .replacingOccurrences(of: "E^", with: " plane ")
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
            
            // print(responseArray)
            return responseArray
    }
    
    private static func locationCoordinateFrom(latitude: String, longitude: String)
        -> CLLocationCoordinate2D {
            // Calculate Latitude from Degrees, Minutes and Seconds
            let latitudeResult = convertToDecimalDegrees(string: latitude)
            
            // Calculate Longitude from Degrees, Minutes and Seconds
            let longitudeResult = convertToDecimalDegrees(string: longitude)
            
            // Location Result
            let locationCoordinate = CLLocationCoordinate2D(latitude: latitudeResult,
                                                            longitude: longitudeResult)
            return locationCoordinate
    }
    
    // Convert from Degrees Decimal Minutes (DDM) to Decimal-Degrees (DD) - (actually we do DDM to DMS to DD)
    // Online Coverter: https://www.pgc.umn.edu/apps/convert/
    // Formula DMS to DD: http://www.mwegner.de/geo/geo-koordinaten/umrechnung-grad-minute-sekunde-dezimalgrad.html
    // To avoid calculating DDM to DMS to DD - https://support.esri.com/en/technical-article/000007058
    private static func convertToDecimalDegrees(string: String)
        -> Double {
            var degreeString = ""
            
            // Degree String
            if let range = string.range(of: ".") {
                degreeString = String(string[string.startIndex..<range.lowerBound].dropLast(2))
                // print("DegreeString: \(degreeString)")
            }
            
            // Minutes String
            var minutesString = ""
            if let range = string.range(of: ".") {
                minutesString = String(string[string.startIndex..<range.lowerBound].suffix(2))
                //print("MinuteString: \(minutesString)")
            }
            
            // Seconds String
            // The latitude and longitude are expressed in degrees, minutes and decimal fractions of minutes, NOT degrees-minutes-seconds! - http://wa8lmf.net/aprs/APRS_symbols.htm
            // So we have to convert decimal fractions of minutes to seconds
            // Convert eg. 4658.70 - the .70 minutes = 42 Seconds
            let seconds: Double = Double(Int(string.suffix(2)) ?? 0) / 100.0 * 60.0
            //print("SecondsString: \(seconds)")
            
            // Formula: http://www.mwegner.de/geo/geo-koordinaten/umrechnung-grad-minute-sekunde-dezimalgrad.html
            // First: divide Seconds by 60 and add Minutes
            let firstResult = (seconds / 60) + (Double(minutesString) ?? 0.0)
            // Second: Divide the Result by 60
            let secondResult = firstResult / 60
            // Third: Add Degrees to the Result
            let thirdResult = secondResult + (Double(degreeString) ?? 0.0)
            
            return thirdResult
    }
    
    // Convert Heading
    private static func headingFrom(heading headingString: String)
        -> Double {
            if let heading = Double.init(headingString) {
                return heading
            }
            
            return 0
    }
    
    // Convert Speed
    private static func speedFrom(speed speedString: String)
        -> Double {
            if let speed = Double.init(speedString) {
                // Convert Knots to Km\h - by multiplying with 1.852
                let speedConverted = speed * 1.852
                // TODO: Truncate decimals
                
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 0
                
                return speedConverted
            }
            
            return 0
    }
    
    // Convert Altitude
    private static func altitudeFrom(altitude altitudeString: String)
        -> Double {
            if let altitude = Double.init(altitudeString) {
                // Convert from Feet to Meter - by dividing with 3.281
                let altitudeConverted = altitude / 3.281
                // Truncate decimals
                return altitudeConverted
            }
            
            return 0
    }
    
    // Convert ClimbRate
    private static func climbRateFrom(climbRate climbRateString: String)
        -> Double {
            if let climbRate = Double.init(climbRateString) {
                // Convert Feet per Minute to Meter per Second -  by dividing with 197
                var climbRateConverted = climbRate / 197
                // Truncate after 1 decimal
                climbRateConverted = climbRateConverted.truncate(places: 1)
                return climbRateConverted
            }
            
            return 0

    }
    
}

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
