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
    var flarmID: String = "No FlarmID"
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
    // MARK: - Public Methods
    static func telemetryDataFromOGNGliderResponse(_ response: String)
        -> GliderTelemetryData? {
            let telemetryDataArray = parseAndCleanup(response: response)
            
            // print("TelemetryDataArray: \(telemetryDataArray)")

            //TODO: Magic number => remove comment sign; 01042020, ph
            guard telemetryDataArray.count >= 11// ResponseElements.allCases.count
                else {
                    print("telemetryDataArray has to less enties: \(telemetryDataArray.count)\ntelemetryDataArray: \(telemetryDataArray)\nresponse string: \(response)")
                    return nil
            }
            
            let flarmID = telemetryDataArray[ResponseElements.flarmID.rawValue]
            let timestamp = Date.currentUnixTimeStamp

            let latitude = String(telemetryDataArray[ResponseElements.latitude.rawValue])
            let latitudeHemisphere = String(telemetryDataArray[ResponseElements.latitudeHemisphere.rawValue])
            let longitude = String(telemetryDataArray[ResponseElements.longitude.rawValue])
            let longitudeHemisphere = String(telemetryDataArray[ResponseElements.longitudeHemisphere.rawValue])
            let location = locationCoordinateFrom(latitude: latitude,
                                                 latitudeHemisphere: latitudeHemisphere,
                                                 longitude: longitude,
                                                 longitudeHemisphere: longitudeHemisphere)

            let type = String(telemetryDataArray[ResponseElements.type.rawValue])
            let heading = Double(telemetryDataArray[7]) ?? 0
            let speed = speedFrom(speed: telemetryDataArray[ResponseElements.speed.rawValue])
            let altitude = altitudeFrom(altitude: telemetryDataArray[ResponseElements.altitude.rawValue])
            let climbRate = climbRateFrom(climbRate: telemetryDataArray[ResponseElements.climbRate.rawValue])
            
            // Extract the interesting Data from TelemetryData
            let telemetryData = GliderTelemetryData(flarmID: flarmID,
                                                    timestamp: timestamp,
                                                    location: location,
                                                    type: type,
                                                    heading: heading,
                                                    speed: speed,
                                                    altitude: altitude,
                                                    climbRate: climbRate
            )
            
            // print(telemetryData)
            return telemetryData
    }
    
    // MARK: - Private Methods
    // Parse and cleanup
    private static func parseAndCleanup(response: String)
        -> [String] {
            // For element desciption see: https://github.com/svoop/ogn_client-ruby/wiki/SenderBeacon

            var finalResponse = response
            // Convert response to Array of Strings
            if let start = finalResponse.firstIndex(of: ">"),
                let end = finalResponse.firstIndex(of: ":") {
                let range = start..<end
                // print("Range: \(range)")
                
                finalResponse.replaceSubrange(range, with: "")
            }
            
            // Replace all unwanted symbols from String
            finalResponse = finalResponse
                .replacingOccurrences(of: ">", with: " ")
                .replacingOccurrences(of: ":\\", with: " ")
                .replacingOccurrences(of: ":/", with: " ")
                .replacingOccurrences(of: "h", with: " ")
                .replacingOccurrences(of: "N/", with: " N ")
                .replacingOccurrences(of: "N\\", with: " N ")
                .replacingOccurrences(of: "S/", with: " S ")
                .replacingOccurrences(of: "S\\", with: " S ")
                .replacingOccurrences(of: "Eg", with: " E plane ")
                .replacingOccurrences(of: "En", with: " E plane ")
                .replacingOccurrences(of: "Ez", with: " E plane ")
                .replacingOccurrences(of: "EX", with: " E heli ")
                .replacingOccurrences(of: "E'", with: " E plane ")
                .replacingOccurrences(of: "E\'", with: " E plane ")
                .replacingOccurrences(of: "E^", with: " E plane ")
                .replacingOccurrences(of: "Wg", with: " W plane ")
                .replacingOccurrences(of: "Wn", with: " W plane ")
                .replacingOccurrences(of: "Wz", with: " W plane ")
                .replacingOccurrences(of: "WX", with: " W heli ")
                .replacingOccurrences(of: "W'", with: " W plane ")
                .replacingOccurrences(of: "W\'", with: " W plane ")
                .replacingOccurrences(of: "W^", with: " W plane ")
                .replacingOccurrences(of: "/", with: " ")
                .replacingOccurrences(of: "A=", with: " ")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
                .replacingOccurrences(of: "fpm", with: "")
            
            //print("bereinigt: \(finalResponse)")
            
            // Split response into parts seperated by spaces
            let splittedFinalResponse = finalResponse.split(separator: " ")
            
            // Insert parts into an Array - responseArray
            var responseArray = [String]()
            for responseSubsequence in splittedFinalResponse {
                responseArray.append(String(responseSubsequence))
            }
            
            // print(responseArray)
            return responseArray
    }
    
    // Calculate Latitude and Logitude from Strigs
    private static func locationCoordinateFrom(latitude: String,
                                               latitudeHemisphere: String,
                                               longitude: String,
                                               longitudeHemisphere: String)
        -> CLLocationCoordinate2D {
            // Calculate Latitude from Degrees, Minutes and Seconds
            
            var latitudeResult = convertToDecimalDegrees(string: latitude)
            if latitudeHemisphere == "S" {
                latitudeResult *= -1
            }
            
            // Calculate Longitude from Degrees, Minutes and Seconds
            var longitudeResult = convertToDecimalDegrees(string: longitude)
            if longitudeHemisphere == "W" {
                longitudeResult *= -1
            }
            
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

                return altitudeConverted
            }
            
            return 0
    }
    
    // Convert ClimbRate
    private static func climbRateFrom(climbRate climbRateString: String)
        -> Double {
            if let climbRate = Double.init(climbRateString) {
                // Convert Feet per Minute to Meter per Second - by dividing with 197
                var climbRateConverted = climbRate / 197
                // Truncate after 1 decimal
                climbRateConverted = climbRateConverted.truncate(places: 1)
                return climbRateConverted
            }
            
            return 0
            
    }
    
}

// MARK: - Extensions
// Truncate Decimal Places
extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


//TODO: Rename and expande extention; 01042020, ph
// MARK: - Extension - ResponseElements
enum ResponseElements: Int, CaseIterable {

    // For element desciption see: https://github.com/svoop/ogn_client-ruby/wiki/SenderBeacon

    case flarmID = 0
    case timeStamp = 1
    case latitude = 2
    case latitudeHemisphere = 3 // N(orth) or S(outh)
    case longitude = 4
    case longitudeHemisphere = 5 // E(ast) or W(est)
    case type = 6
    case heading = 7
    case speed = 8
    case altitude = 9
    case position = 10
    case deviceID = 11
    case climbRate = 12
    case turnRate = 13
    case signal = 14
    case crc = 15
    case frequency = 16
    case quality = 17

}
