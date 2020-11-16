//
//  AirportDatabase.swift
//  Glider Tool
//
//  Created by Peter Hauke on 02.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - AirportDatabase
class AirportDatabase {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = AirportDatabase()
    // ... Notifications
    static let airportUpdateCompletedNotificationName = Notification.Name(rawValue: "airportUpdateCompleted")
    static let airportUpdateFailedNotificationName = Notification.Name(rawValue: "airportUpdateFailed")
    
    // Private
    private var destinationAirports = [AirportDatabase.Airport]()
    private let libraryURL: URL =  (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first as URL?)!
    
    // MARK: - Init&Co.
    private init() {
        checkForAirportsJSONInLibraryFolder()
        loadAirportsFromJSONIntoDatabase()
    }
    
    // MARK: - Public Class Methods
    // Give back all Airports from Airport Database
    class func destinationAirports()
        -> [AirportDatabase.Airport]? {
            let destinationAirports = shared.destinationAirports
            return destinationAirports
    }
    
    // Give back filtered Airports from Airport Database
    class func filteredDestinationAirports(byName searchString: String?,
                                           sortedBy sortIndicator: SortIndicator)
        -> [AirportDatabase.Airport]? {
            let filteredDestinationAirports = shared.filteredDestinationAirports(byName: searchString,
                                                                                 sortedBy: sortIndicator)
            return filteredDestinationAirports
    }
    
    // Give back nearest Airport from User Location
    class func nearestAirport()
        -> AirportDatabase.Airport? {
            let nearestAirport = shared.nearestAirport()
            return nearestAirport
    }
    
    // Download current Airports.json File from Server
    class func downloadAirportsFromServer() {
        shared.downloadAirportsFromServer()
    }
    
    // MARK: - Private Methods
    // Check if Airports.json exists in Library Folder
    private func checkForAirportsJSONInLibraryFolder() {
        // Check if Airports.json exists in Library Folder
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        let airportsInLibraryFolder = libraryURL.appendingPathComponent("Airports.json")
        let airportsInBundle = URL(fileURLWithPath: Bundle.main.path(forResource: "Airports", ofType: "json")!)
        
        if let pathComponent = url.appendingPathComponent("Airports.json") {
            
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("Airports.json available in Library Folder.")
            } else {
                print("Airports.json not found in Library Folder. Copy...")
                do {
                    try FileManager.default.copyItem(at: airportsInBundle, to: airportsInLibraryFolder)
                    print("Airports.json copied to Library Folder.")
                } catch let writeError {
                    print("Error creating a file: \(airportsInLibraryFolder) : \(writeError)")
                }
            }
        }
    }
    
    // Load Airports from Airports.json into Database
    private func loadAirportsFromJSONIntoDatabase() {
        // var for storing Content of Airports.json File
        var jsonAsString: String?
        
        let airportsURL = libraryURL.appendingPathComponent("Airports.json")
        
        do {
            // Storing Content of Airports.json File as String
            try jsonAsString = String.init(contentsOf: airportsURL)
        } catch {
            print("went wrong")
        }
        
        // Convert String to Data
        let jsonAsData = jsonAsString?.data(using: .utf8)
        
        // var for storing Content of Airports.json File as Dictionary
        var jsonAsDict = [String: Any]()
        
        do {
            // Convert Data to Dictionary
            jsonAsDict = try JSONSerialization.jsonObject(with: jsonAsData!,
                                                          options: .allowFragments) as! [String: Any]
        } catch {
            NotificationBanner.show("Airport Database not found.")
        }
        
        if let airports = jsonAsDict["Airports"] as? [[String: Any]] {
            // Append every single Object to Airports Database
            for airport in airports {
                let myAirportStruct = AirportDatabase.Airport(dictionary: airport)
                destinationAirports.append(myAirportStruct)
            }
        }
    }
    
    // Update Distances between User Location and Airports
    private func updateDistancesFromUserLocationToAirports() {
        if let currentLocation = LocationManager.currentLocation() {
            var puffer = [AirportDatabase.Airport]()
            for var destinationAirport in destinationAirports {
                
                let destinationAirportLocation = CLLocation(latitude: destinationAirport.latitude,
                                                            longitude: destinationAirport.longitude)
                
                let currentDistance = currentLocation.distance(from: destinationAirportLocation)
                destinationAirport.updateDistance(currentDistance)
                
                puffer.append(destinationAirport)
            }
            
            destinationAirports = puffer
        }
    }
    
    private func filteredDestinationAirports(byName searchString: String?,
                                             sortedBy sortIndicator: SortIndicator)
        -> [AirportDatabase.Airport]? {
            
            updateDistancesFromUserLocationToAirports()
            
            var filteredAndSortedAirports = [AirportDatabase.Airport]()
            
            // Filter
            var filteredArray = destinationAirports
            
            if let searchString = searchString,
                
                searchString.isEmpty == false {
                filteredArray = destinationAirports.filter { (airport) -> Bool in
                    let airportNameContainsSearchString = airport.name.localizedCaseInsensitiveContains(searchString)
                    let airportICAOContainsSearchString = airport.icao.localizedCaseInsensitiveContains(searchString)
                    let containsSearchString = airportNameContainsSearchString || airportICAOContainsSearchString
                    
                    return containsSearchString
                }
            }
            
            // Sorting Destination Airports
            switch sortIndicator {
            case .name:
                filteredAndSortedAirports = filteredArray.sorted(by: { ($0.name < $1.name) })
            case .distance:
                for destinationAirport in filteredArray where destinationAirport.distance == nil {
                    return filteredArray
                }
                
                filteredAndSortedAirports = filteredArray.sorted(by: { ($0.distance! < $1.distance!) })
            }
            
            return filteredAndSortedAirports
    }
    
    // Give back nearest Airport from User Location
    private func nearestAirport()
        -> Airport? {
            updateDistancesFromUserLocationToAirports()
            if let filterDestinationAirports = filteredDestinationAirports(byName: nil,
                                                                           sortedBy: .distance) {
                return filterDestinationAirports.first
            }
            
            return nil
    }
    
    // Download current Airports.json File from Server
    private func downloadAirportsFromServer() {
        // File Source URL
        if let airportsJSONFileURL = Presets.AirportDatabase.airportsJSONFileURL,
            UIApplication.shared.canOpenURL(airportsJSONFileURL as URL) {
            
            // Create destination URL
            let libraryUrl: URL =  (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first as URL?)!
            let destinationFileUrl = libraryUrl.appendingPathComponent("Airports.json")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let request = URLRequest(url: airportsJSONFileURL)
            
            let task = session.downloadTask(with: request) { [unowned self] (tempLocalUrl, response, error) in
               guard let tempLocalUrl = tempLocalUrl, error == nil
                else {
                    print("Error took place while downloading a file. Error description: %@", error!.localizedDescription)
                    
                    DispatchQueue.main.async {
                        NotificationBanner.show("Update failed. Check Internet Connection!")
                    }
                    
                    // Post Notification for failed Update
                    NotificationCenter.default.post(name: AirportDatabase.airportUpdateFailedNotificationName,
                                                    object: nil)
                    return
                }

                print("Downloading Airprt Database Update...")
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    // If successfully downloaded new Airports.json from server - (statuscode: 200)
                    if statusCode == 200 {
                        do {
                            try FileManager.default.removeItem(at: destinationFileUrl)
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                            
                            // Remove all Airports from Array
                            self.destinationAirports.removeAll()
                            
                            // Create Destination Airport List from new Airports.json
                            self.loadAirportsFromJSONIntoDatabase()
                            self.updateDistancesFromUserLocationToAirports()
                            
                            // Post Notification for comoleted Update
                            NotificationCenter.default.post(name: AirportDatabase.airportUpdateCompletedNotificationName,
                                                            object: nil)
                            
                            // Show Notification Banner
                            DispatchQueue.main.async {
                                NotificationBanner.show("Airport Database successfully updated.")
                            }
                            
                        } catch let writeError {
                            print("Error creating a file: \(destinationFileUrl) : \(writeError)")
                            
                            DispatchQueue.main.async {
                                NotificationBanner.show("Error creating file.")
                            }
                        }
                        
                        // If Download fails
                    } else {
                        print("Download failed. Status code: \(statusCode)")
                        
                        DispatchQueue.main.async {
                            NotificationBanner.show("Update server not reachable.")
                        }
                        
                        // Post Notification for failed Update
                        NotificationCenter.default.post(name: AirportDatabase.airportUpdateFailedNotificationName,
                                                        object: nil)
                        
                    }
                }
                
            }
            
            task.resume()
        } else {
            print("Airports.json URL is nil or Syntax has errors.")
        }
        // All done
    }
    
}

// MARK: - Extentsion - Structs and Enums

extension AirportDatabase {
    
    enum SortIndicator: Int {
        case name       = 0
        case distance   = 1
    }
    
    struct Airport: Equatable {
        // MARK: Lets and Vars
        var validationDate: String
        var icao: String
        var name: String
        var latitude: Double
        var longitude: Double
        var elevation: Double
        var airportType: String
        var runwaySurface: String
        var runwayDimensions: String
        var runwayDirections: String
        var url: String?
        var country: String
        /**In meters.*/
        var distance: CLLocationDistance?
        var phone: String?
        var additionalInfo: String?
        var radioName: String?
        var radioFrequency: String?
        
        // MARK: Init&Co.
        public init(dictionary: [String: Any] ) {
            self.validationDate = dictionary["validationDate"] as? String ?? ""
            self.icao = dictionary["icao"] as? String ?? ""
            self.name = dictionary["name"] as? String ?? ""
            self.latitude = dictionary["latitude"] as? Double ?? 0
            self.longitude = dictionary["longitude"] as? Double ?? 0
            self.elevation = dictionary["elevation"] as? Double ?? 0
            self.airportType = dictionary["airportType"] as? String ?? ""
            self.runwaySurface = dictionary["runwaySurface"] as? String ?? ""
            self.runwayDimensions = dictionary["runwayDimensions"] as? String ?? ""
            self.runwayDirections = dictionary["runwayDirections"] as? String ?? ""
            self.url = dictionary["url"] as? String ?? nil
            self.country = dictionary["country"] as? String ?? ""
            self.phone = dictionary["phone"] as? String ?? nil
            self.additionalInfo = dictionary["additionalInfo"] as? String ?? ""
            self.radioName = dictionary["radioName"] as? String ?? ""
            self.radioFrequency = dictionary["radioFrequency"] as? String ?? ""
            
        }
        
        // Equatable for comparing Airports
        static func == (lhs: Airport, rhs: Airport) -> Bool {
            return
                lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
        }
        
        // MARK: Public Methods
        mutating func updateDistance(_ newDistance: CLLocationDistance) {
            distance = newDistance
        }
        
        // TODO: Check, where we could use it: 05042020, ph
        func locationCoordinate2D()
            -> CLLocationCoordinate2D {
                let locationCoordinate2D = CLLocationCoordinate2D.init(latitude: latitude,
                                                                       longitude: longitude)
                return locationCoordinate2D
        }
        
        // TODO: Check, where we could use it: 08042020, ph
        func location()
            -> CLLocation {
                let location = CLLocation.init(latitude: latitude,
                                               longitude: longitude)
                return location
        }
    }
    
}
