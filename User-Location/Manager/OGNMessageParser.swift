//
//  OGNMessageParser.swift
//  Glider Tool
//
//  Created by sonic on 13.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

class OGNMessageParser: NSObject {
    
    func parseResponse(response: String) -> OGNMessage {
        var finalResponse = response
        
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
        
        let responseArray = finalResponse.split(separator: " ")
        
        // Calculate Latitude from Degrees, Minutes and Seconds
        let latitude = String(responseArray[2])
        
        // Latitude Degree String
        var latitudeDegreeString = ""
        if let range = latitude.range(of: ".") {
            latitudeDegreeString = String(latitude[latitude.startIndex..<range.lowerBound].dropLast(2))
        }
        
        // Latitude Minutes String
        var latitudeMinutesString = ""
        if let range = latitude.range(of: ".") {
            latitudeMinutesString = String(latitude[latitude.startIndex..<range.lowerBound].suffix(2))
        }
        
        // Latitude Seconds String
        let latitudeSeconds: Double = Double(Int(String(latitude.suffix(2))) ?? 0) / 100.0 * 60.0
        
        let firstLatitudeResult = (latitudeSeconds / 60) + (Double(latitudeMinutesString) ?? 0.0)
        let secondLatitudeResult = firstLatitudeResult / 60
        let thirdLatitudeResult = secondLatitudeResult + (Double(latitudeDegreeString) ?? 0.0)
        
        print("Deg-Min-Sec: \(latitudeDegreeString)° \(latitudeMinutesString)' \(latitudeSeconds)'")
        print("Calculated Latitude: \(thirdLatitudeResult)")
           
        // Calculate Longitude from Degrees, Minutes and Seconds
        let longitude = String(responseArray[3])
        
        // Longitude Degree String
        var longitudeDegreeString = ""
        if let range = longitude.range(of: ".") {
            longitudeDegreeString = String(longitude[longitude.startIndex..<range.lowerBound].dropLast(2))
        }
        
        // Longitude Minutes String
        var longitudeMinutesString = ""
        if let range = longitude.range(of: ".") {
            longitudeMinutesString = String(longitude[longitude.startIndex..<range.lowerBound].suffix(2))
        }
        
        // Latitude Seconds String
        let longitudeSeconds: Double = Double(Int(String(longitude.suffix(2))) ?? 0) / 100.0 * 60.0
        
        let firstLongitudeResult = (longitudeSeconds / 60) + (Double(longitudeMinutesString) ?? 0.0)
        let secondLongitudeResult = firstLongitudeResult / 60
        let thirdLongitudeResult = secondLongitudeResult + (Double(longitudeDegreeString) ?? 0.0)
        
        print("Deg-Min-Sec: \(longitudeDegreeString)° \(longitudeMinutesString)' \(longitudeSeconds)'")
        print("Calculated Longitude: \(thirdLongitudeResult)")
        
        // Location Result
        let location = CLLocationCoordinate2D(latitude: thirdLatitudeResult, longitude: thirdLongitudeResult)
        
        // TODO: Calculate Altitude from ft to m by dividing with 3,281
        // let altitude: Double = 0
        
        // TODO: Calculate ClimbRate from fpm to ms by dividing with 197
        // let climbRate: Double = 0
        
        
            
        return OGNMessage(
            flarmID: String(responseArray[0]),
            timestamp: String(responseArray[1]),
            location: location,
            heading: String(responseArray[4]),
            speed: String(responseArray[5]),
            altitude: String(responseArray[6]),
            climbRate: String(responseArray[9])
        )
    }
    
}
