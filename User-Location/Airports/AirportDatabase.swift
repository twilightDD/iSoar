//
//  AirportDatabase.swift
//  Glider Tool
//
//  Created by Peter Hauke on 02.06.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

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
        checkForMapOjectsInLibraryFolder()
        loadAirports()
    }

    // MARK: - Public Class Methods
    class func nearestAirport ()
        -> AirportDatabase.Airport? {
            let nearestAirport = shared.nearestAirport()
            return nearestAirport
    }

    class func icaoOfNearestAirport()
        -> String? {
            let nearestAirport = AirportDatabase.nearestAirport()
            let icaoOfNearestAirport = nearestAirport?.icao
            return icaoOfNearestAirport
    }

    class func filteredDestinationAirports(byName searchString: String?,
                                           sortedBy sortIndicator: SortIndicator)
        -> [AirportDatabase.Airport]? {
            let filteredDestinationAirports = shared.filteredDestinationAirports(byName: searchString,
                                                                               sortedBy: sortIndicator)
            return filteredDestinationAirports
    }

    class func downloadAirportsFromServer() {
        shared.downloadAirportsFromServer()
    }

    // MARK: - Private Methods
    private func updateDistance() {
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

            updateDistance()

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
                // In case of a malfuction of where clousure above, use this code:
                //                for destinationAirport in filteredArray {
                //                    if destinationAirport.distance == nil {
                //                        return filteredArray
                //                    }
                //                }

                filteredAndSortedAirports = filteredArray.sorted(by: { ($0.distance! < $1.distance!) })
            }
            
            return filteredAndSortedAirports
    }

    private func nearestAirport()
        -> Airport? {
            updateDistance()
            if let filterDestinationAirports = filteredDestinationAirports(byName: nil,
                                                                         sortedBy: .distance) {
                return filterDestinationAirports.first
            }
            
            return nil
    }

    private func downloadAirportsFromServer() {
        // Create destination URL
        let libraryUrl: URL =  (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = libraryUrl.appendingPathComponent("Airports.json")
        
        // File Source URL
        let fileURL = URL(string: "https://www.leupold.me/Airports.json")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url: fileURL!)
        
        let task = session.downloadTask(with: request) { [unowned self] (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                print("Downloading Airprt Database Update...")
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.removeItem(at: destinationFileUrl)
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    
                    // Clear Airports.shared.destinationAirports
                    self.destinationAirports.removeAll()
                    
                    // Create Destination Airport List from new Airports.json
                    self.loadAirports()
                    self.updateDistance()
                    
                    // Post Notification for comoleted Update
                    NotificationCenter.default.post(name: AirportDatabase.airportUpdateCompletedNotificationName,
                                                    object: nil)
                    
                } catch let writeError {
                    // TODO: @dl UserInfo; 04042020, ph
                    print("Error creating a file: \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                // TODO: @dl UserInfo; 04042020, ph
                print("Error took place while downloading a file. Error description: %@", error!.localizedDescription)
                
                // Post Notification for failed Update
                NotificationCenter.default.post(name: AirportDatabase.airportUpdateFailedNotificationName,
                                                object: nil)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Methods
    // Check if MapOjects.json exists in Library Folder
    private func checkForMapOjectsInLibraryFolder() {
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
    
    // Load Airports from json
    private func loadAirports() {
        // --- json laden
        
        // hier kommt der Inhalt der Datein rein
        var jsonAsString: String?
        
        let airportsURL = libraryURL.appendingPathComponent("Airports.json")
        
        do {
            // URL laden und als String zurück geben
            try jsonAsString = String.init(contentsOf: airportsURL)
        } catch {
            print("went wrong")
        }
        
        // String in Data konvertieren
        let jsonAsData = jsonAsString?.data(using: .utf8)
        
        // hier kommt der Inhalt der Datei als Dictionary rein
        var jsonAsDict = [String: Any]()
        do {
            // Umwandeln des Data in ein Dictionary (nennt sich deserialisieren)
            jsonAsDict = try JSONSerialization.jsonObject(with: jsonAsData!,
                                                          options: .allowFragments) as! [String: Any]
        } catch {
            print("json went wrong")
        }
        
        if let airports = jsonAsDict["Airports"] as? [Dictionary<String, Any>] {
            // jedes Element des Arrays abklappern
            for airport in airports {
                let myAirportStruct = AirportDatabase.Airport(dictionary: airport)
                destinationAirports.append(myAirportStruct)
            }
        }
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
        var country: String?
        /**In meters.*/
        var distance: CLLocationDistance?
        var phone: String?
        var additionalInfo: String?
        var radioName: String?
        var radioFrequency: String?
        
        // var radios:[Radio] // hinzufügen => ProTipp: Struct ;)
        
        // MARK: Init&Co.
        public init(dictionary: Dictionary<String, Any>) {
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
        
        // MARK: Public Methods
        mutating func updateDistance(_ newDistance: CLLocationDistance) {
            distance = newDistance
        }
        
    }
}
