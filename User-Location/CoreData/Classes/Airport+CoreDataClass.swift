//
//  Airport+CoreDataClass.swift
//  Glider Tool
//
//  Created by sonic on 18.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import CoreData
import UIKit

@objc(Airport)
public class Airport: NSManagedObject {
    
    static let importOrUpdateFinishedNotification = Notification.Name(rawValue: "airportImportOrUpdateFinished")
    static let importOrUpdateFailedNotification = Notification.Name(rawValue: "airportImportOrUpdateFailed")
    
    lazy var location = CLLocation(latitude: latitude, longitude: longitude)
    lazy var locationCoordinate2D = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
    
    class func importOrUpdate(_ airportDictionaries: [[String: Any]]) {
        
        let context = CoreDataManager.editContextInBackground()
        
        for airportDictionary in airportDictionaries {
            // Check for existing  airportDictionary or create a new one
            guard let uuidString = airportDictionary[Airport.Attributes.uuid] as? String,
                  let uuid = UUID.init(uuidString: uuidString)
            else { fatalError() }
            let airportsWithUUID = context.fetchObjects(forEntityClass: Airport.self,
                                                        sortByKeypath: nil,
                                                        predicateString: "%K == %@",
                                                        predicateArguments: [Airport.Attributes.uuid, uuid])
            
            var airportWithUUID: Airport!
            
            if airportsWithUUID.isEmpty == true {
                airportWithUUID = Airport.init(context: context)
                airportWithUUID.uuid = uuid
            } else if airportsWithUUID.count == 1 {
                if let uniqueAirport = airportsWithUUID.first {
                    airportWithUUID = uniqueAirport
                }
            } else {
                print("\(#function) - UUID already exists")
                DLLogger.writeStringToLogFile("\(#function) - UUID already exists")
                break
            }
            
            // Update Values
            airportWithUUID.additionalInfo = airportDictionary[Airport.Attributes.additionalInfo] as? String ?? "<kein Wert>"
            airportWithUUID.airportType = airportDictionary[Airport.Attributes.airportType] as? String ?? "<kein Wert>"
            airportWithUUID.country = airportDictionary[Airport.Attributes.country] as? String ?? "<kein Wert>"
            airportWithUUID.elevation = airportDictionary[Airport.Attributes.elevation] as? Double ?? 0
            airportWithUUID.icao = airportDictionary[Airport.Attributes.icao] as? String ?? "<kein Wert>"
            airportWithUUID.latitude = airportDictionary[Airport.Attributes.latitude] as? Double ?? 0
            airportWithUUID.longitude = airportDictionary[Airport.Attributes.longitude] as? Double ?? 0
            airportWithUUID.name = airportDictionary[Airport.Attributes.name] as? String ?? "<kein Wert>"
            airportWithUUID.phone = airportDictionary[Airport.Attributes.phone] as? String ?? "<kein Wert>"
            airportWithUUID.radioFrequency = airportDictionary[Airport.Attributes.radioFrequency] as? String ?? "<kein Wert>"
            airportWithUUID.radioName = airportDictionary[Airport.Attributes.radioName] as? String ?? "<kein Wert>"
            airportWithUUID.runwayDimensions = airportDictionary[Airport.Attributes.runwayDimensions] as? String ?? "<kein Wert>"
            airportWithUUID.runwayDirections = airportDictionary[Airport.Attributes.runwayDirections] as? String ?? "<kein Wert>"
            airportWithUUID.runwaySurface = airportDictionary[Airport.Attributes.runwaySurface] as? String ?? "<kein Wert>"
            airportWithUUID.url = airportDictionary[Airport.Attributes.url] as? String ?? "<kein Wert>"
            airportWithUUID.validationDate = airportDictionary[Airport.Attributes.validationDate] as? String ?? "<kein Wert>"
            
        }
        
        print("\(#function) - \(context.insertedObjects.count) Airports imported.")
        
        context.saveContext()
        
        // Post Notification for finished Import or Update
        NotificationCenter.default.post(name: importOrUpdateFinishedNotification,
                                        object: nil)
        
    }
    
    func countryImage()
    -> UIImage? {
        guard let country = self.country
        else { return  nil}
        
        let image = UIImage(named: country)
        return image
    }
    
}

// MARK: - Extenstion - Location Updates
extension Airport {
    
    class func updateLocation(_ currentLocation: CLLocation) {
        let editContext = CoreDataManager.editContextInBackground()
        let allAirports = editContext.fetchObjects(forEntityClass: Airport.self)
        
        for airport in allAirports {
            airport.updateDistance(forLocation: currentLocation)
        }
        
        editContext.saveContext()

    }

    private func updateDistance(forLocation currentLocation: CLLocation) {
        let currentDistance = location.distance(from: currentLocation)
        distance = currentDistance
    }
    
}

// MARK: - Extension Airport Attributes
extension Airport {
    struct Attributes {
        static let additionalInfo = "additionalInfo"
        static let airportType = "airportType"
        static let country = "country"
        static let distance = "distance"
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
