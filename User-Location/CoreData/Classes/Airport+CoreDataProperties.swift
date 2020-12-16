//
//  Airport+CoreDataProperties.swift
//  Glider Tool
//
//  Created by sonic on 18.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import CoreData

extension Airport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Airport> {
        return NSFetchRequest<Airport>(entityName: Airport.entityName())
    }

    @NSManaged public var additionalInfo: String
    @NSManaged public var airportType: String
    @NSManaged public var country: String
    @NSManaged public var distance: Double
    @NSManaged public var elevation: Double
    @NSManaged public var icao: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String
    @NSManaged public var phone: String
    @NSManaged public var radioFrequency: String
    @NSManaged public var radioName: String
    @NSManaged public var runwayDimensions: String
    @NSManaged public var runwayDirections: String
    @NSManaged public var runwaySurface: String
    @NSManaged public var url: String
    @NSManaged public var uuid: UUID
    @NSManaged public var validationDate: String

}

extension Airport: Identifiable {

}
