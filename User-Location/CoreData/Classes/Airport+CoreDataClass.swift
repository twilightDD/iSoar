//
//  Airport+CoreDataClass.swift
//  Glider Tool
//
//  Created by sonic on 18.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import CoreData

@objc(Airport)
public class Airport: NSManagedObject {

}

extension Airport {
    struct Attributes {
        static let additionalInfo = "additionalInfo"
        static let airportType = "airportType"
        static let country = "country"
        static let elevation = "elevation"
        static let icao = "icao"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let name = "name"
        static let phone = "phone"
        static let radioFrequency = "radioFrequency"
        static let radioName = "radioName"
        static let runwayDimensions = "runwayDimensions"
        static let runwayDirections = "runwayDirections"
        static let runwaySurface = "runwaySurface"
        static let url = "url"
        static let uuid = "uuid"
        static let validationDate = "validationDate"

    }
}
